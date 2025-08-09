function formatVagueHumanReadableTime(totalSeconds) {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds - (hours * 3600)) / 60);
    const seconds = totalSeconds - (hours * 3600) - (minutes * 60);
 
    var str = "";
    if (hours) {
        str += hours.toString() + "h";
    }
    if (minutes) {
        str += minutes.toString() + "m";
    }
    if (!hours && !minutes) {
        str += seconds.toString() + "s";
    }
    return str;
}

