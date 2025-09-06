import QtQuick
import "../Helpers/Utils.js" as Utils
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Scope {
    id: root
    // Default bars reduced by one third: 64 -> ~43
    property int count: 43
    // Pull defaults from settings for a crisper, less-smoothed look
    // Active profile (if any)
    property var _vp: (Settings.settings.visualizerProfiles && Settings.settings.activeVisualizerProfile && Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile]) ? Settings.settings.visualizerProfiles[Settings.settings.activeVisualizerProfile] : null
    property int noiseReduction: (_vp && _vp.cavaNoiseReduction !== undefined) ? _vp.cavaNoiseReduction : (Settings.settings.cavaNoiseReduction !== undefined ? Settings.settings.cavaNoiseReduction : 5)
    // Clamp framerate to a safe range 1..120
    property int framerate: (function(){
        var raw = (_vp && _vp.cavaFramerate !== undefined) ? _vp.cavaFramerate
                 : (Settings.settings.cavaFramerate !== undefined ? Settings.settings.cavaFramerate : 30);
        return Utils.clamp(Utils.coerceInt(raw, 30), 1, 120);
    })()
    property int gravity:        (_vp && _vp.cavaGravity        !== undefined) ? _vp.cavaGravity        : (Settings.settings.cavaGravity        !== undefined ? Settings.settings.cavaGravity        : 20000)
    property bool monstercat:    (_vp && _vp.cavaMonstercat     !== undefined) ? _vp.cavaMonstercat     : (Settings.settings.cavaMonstercat     !== undefined ? Settings.settings.cavaMonstercat     : false)
    property string channels: "mono"
    property string monoOption: "average"

    property var config: ({
            general: {
                bars: count,
                framerate: framerate,
                autosens: 1
            },
            smoothing: {
                monstercat: monstercat ? 1 : 0,
                gravity: gravity,
                noise_reduction: noiseReduction
            },
            output: {
                method: "raw",
                bit_format: 8,
                channels: channels,
                mono_option: monoOption
            }
        })

    property var values: Array(count).fill(0)

    ProcessRunner {
        id: process
        property int index: 0
        autoStart: (Settings.settings.showMediaVisualizer === true) && MusicManager.isPlaying
        cmd: ["cava", "-p", "/dev/stdin"]
        stdinEnabled: true
        rawMode: true
        restartMode: "always"
        onExited: {
            process.stdinEnabled = true;
            process.index = 0;
            values = Array(count).fill(0);
        }
        onStarted: {
            for (const k in config) {
                if (typeof config[k] !== "object") {
                    process.write(k + "=" + config[k] + "\n");
                    continue;
                }
                process.write("[" + k + "]\n");
                const obj = config[k];
                for (const k2 in obj) {
                    process.write(k2 + "=" + obj[k2] + "\n");
                }
            }
            process.stdinEnabled = false;
        }
        onChunk: (data) => {
            const newValues = Array(count).fill(0);
            for (let i = 0; i < values.length; i++) newValues[i] = values[i];
            if (process.index + data.length > count) process.index = 0;
            for (let i = 0; i < data.length; i += 1) {
                newValues[process.index] = Utils.clamp(data.charCodeAt(i), 0, 128) / 128;
                process.index = (process.index + 1) % count;
            }
            values = newValues;
        }
    }
}
