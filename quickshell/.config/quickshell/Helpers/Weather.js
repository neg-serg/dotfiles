// In-memory caches with TTL
var _geoCache = {}; // key: cityLower -> { value: {lat, lon}, expiry: ts, errorUntil?: ts }
var _weatherCache = {}; // key: cityLower -> { value: weatherObject, expiry: ts, errorUntil?: ts }
// Shared HTTP helper
try { Qt.include("Http.js"); } catch (e) { }

// Defaults (can be overridden via options argument)
var DEFAULTS = {
    geocodeTtlMs: 24 * 60 * 60 * 1000,   // 24h
    weatherTtlMs: 5 * 60 * 1000,         // 5m
    errorTtlMs: 2 * 60 * 1000,           // 2m backoff for 429/5xx
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
        return { error: true, retryAt: entry.errorUntil };
    }
    if (entry.expiry && t < entry.expiry) {
        return { value: entry.value };
    }
    // expired
    delete store[key];
    return null;
}

function writeCacheSuccess(store, key, value, ttlMs) {
    store[key] = { value: value, expiry: now() + ttlMs };
}

function writeCacheError(store, key, errorTtlMs) {
    store[key] = { errorUntil: now() + errorTtlMs };
}

function xhrGetJson(url, timeoutMs, success, fail) {
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
                    fail && fail({ type: "parse", message: "Failed to parse JSON" });
                }
            } else {
                fail && fail({ type: "http", status: status });
            }
        };
        xhr.ontimeout = function() {
            fail && fail({ type: "timeout" });
        };
        xhr.onerror = function() {
            fail && fail({ type: "network" });
        };
        xhr.send();
    } catch (e) {
        fail && fail({ type: "exception", message: String(e) });
    }
}

function fetchCoordinates(city, callback, errorCallback, options) {
    options = options || {};
    var cfg = {
        geocodeTtlMs: options.geocodeTtlMs || DEFAULTS.geocodeTtlMs,
        errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
        timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs
    };
    var key = String(city || "").trim().toLowerCase();
    if (!key) {
        if (errorCallback) errorCallback("City is empty");
        return;
    }

    var cached = readCache(_geoCache, key);
    if (cached) {
        if (cached.error) {
            errorCallback && errorCallback("Geocoding temporarily unavailable; retry later");
            return;
        }
        if (cached.value) {
            callback(cached.value.lat, cached.value.lon);
            return;
        }
    }

    var geoUrl = buildUrl("https://geocoding-api.open-meteo.com/v1/search", {
        name: city,
        language: "en",
        format: "json",
        count: 1
    });

    // Prefer shared httpGetJson with User-Agent if available
    var _ua = (options && options.userAgent) ? String(options.userAgent) : "Quickshell";
    if (typeof httpGetJson === 'function') {
        httpGetJson(geoUrl, cfg.timeoutMs, function(geoData) {
            try {
                if (geoData && geoData.results && geoData.results.length > 0) {
                    var lat = geoData.results[0].latitude;
                    var lon = geoData.results[0].longitude;
                    writeCacheSuccess(_geoCache, key, { lat: lat, lon: lon }, cfg.geocodeTtlMs);
                    callback(lat, lon);
                } else {
                    writeCacheError(_geoCache, key, cfg.errorTtlMs);
                    errorCallback && errorCallback("City not found");
                }
            } catch (e) {
                writeCacheError(_geoCache, key, cfg.errorTtlMs);
                errorCallback && errorCallback("Failed to parse geocoding data");
            }
        }, function(err) {
            if (err && (err.status === 429 || (err.status >= 500 && err.status <= 599))) {
                writeCacheError(_geoCache, key, cfg.errorTtlMs);
            }
            errorCallback && errorCallback("Geocoding error: " + (err.status || err.type || "unknown"));
        }, _ua);
        return;
    }
    xhrGetJson(geoUrl, cfg.timeoutMs, function(geoData) {
        try {
            if (geoData && geoData.results && geoData.results.length > 0) {
                var lat = geoData.results[0].latitude;
                var lon = geoData.results[0].longitude;
                writeCacheSuccess(_geoCache, key, { lat: lat, lon: lon }, cfg.geocodeTtlMs);
                callback(lat, lon);
            } else {
                writeCacheError(_geoCache, key, cfg.errorTtlMs);
                errorCallback && errorCallback("City not found");
            }
        } catch (e) {
            writeCacheError(_geoCache, key, cfg.errorTtlMs);
            errorCallback && errorCallback("Failed to parse geocoding data");
        }
    }, function(err) {
        if (err && (err.status === 429 || (err.status >= 500 && err.status <= 599))) {
            writeCacheError(_geoCache, key, cfg.errorTtlMs);
        }
        errorCallback && errorCallback("Geocoding error: " + (err.status || err.type || "unknown"));
    });
}

function fetchWeather(latitude, longitude, callback, errorCallback, options) {
    options = options || {};
    var cfg = {
        weatherTtlMs: options.weatherTtlMs || DEFAULTS.weatherTtlMs,
        errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
        timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs,
        cityKey: options.cityKey || null
    };

    var cacheKey = cfg.cityKey ? String(cfg.cityKey).toLowerCase() : null;
    if (cacheKey) {
        var cached = readCache(_weatherCache, cacheKey);
        if (cached) {
            if (cached.error) {
                errorCallback && errorCallback("Weather temporarily unavailable; retry later");
                return;
            }
            if (cached.value) {
                callback(cached.value);
                return;
            }
        }
    }

    var url = buildUrl("https://api.open-meteo.com/v1/forecast", {
        latitude: String(latitude),
        longitude: String(longitude),
        current_weather: "true",
        current: "relativehumidity_2m,surface_pressure",
        daily: "temperature_2m_max,temperature_2m_min,weathercode",
        timezone: "auto"
    });

    if (typeof httpGetJson === 'function') {
        httpGetJson(url, cfg.timeoutMs, function(weatherData) {
            if (cacheKey) writeCacheSuccess(_weatherCache, cacheKey, weatherData, cfg.weatherTtlMs);
            callback(weatherData);
        }, function(err) {
            if (cacheKey && err && (err.status === 429 || (err.status >= 500 && err.status <= 599))) {
                writeCacheError(_weatherCache, cacheKey, cfg.errorTtlMs);
            }
            errorCallback && errorCallback("Weather fetch error: " + (err.status || err.type || "unknown"));
        }, _ua);
        return;
    }
    xhrGetJson(url, cfg.timeoutMs, function(weatherData) {
        if (cacheKey) writeCacheSuccess(_weatherCache, cacheKey, weatherData, cfg.weatherTtlMs);
        callback(weatherData);
    }, function(err) {
        if (cacheKey && err && (err.status === 429 || (err.status >= 500 && err.status <= 599))) {
            writeCacheError(_weatherCache, cacheKey, cfg.errorTtlMs);
        }
        errorCallback && errorCallback("Weather fetch error: " + (err.status || err.type || "unknown"));
    });
}

function fetchCityWeather(city, callback, errorCallback, options) {
    options = options || {};
    var cityKey = String(city || "").trim();
    fetchCoordinates(cityKey, function(lat, lon) {
        fetchWeather(lat, lon, function(weatherData) {
            callback({
                city: cityKey,
                latitude: lat,
                longitude: lon,
                weather: weatherData
            });
        }, errorCallback, {
            weatherTtlMs: options.weatherTtlMs || DEFAULTS.weatherTtlMs,
            errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
            timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs,
            cityKey: cityKey
        });
    }, errorCallback, {
        geocodeTtlMs: options.geocodeTtlMs || DEFAULTS.geocodeTtlMs,
        errorTtlMs: options.errorTtlMs || DEFAULTS.errorTtlMs,
        timeoutMs: options.timeoutMs || DEFAULTS.timeoutMs
    });
} 
