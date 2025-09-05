try { Qt.include("./Http.js"); } catch (e) { }
// Fallback shim if httpGetJson is not provided by Http.js
if (typeof httpGetJson !== 'function') {
    function httpGetJson(url, timeoutMs, success, fail, userAgent) {
        try {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", url, true);
            if (timeoutMs !== undefined && timeoutMs !== null) xhr.timeout = timeoutMs;
            try {
                if (xhr.setRequestHeader) {
                    try { xhr.setRequestHeader('Accept', 'application/json'); } catch (e1) {}
                    if (userAgent) { try { xhr.setRequestHeader('User-Agent', String(userAgent)); } catch (e2) {} }
                }
            } catch (e3) {}
            xhr.onreadystatechange = function() {
                if (xhr.readyState !== XMLHttpRequest.DONE) return;
                var status = xhr.status;
                if (status === 200) {
                    try { success && success(JSON.parse(xhr.responseText)); }
                    catch (e) { fail && fail({ type: 'parse' }); }
                } else {
                    var retryAfter = 0; try { var ra = xhr.getResponseHeader && xhr.getResponseHeader('Retry-After'); if (ra) retryAfter = Number(ra) * 1000; } catch (e4) {}
                    fail && fail({ type: 'http', status: status, retryAfter: retryAfter });
                }
            };
            xhr.ontimeout = function(){ fail && fail({ type: 'timeout' }); };
            xhr.onerror = function(){ fail && fail({ type: 'network' }); };
            xhr.send();
        } catch (e) { fail && fail({ type: 'exception' }); }
    }
}
var _countryCode = null;
var _regionCode = null;
var _regionName = null;
var _locationExpiry = 0;
var _holidaysCache = {}; // key: "year-country" -> { value, expiry, errorUntil }
// Shared HTTP helper
try { Qt.include("./Http.js") /* deprecated include; kept for compatibility if needed */; } catch (e) { }

var DEFAULTS = {
    locationTtlMs: 24 * 60 * 60 * 1000,  // 24h
    holidaysTtlMs: 24 * 60 * 60 * 1000,  // 24h (holidays are static per year)
    errorTtlMs: 30 * 60 * 1000,          // 30m backoff on 429/5xx
    timeoutMs: 8000                      // 8s timeout
};

function now() { return Date.now(); }

function qsFrom(obj) {
    var parts = [];
    for (var k in obj) {
        if (!obj.hasOwnProperty(k)) continue;
        var v = obj[k];
        if (v === undefined || v === null) continue;
        parts.push(encodeURIComponent(k) + "=" + encodeURIComponent(String(v)));
    }
    return parts.join("&");
}

function buildUrl(base, paramsObj) {
    try {
        if (typeof URL !== 'undefined' && typeof URLSearchParams !== 'undefined') {
            var u = new URL(base);
            var p = new URLSearchParams();
            for (var key in paramsObj) {
                if (!paramsObj.hasOwnProperty(key)) continue;
                var val = paramsObj[key];
                if (val === undefined || val === null) continue;
                p.set(key, String(val));
            }
            u.search = p.toString();
            return u.toString();
        }
    } catch (e) { /* fallthrough */ }
    var qs = qsFrom(paramsObj);
    return qs ? (base + "?" + qs) : base;
}

function readCache(store, key) {
    var entry = store[key];
    if (!entry) return null;
    var t = now();
    if (entry.errorUntil && t < entry.errorUntil) {
        return { error: true };
    }
    if (entry.expiry && t < entry.expiry) {
        return { value: entry.value };
    }
    delete store[key];
    return null;
}

function writeCacheSuccess(store, key, value, ttlMs) {
    store[key] = { value: value, expiry: now() + ttlMs };
}

function writeCacheError(store, key, errorTtlMs) {
    store[key] = { errorUntil: now() + errorTtlMs };
}

// xhrGetJson removed; use httpGetJson from Helpers/Http.js

function getCountryCode(callback, errorCallback, options) {
    options = options || {};
    var cfg = {
        locationTtlMs: options.locationTtlMs || DEFAULTS.locationTtlMs,
        errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
        timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs
    };
    var t = now();
    if (_countryCode && t < _locationExpiry) {
        callback(_countryCode);
        return;
    }

    var _ua = (options && options.userAgent) ? String(options.userAgent) : "Quickshell";
    var dbg = !!(options && options.debug);
    var url = buildUrl("https://nominatim.openstreetmap.org/search", {
        city: Settings.settings.weatherCity || "",
        country: "",
        format: "json",
        addressdetails: 1,
        extratags: 1
    });
    if (dbg) try { console.debug('[Holidays] GET', url); } catch (e) {}
    httpGetJson(url, cfg.timeoutMs, function(response) {
        try {
            _countryCode = (response && response[0] && response[0].address && response[0].address.country_code) ? response[0].address.country_code : "US";
            _regionCode = (response && response[0] && response[0].address && response[0].address["ISO3166-2-lvl4"]) ? response[0].address["ISO3166-2-lvl4"] : "";
            _regionName = (response && response[0] && response[0].address && response[0].address.state) ? response[0].address.state : "";
            _locationExpiry = now() + cfg.locationTtlMs;
            callback(_countryCode);
        } catch (e) {
            errorCallback && errorCallback("Failed to parse location data");
        }
    }, function(err) {
        // Back off location lookup if Retry-After or server error
        if (err) {
            var backoff = (err.retryAfter && err.retryAfter > 0) ? err.retryAfter : 0;
            if (!backoff && (err.status === 429 || (err.status >= 500 && err.status <= 599))) backoff = cfg.errorTtlMs;
            if (backoff > 0) _locationExpiry = now() + backoff;
        }
        errorCallback && errorCallback("Location lookup error: " + (err.status || err.type || "unknown"));
    }, _ua);
}

function getHolidays(year, countryCode, callback, errorCallback, options) {
    options = options || {};
    var cfg = {
        holidaysTtlMs: options.holidaysTtlMs || DEFAULTS.holidaysTtlMs,
        errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
        timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs
    };
    var cacheKey = year + "-" + (countryCode || "");
    var cached = readCache(_holidaysCache, cacheKey);
    if (cached) {
        if (cached.error) {
            errorCallback && errorCallback("Holidays temporarily unavailable; retry later");
            return;
        }
        callback(cached.value);
        return;
    }

    var url = "https://date.nager.at/api/v3/PublicHolidays/" + year + "/" + countryCode;

    if (dbg) try { console.debug('[Holidays] GET', url); } catch (e) {}
    httpGetJson(url, cfg.timeoutMs, function(list) {
        try {
            var augmented = filterHolidaysByRegion(list || []);
            writeCacheSuccess(_holidaysCache, cacheKey, augmented, cfg.holidaysTtlMs);
            callback(augmented);
        } catch (e) {
            errorCallback && errorCallback("Failed to process holidays");
        }
    }, function(err) {
        if (err) {
            var backoff = (err.retryAfter && err.retryAfter > 0) ? err.retryAfter : 0;
            if (!backoff && (err.status === 429 || (err.status >= 500 && err.status <= 599))) backoff = cfg.errorTtlMs;
            if (backoff > 0) writeCacheError(_holidaysCache, cacheKey, backoff);
        }
        errorCallback && errorCallback("Holidays fetch error: " + (err.status || err.type || "unknown"));
    }, _ua);
}

function filterHolidaysByRegion(holidays) {
    if (!_regionCode) {
        return holidays;
    }
    const retHolidays = [];
    holidays.forEach(function(holiday) {
        if (holiday.counties?.length > 0) {
            let found = false;
            holiday.counties.forEach(function(county) {
                if (county.toLowerCase() === _regionCode.toLowerCase()) {
                    found = true;
                }
            });
            if (found) {
                var regionText = " (" + _regionName + ")";
                holiday.name = holiday.name + regionText;
                holiday.localName = holiday.localName + regionText;
                retHolidays.push(holiday);
            }
        } else {
            retHolidays.push(holiday);
        }
    });
    return retHolidays;
}

function getHolidaysForMonth(year, month, callback, errorCallback, options) {
    getCountryCode(function(countryCode) {
        getHolidays(year, countryCode, function(holidays) {
            var filtered = holidays.filter(function(h) {
                var date = new Date(h.date);
                return date.getFullYear() === year && date.getMonth() === month;
            });
            callback(filtered);
        }, errorCallback, options);
    }, errorCallback, options);
}
