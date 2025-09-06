pragma Singleton
import QtQuick
import qs.Components
import qs.Settings
import qs.Services as Services

// Clipboard service: polls wl-paste for text or image content and exposes a de-duplicated history
Item {
    id: root

    // Public state
    property var history:[]          // Array of { type: 'text'|'image', content|data, mimeType?, timestamp }
    property bool enabled: false       // Consumers toggle this when they need clipboard updates
    property bool isLoading: false

    // Internals
    property var _types: []
    property string _pendingMime: ""
    property int _maxItems: 20

    function _pushEntry(entry) {
        try {
            // Deduplicate by full payload
            var exists = history.find(function (it) {
                if (!it || it.type !== entry.type) return false;
                if (entry.type === 'text') return it.content === entry.content;
                if (entry.type === 'image') return it.data === entry.data;
                return false;
            });
            if (exists) return;
            history = [entry].concat(history).slice(0, _maxItems);
        } catch (e) { /* ignore */ }
    }

    function updateClipboardHistory() {
        if (typeProc.isLoading || textProc.isLoading || imageProc.isLoading) return;
        typeProc.isLoading = true;
        typeProc.cmd = ["wl-paste", "-l"];
        typeProc.start();
    }

    // Polling via centralized Timers service
    Connections {
        target: Services.Timers
        function onTickClipboard() {
            if (!root.enabled) return;
            root.updateClipboardHistory();
        }
    }

    // --- Processes ---
    ProcessRunner {
        id: typeProc
        property bool isLoading: false
        property string _buf: ""
        onLine: (s) => { _buf += (s + "\n") }
        onExited: (code, status) => {
            try {
                if (code === 0) {
                    var list = String(_buf).trim().split('\n').filter(function (t) { return t; });
                    root._types = list;
                    // Prefer image
                    var imageType = null;
                    for (var i = 0; i < list.length; i++) if (String(list[i]).indexOf('image/') === 0) { imageType = String(list[i]); break; }
                    if (imageType) {
                        imageProc.mimeType = imageType;
                        imageProc.cmd = ["sh", "-c", `wl-paste -n -t "${imageType}" | base64 -w 0`];
                        imageProc.start();
                    } else {
                        textProc.cmd = ["wl-paste", "-n", "--type", "text/plain"];
                        textProc.start();
                    }
                }
            } finally {
                _buf = "";
                typeProc.isLoading = false;
            }
        }
        autoStart: false
        restartOnExit: false
    }

    ProcessRunner {
        id: imageProc
        property string mimeType: ""
        property string _buf: ""
        property bool isLoading: false
        onLine: (s) => { _buf += (s + "\n") }
        onExited: (code, status) => {
            try {
                if (code === 0) {
                    var base64 = String(_buf).trim();
                    if (base64) {
                        var entry = { type: 'image', mimeType: mimeType, data: `data:${mimeType};base64,${base64}`, timestamp: Date.now() };
                        root._pushEntry(entry);
                    }
                }
            } finally {
                _buf = "";
                imageProc.isLoading = false;
            }
        }
        autoStart: false
        restartOnExit: false
    }

    ProcessRunner {
        id: textProc
        property string _buf: ""
        property bool isLoading: false
        onLine: (s) => { _buf += (s + "\n") }
        onExited: (code, status) => {
            try {
                if (code === 0) {
                    var content = String(_buf).trim();
                    if (content) {
                        var entry = { type: 'text', content: content, timestamp: Date.now() };
                        root._pushEntry(entry);
                    }
                }
            } finally {
                _buf = "";
                textProc.isLoading = false;
            }
        }
        autoStart: false
        restartOnExit: false
    }
}
