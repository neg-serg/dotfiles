import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Services
import qs.Settings

Item {
    id: workspace
    property string wsName: "?"     // Current workspace name
    property int wsId: -1           // Current workspace ID

    // Let the component size itself to fit the label
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Label {
        id: label
        text: wsName !== "" ? wsName : (wsId >= 0 ? wsId.toString() : "?")
        font.bold: true
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall * Theme.scale(Screen)
        color: Theme.textPrimary
        padding: 6
    }

    // One-time request
    Process {
        id: getCurrentWS
        command: ["hyprctl", "-j", "activeworkspace"]
        // ensure parser exists before starting
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const obj = JSON.parse(text);
                    workspace.wsId = obj.id ?? -1;
                    workspace.wsName = obj.name ?? "";
                } catch (e) { console.log("activeworkspace parse error:", e); }
            }
        }

        // inherit the Hyprland signature explicitly
        environment: [
            "HYPRLAND_INSTANCE_SIGNATURE=" + (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? "")
        ]
        Component.onCompleted: running = true
    }

    // Subscription (line-by-line)
    Process {
        id: subscribe

        command: [ws.hyprctl, "-s"]

        // keep our own buffer + last processed length
        property string _buf: ""
        property int _lastLen: 0

        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                // take only the newly appended part of the collector's text
                const chunk = text.substring(subscribe._lastLen);
                subscribe._lastLen = text.length;

                // append and process complete lines
                subscribe._buf += chunk;
                let lines = subscribe._buf.split("\n");
                subscribe._buf = lines.pop(); // keep incomplete tail

                for (let line of lines) {
                    line = line.trim();
                    if (!line) continue;

                    if (line.startsWith("workspacev2>>")) {
                        const payload = line.split(">>")[1] || "";
                        const toks = payload.split(/\s+/);
                        const idNum = parseInt(toks[0]);
                        if (!Number.isNaN(idNum)) ws.wsId = idNum;
                        const nameKV = toks.find(t => t.startsWith("name:"));
                        ws.wsName = nameKV ? nameKV.slice(5)
                        : (toks[1] && !/^\d+$/.test(toks[1]) ? toks[1] : "");
                    } else if (line.startsWith("workspace>>")) {
                        const idNum = parseInt((line.split(">>")[1] || "").trim());
                        if (!Number.isNaN(idNum)) ws.wsId = idNum;
                        ws.wsName = "";
                        refreshOnce.start();
                    } else if (line.startsWith("focusedmon>>") || line.startsWith("focusedmonv2>>")) {
                        refreshOnce.start();
                    }
                }
            }
        }

        environment: [
            "HYPRLAND_INSTANCE_SIGNATURE=" + (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? "")
        ]

        // restart on exit *after* parser+env exist
        onExited: running = true
        Component.onCompleted: running = true
    }

    // Timer used to delay a refresh after certain events
    Timer {
        id: refreshOnce
        interval: 80
        repeat: false
        onTriggered: getCurrentWS.running = true
    }
}
