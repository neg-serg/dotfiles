var _countryCode = null;
var _regionCode = null;
var _regionName = null;
var _locationExpiry = 0;
var _holidaysCache = {}; // key: "year-country" -> { value, expiry, errorUntil }

var DEFAULTS = {
    locationTtlMs: 24 * 60 * 60 * 1000,  // 24h
    holidaysTtlMs: 24 * 60 * 60 * 1000,  // 24h (holidays are static per year)
    errorTtlMs: 30 * 60 * 1000,          // 30m backoff on 429/5xx
    timeoutMs: 8000                      // 8s timeout
};

function _now() { return Date.now(); }

function _qsFrom(obj) {
    var parts = [];
    for (var k in obj) {
        if (!obj.hasOwnProperty(k)) continue;
        var v = obj[k];
        if (v === undefined || v === null) continue;
        parts.push(encodeURIComponent(k) + "=" + encodeURIComponent(String(v)));
    }
    return parts.join("&");
}

function _buildUrl(base, paramsObj) {
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
    var qs = _qsFrom(paramsObj);
    return qs ? (base + "?" + qs) : base;
}

function _readCache(store, key) {
    var entry = store[key];
    if (!entry) return null;
    var now = _now();
    if (entry.errorUntil && now < entry.errorUntil) {
        return { error: true };
    }
    if (entry.expiry && now < entry.expiry) {
        return { value: entry.value };
    }
    delete store[key];
    return null;
}

function _writeCacheSuccess(store, key, value, ttlMs) {
    store[key] = { value: value, expiry: _now() + ttlMs };
}

function _writeCacheError(store, key, errorTtlMs) {
    store[key] = { errorUntil: _now() + errorTtlMs };
}

function _xhrGetJson(url, timeoutMs, success, fail) {
    try {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.timeout = timeoutMs;
        // Some APIs require an explicit User-Agent; set if allowed
        try {
            if (xhr.setRequestHeader) {
                try { xhr.setRequestHeader('Accept', 'application/json'); } catch (e1) {}
                try { xhr.setRequestHeader('User-Agent', 'Quickshell'); } catch (e2) {}
            }
        } catch (e) { /* ignore header setting failures */ }
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            var status = xhr.status;
            if (status === 200) {
                try {
                    success(JSON.parse(xhr.responseText));
                } catch (e) {
                    fail && fail({ type: "parse" });
                }
            } else {
                fail && fail({ type: "http", status: status });
            }
        };
        xhr.ontimeout = function() { fail && fail({ type: "timeout" }); };
        xhr.onerror = function() { fail && fail({ type: "network" }); };
        xhr.send();
    } catch (e) {
        fail && fail({ type: "exception" });
    }
}

function getCountryCode(callback, errorCallback, options) {
    options = options || {};
    var cfg = {
        locationTtlMs: options.locationTtlMs || DEFAULTS.locationTtlMs,
        errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
        timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs
    };
    var now = _now();
    if (_countryCode && now < _locationExpiry) {
        callback(_countryCode);
        return;
    }

    var url = _buildUrl("https://nominatim.openstreetmap.org/search", {
        city: Settings.settings.weatherCity || "",
        country: "",
        format: "json",
        addressdetails: 1,
        extratags: 1
    });

    _xhrGetJson(url, cfg.timeoutMs, function(response) {
        try {
            _countryCode = (response && response[0] && response[0].address && response[0].address.country_code) ? response[0].address.country_code : "US";
            _regionCode = (response && response[0] && response[0].address && response[0].address["ISO3166-2-lvl4"]) ? response[0].address["ISO3166-2-lvl4"] : "";
            _regionName = (response && response[0] && response[0].address && response[0].address.state) ? response[0].address.state : "";
            _locationExpiry = _now() + cfg.locationTtlMs;
            callback(_countryCode);
        } catch (e) {
            errorCallback && errorCallback("Failed to parse location data");
        }
    }, function(err) {
        errorCallback && errorCallback("Location lookup error: " + (err.status || err.type || "unknown"));
    });
}

function getHolidays(year, countryCode, callback, errorCallback, options) {
    options = options || {};
    var cfg = {
        holidaysTtlMs: options.holidaysTtlMs || DEFAULTS.holidaysTtlMs,
        errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
        timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs
    };
    var cacheKey = year + "-" + (countryCode || "");
    var cached = _readCache(_holidaysCache, cacheKey);
    if (cached) {
        if (cached.error) {
            errorCallback && errorCallback("Holidays temporarily unavailable; retry later");
            return;
        }
        callback(cached.value);
        return;
    }

    var url = "https://date.nager.at/api/v3/PublicHolidays/" + year + "/" + countryCode;

    _xhrGetJson(url, cfg.timeoutMs, function(list) {
        try {
            var augmented = filterHolidaysByRegion(list || []);
            _writeCacheSuccess(_holidaysCache, cacheKey, augmented, cfg.holidaysTtlMs);
            callback(augmented);
        } catch (e) {
            errorCallback && errorCallback("Failed to process holidays");
        }
    }, function(err) {
        if (err && (err.status === 429 || (err.status >= 500 && err.status <= 599))) {
            _writeCacheError(_holidaysCache, cacheKey, cfg.errorTtlMs);
        }
        errorCallback && errorCallback("Holidays fetch error: " + (err.status || err.type || "unknown"));
    });
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
