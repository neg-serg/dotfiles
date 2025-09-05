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

// httpGetJson removed; use httpGetJson from Helpers/Http.js

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

    // Use shared httpGetJson with User-Agent
    var _ua = (options && options.userAgent) ? String(options.userAgent) : "Quickshell";
    if (typeof httpGetJson === 'function') {
        var dbg = !!(options && options.debug);
    if (dbg) try { console.debug('[Weather] GET', geoUrl); } catch (e) {}
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
    var dbg = !!(options && options.debug);
    if (dbg) try { console.debug('[Weather] GET', geoUrl); } catch (e) {}
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
        if (err) {
            var backoff = (err.retryAfter && err.retryAfter > 0) ? err.retryAfter : 0;
            if (!backoff && (err.status === 429 || (err.status >= 500 && err.status <= 599))) backoff = cfg.errorTtlMs;
            if (backoff) writeCacheError(_geoCache, key, backoff);
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
    var _ua = (options && options.userAgent) ? String(options.userAgent) : "Quickshell";
    if (dbg) try { console.debug('[Weather] GET', url); } catch (e) {}
    httpGetJson(url, cfg.timeoutMs, function(weatherData) {
        if (cacheKey) writeCacheSuccess(_weatherCache, cacheKey, weatherData, cfg.weatherTtlMs);
        callback(weatherData);
    }, function(err) {
        if (cacheKey && err) {
            var backoff = (err.retryAfter && err.retryAfter > 0) ? err.retryAfter : 0;
            if (!backoff && (err.status === 429 || (err.status >= 500 && err.status <= 599))) backoff = cfg.errorTtlMs;
            if (backoff) writeCacheError(_weatherCache, cacheKey, backoff);
        }
        errorCallback && errorCallback("Weather fetch error: " + (err.status || err.type || "unknown"));
    }, _ua);
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
