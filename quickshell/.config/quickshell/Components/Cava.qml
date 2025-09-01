import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Settings

Scope {
    id: root
    // Default bars reduced by one third: 64 -> ~43
    property int count: 43
    // Pull defaults from settings for a crisper, less-smoothed look
    property int noiseReduction: (Settings.settings.cavaNoiseReduction !== undefined ? Settings.settings.cavaNoiseReduction : 5)
    property int framerate:      (Settings.settings.cavaFramerate      !== undefined ? Settings.settings.cavaFramerate      : 30)
    property int gravity:        (Settings.settings.cavaGravity        !== undefined ? Settings.settings.cavaGravity        : 20000)
    property bool monstercat:    (Settings.settings.cavaMonstercat     !== undefined ? Settings.settings.cavaMonstercat     : false)
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

    Process {
        id: process
        property int index: 0
        stdinEnabled: true
        running: MusicManager.isPlaying
        command: ["cava", "-p", "/dev/stdin"]
        onExited: {
            stdinEnabled = true;
            index = 0;
            values = Array(count).fill(0);
        }
        onStarted: {
            for (const k in config) {
                if (typeof config[k] !== "object") {
                    write(k + "=" + config[k] + "\n");
                    continue;
                }
                write("[" + k + "]\n");
                const obj = config[k];
                for (const k2 in obj) {
                    write(k2 + "=" + obj[k2] + "\n");
                }
            }
            stdinEnabled = false;
        }
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const newValues = Array(count).fill(0);
                for (let i = 0; i < values.length; i++) {
                    newValues[i] = values[i];
                }
                if (process.index + data.length > count) {
                    process.index = 0;
                }
                for (let i = 0; i < data.length; i += 1) {
                    newValues[process.index] = Math.min(data.charCodeAt(i), 128) / 128;
                    process.index = (process.index+1) % count;
                }
                values = newValues;
            }
        }
    }
}
