var _countryCode = null;
var _regionCode = null;
var _regionName = null;
var _holidaysCache = {};

function getCountryCode(callback) {
    if (_countryCode) {
        callback(_countryCode);
        return;
    }
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "https://nominatim.openstreetmap.org/search?city="+ Settings.settings.weatherCity+"&country=&format=json&addressdetails=1&extratags=1", true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
            var response = JSON.parse(xhr.responseText);
            _countryCode = response?.[0]?.address?.country_code ?? "US";
            _regionCode = response?.[0]?.address?.["ISO3166-2-lvl4"] ?? "";
            _regionName = response?.[0]?.address?.state ?? "";
            callback(_countryCode);
        }
    }
    xhr.send();
}

function getHolidays(year, countryCode, callback) {
    var cacheKey = year + "-" + countryCode;
    if (_holidaysCache[cacheKey]) {
        callback(_holidaysCache[cacheKey]);
        return;
    }
    var url = "https://date.nager.at/api/v3/PublicHolidays/" + year + "/" + countryCode;
    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
            var holidays = JSON.parse(xhr.responseText);
            var augmentedHolidays = filterHolidaysByRegion(holidays);
            _holidaysCache[cacheKey] = augmentedHolidays;
            callback(augmentedHolidays);
        }
    }
    xhr.send();
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

function getHolidaysForMonth(year, month, callback) {
    getCountryCode(function(countryCode) {
        getHolidays(year, countryCode, function(holidays) {
            var filtered = holidays.filter(function(h) {
                var date = new Date(h.date);
                return date.getFullYear() === year && date.getMonth() === month;
            });
            callback(filtered);
        });
    });
}