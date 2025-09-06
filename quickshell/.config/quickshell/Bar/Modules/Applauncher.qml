import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Components
import "../../Helpers/Utils.js" as Utils
import "../../Helpers/Color.js" as Color
import qs.Settings
import qs.Services as Services

import "../../Helpers" as Helpers

PanelWithOverlay {
    // Smoke test to ensure Helpers.Fuzzy is available at runtime
    // Do not dim the screen when launcher is open — keep overlay transparent
    showOverlay: false
    Component.onCompleted: {
        try {
            var res = Helpers.Fuzzy.single('term', 'terminal');
        
        } catch (e) {
            console.warn('[Applauncher] Fuzzy smoke failed:', e);
        }
    }
    // Clipboard integration via service
    readonly property var clipboardHistory: Services.Clipboard.history
    Connections { target: Services.Clipboard; function onHistoryChanged() { try { root.filterLater.restart() } catch (e) {} } }

    // Old clipboard ProcessRunners removed; use Services.Clipboard instead

    id: appLauncherPanel
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    onVisibleChanged: {
        // Enable clipboard polling only when panel is visible and >clip is active
        try { Services.Clipboard.enabled = (visible && searchField && searchField.text && searchField.text.startsWith(">clip")); } catch (e) {}
    }
    
    function isPinned(app) {
        return app && app.execString && Settings.settings.pinnedExecs.indexOf(app.execString) !== -1;
    }

    function togglePin(app) {
        if (!app || !app.execString) return;
        var arr = Settings.settings.pinnedExecs ? Settings.settings.pinnedExecs.slice() : [];
        var idx = arr.indexOf(app.execString);
        if (idx === -1) {
            arr.push(app.execString);
        } else {
            arr.splice(idx, 1);
        }
        Settings.settings.pinnedExecs = arr;
        try { root.filterLater.restart() } catch (e) {}
    }
    
    function showAt() {
        appLauncherPanelRect.showAt();
    }

    function hidePanel() {
        appLauncherPanelRect.hidePanel();
    }

    function show() {
        appLauncherPanelRect.showAt();
    }

    function dismiss() {
        appLauncherPanelRect.hidePanel();
    }

    Rectangle {
        id: appLauncherPanelRect
        implicitWidth: Theme.applauncherWidth
        implicitHeight: Theme.applauncherHeight
        color: "transparent"
        visible: parent.visible
        // Reduce rounded corners within the launcher UI (from Theme)
        property real radiusScale: Theme.applauncherCornerScale
        // Compactness scale for fonts, icons, paddings, spacings (from Theme)
        property real compactScale: Theme.applauncherCompactScale
        property bool shouldBeVisible: false
        // Search perf tuning
        property int maxResults: Theme.applauncherSearchMaxResults
        property int debounceMs: Theme.applauncherSearchDebounceMs
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        function showAt() {
            appLauncherPanel.visible = true;
            shouldBeVisible = true;
            root.selectedIndex = 0;
            root.appModel = DesktopEntries.applications.values;
            // Precompute base (non-plugin) app list once per open for responsiveness
            try {
                root.baseApps = root.appModel.slice().filter(function(a){
                    if (isAudioPluginEntry(a)) return false;
                    if (Theme.applauncherFilterConsoleApps && isConsoleAppEntry(a)) return false;
                    return true;
                });
            } catch (e) { root.baseApps = root.appModel.slice(); }
            try { root.filterLater.restart() } catch (e) {}
        }

        function hidePanel() {
            shouldBeVisible = false;
            searchField.text = "";
            root.selectedIndex = 0;
        }

        // Prevent closing when clicking in the panel bg
        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            id: root
            width: Theme.applauncherWidth
            height: Theme.applauncherHeight
            x: (parent.width - width) / 2
            // Panel background should look like the bar: slightly translucent background (from Theme)
            color: Color.withAlpha(Theme.background, Theme.applauncherBgAlpha)
            radius: Math.round(Theme.applauncherCornerRadius * appLauncherPanelRect.radiusScale)
            border.color: "transparent"
            border.width: 0
            layer.enabled: false

            property var appModel: DesktopEntries.applications.values
            // Cache of non-plugin applications for faster incremental filtering
            property var baseApps: []
            property var filteredApps: []
            property int selectedIndex: 0
            // Bottom-docked slide + scale
            property int bottomMargin: Theme.applauncherBottomMargin
            property int targetY: Utils.clamp(parent.height - height - bottomMargin, 0, parent.height)
            property int offscreenYBottom: parent.height + Theme.applauncherOffscreenShift
            y: appLauncherPanelRect.shouldBeVisible ? targetY : offscreenYBottom
            Behavior on y { enabled: !Settings.settings.applauncherDisableAnimations; NumberFadeBehavior { duration: Math.round(Theme.applauncherEnterAnimMs / 4); easing.type: Theme.uiEasingQuick } }
            scale: appLauncherPanelRect.shouldBeVisible ? 1 : 0
            Behavior on scale { enabled: !Settings.settings.applauncherDisableAnimations; NumberFadeBehavior { duration: Math.round(Theme.applauncherScaleAnimMs / 4); easing.type: Theme.uiEasingInOut } }
            onScaleChanged: {
                if (scale === 0 && !appLauncherPanelRect.shouldBeVisible) {
                    appLauncherPanel.visible = false;
                }
                if (scale === 1 && appLauncherPanelRect.shouldBeVisible) {
                    // Focus after the panel is fully shown to avoid Wayland textinput focus race warnings
                    focusLater.start();
                }
            }

            function isMathExpression(str) {
                return /^[-+*/().0-9\s]+$/.test(str);
            }

            function safeEval(expr) {
                try {
                    return Function('return (' + expr + ')')();
                } catch (e) {
                    return undefined;
                }
            }

            function isAudioPluginEntry(app) {
                try {
                    const n = String(app.name || '').toLowerCase();
                    const c = String(app.comment || app.genericName || '').toLowerCase();
                    const cats = String(app.categories || app.category || '').toLowerCase();
                    const ex = String(app.execString || app.exec || '').toLowerCase();
                    function m(s,re){ return re.test(s); }
                    const re = /(\b(vst|vst2|vst3|lv2|ladspa|dssi|clap|lsp|audiounit|audio-unit|au|vamp|plugin)\b)/;
                    if (m(n,re) || m(c,re) || m(cats,re) || m(ex,re)) return true;
                    if (ex.indexOf('/.vst') !== -1 || ex.indexOf('/vst3') !== -1 || ex.indexOf('/.lv2') !== -1 || ex.indexOf('/.ladspa') !== -1 || ex.indexOf('/.clap') !== -1) return true;
                } catch (e) {}
                return false;
            }

            function isConsoleAppEntry(app) {
                try {
                    // Standard desktop entry flag
                    if (app.runInTerminal === true || String(app.terminal || '').toLowerCase() === 'true') return true;
                    const n = String(app.name || '').toLowerCase();
                    const ex = String(app.execString || app.exec || '').toLowerCase();
                    // Common console-only tools that provide .desktop files
                    const consoleNames = ['yazi','ranger','lf','nnn','mc','htop','btop','bashtop','btm','nvim','neovim','vim','nano','tmux','xplr','zellij'];
                    for (var i = 0; i < consoleNames.length; ++i) {
                        const t = consoleNames[i];
                        if (n === t || n.indexOf(t) !== -1 || ex.startsWith(t + ' ') || ex.indexOf('/' + t + ' ') !== -1 || ex === t) return true;
                    }
                } catch (e) {}
                return false;
            }

            function likelyMissingIcon(app) {
                try {
                    if (app.isCalculator || app.isClipboard || app.isCommand) return false;
                    const icon = String(app.icon || '').trim();
                    if (!icon) return true;
                    if (icon === 'application-x-executable') return true;
                } catch (e) {}
                return false;
            }

            function updateFilterNow() {
                var query = searchField.text ? searchField.text.toLowerCase() : "";
                var apps = (root.baseApps && root.baseApps.length) ? root.baseApps : root.appModel.slice();
                var results = [];
                

                if (query === ">") {
                    results.push({
                        isCommand: true,
                        name: ">calc",
                        content: "Calculator - evaluate mathematical expressions",
                        icon: "calculate",
                        execute: function() {
                            searchField.text = ">calc ";
                            searchField.cursorPosition = searchField.text.length;
                        }
                    });
                    
                    results.push({
                        isCommand: true,
                        name: ">clip",
                        content: "Clipboard history - browse and restore clipboard items",
                        icon: "content_paste",
                        execute: function() {
                            searchField.text = ">clip ";
                            searchField.cursorPosition = searchField.text.length;
                        }
                    });
                    
                    root.filteredApps = results;
                    return;
                }
                

                if (query.startsWith(">clip")) {
                    Services.Clipboard.enabled = appLauncherPanel.visible;
                    const searchTerm = query.slice(5).trim();
                    
                    clipboardHistory.forEach(function(clip, index) {
                        let searchContent = clip.type === 'image' ? clip.mimeType : (clip.content || clip);
                            
                        if (!searchTerm || searchContent.toLowerCase().includes(searchTerm)) {
                            let entry;
                            if (clip.type === 'image') {
                                entry = {
                                    isClipboard: true,
                                    name: "Image from " + new Date(clip.timestamp).toLocaleTimeString(),
                                    content: "Image: " + clip.mimeType,
                                    icon: "image",
                                    type: 'image',
                                    data: clip.data,
                                    execute: function() {
                                        const base64Data = clip.data.split(',')[1];
                                        Quickshell.execDetached(["sh", "-c", `echo '${base64Data}' | base64 -d | wl-copy -t '${clip.mimeType}'`]);
                                    }
                                };
                            } else {
                                const textContent = clip.content || clip;
                                let displayContent = textContent;
                                let previewContent = "";
                                
                                // Clean up whitespace for display
                                displayContent = displayContent.replace(/\s+/g, ' ').trim();
                                
                                // Truncate long content and show preview
                                if (displayContent.length > 50) {
                                    previewContent = displayContent;
                                    // Show first line or first 50 characters as title
                                    displayContent = displayContent.split('\n')[0].substring(0, 50) + "...";
                                }
                                
                                entry = {
                                    isClipboard: true,
                                    name: displayContent,
                                    content: previewContent || textContent,
                                    icon: "content_paste",
                                    execute: function() {
                                        Quickshell.execDetached(["sh", "-c", "echo -n '" + textContent.replace(/'/g, "'\\''") + "' | wl-copy"]);
                                    }
                                };
                            }
                            results.push(entry);
                        }
                    });
                    
                    if (results.length === 0) {
                        results.push({
                            isClipboard: true,
                            name: "No clipboard history",
                            content: "No matching clipboard entries found",
                            icon: "content_paste_off"
                        });
                    }
                    
                    root.filteredApps = results;
                    return;
                }
                

                if (query.startsWith(">calc")) {
                    var expr = searchField.text.slice(5).trim();
                    if (expr && isMathExpression(expr)) {
                        var value = safeEval(expr);
                        if (value !== undefined && value !== null && value !== "") {
                            results.push({
                                isCalculator: true,
                                name: `Calculator: ${expr} = ${value}`,
                                result: value,
                                expr: expr,
                                icon: "calculate"
                            });
                        }
                    }
                    
    
                    var pinned = [];
                    var unpinned = [];
                    for (var i = 0; i < results.length; ++i) {
                        var app = results[i];
                        if (app.execString && Settings.settings.pinnedExecs.indexOf(app.execString) !== -1) {
                            pinned.push(app);
                        } else {
                            unpinned.push(app);
                        }
                    }
                    // Sort pinned apps alphabetically for consistent display
                    pinned.sort(function(a, b) {
                        return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
                    });
                    root.filteredApps = pinned.concat(unpinned);
                    root.selectedIndex = 0;
                    return;
                }
                if (!query) {
                    results = results.concat(apps.sort(function (a, b) {
                        return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
                    }));
                } else {
                    // Fast path: prefix/substring matches first
                    var q = query;
                    var prelim = [];
                    function pushIfMatch(app) {
                        var n = String(app.name||"").toLowerCase();
                        var c = String(app.comment||"").toLowerCase();
                        var g = String(app.genericName||"").toLowerCase();
                        if (n.startsWith(q) || n.indexOf(q) !== -1 || c.indexOf(q) !== -1 || g.indexOf(q) !== -1) prelim.push(app);
                    }
                    for (var i = 0; i < apps.length && prelim.length < appLauncherPanelRect.maxResults; ++i) pushIfMatch(apps[i]);
                    results = results.concat(prelim);
                    // If still under limit, use fuzzysort for the rest
                    if (results.length < appLauncherPanelRect.maxResults) {
                        var fuzzyResults = Helpers.Fuzzy.go(query, apps, { keys: ["name","comment","genericName"], limit: appLauncherPanelRect.maxResults });
                        for (var j = 0; j < fuzzyResults.length && results.length < appLauncherPanelRect.maxResults; ++j) results.push(fuzzyResults[j].obj);
                    }
                }

                // Icons are removed from launcher UI; skip icon-based filtering entirely

                var pinned = [];
                var unpinned = [];
                for (var i = 0; i < results.length; ++i) {
                    var app = results[i];
                    // Exclude console-only apps from final list too (defense-in-depth when baseApps not set)
                    if (Theme.applauncherFilterConsoleApps && isConsoleAppEntry(app)) continue;
                    if (app.execString && Settings.settings.pinnedExecs.indexOf(app.execString) !== -1) {
                        pinned.push(app);
                    } else {
                        unpinned.push(app);
                    }
                }
                // Sort pinned alphabetically
                pinned.sort(function(a, b) {
                    return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
                });
                root.filteredApps = pinned.concat(unpinned);
                root.selectedIndex = 0;
            }

            // Debounced filtering trigger
            Timer { id: filterLater; interval: Math.max(0, appLauncherPanelRect.debounceMs); repeat: false; onTriggered: root.updateFilterNow() }

            function selectNext() {
                if (filteredApps.length > 0)
                    selectedIndex = Utils.clamp(selectedIndex + 1, 0, filteredApps.length - 1);
            }

            function selectPrev() {
                if (filteredApps.length > 0)
                    selectedIndex = Utils.clamp(selectedIndex - 1, 0, filteredApps.length - 1);
            }

            function activateSelected() {
                if (filteredApps.length === 0)
                    return;

                var modelData = filteredApps[selectedIndex];
                const termEmu = Quickshell.env("TERMINAL") || Quickshell.env("TERM_PROGRAM") || "";

                if (modelData.isCommand) {
                    modelData.execute();
                    return;
                } else if (modelData.runInTerminal && termEmu){
                    Quickshell.execDetached([termEmu, "-e", modelData.execString.trim()]);
                } else if (modelData.execute) {
                    modelData.execute();
                } else {
                    var execCmd = modelData.execString || modelData.exec || "";
                    if (execCmd) {
                        execCmd = execCmd.replace(/\s?%[fFuUdDnNiCkvm]/g, '');
                        Quickshell.execDetached(["sh", "-c", execCmd.trim()]);
                    }
                }

                appLauncherPanel.hidePanel();
                searchField.text = "";
            }

            Component.onCompleted: updateFilterNow()

            RowLayout {
                anchors.fill: parent
                anchors.margins: Math.round(Theme.uiSpacingXSmall * Theme.scale(Screen) * appLauncherPanelRect.compactScale)
                spacing: Math.round(Theme.uiSpacingSmall * appLauncherPanelRect.compactScale)

        
                Rectangle {
                    id: previewPanel
                    Layout.preferredWidth: Math.round(Theme.applauncherPreviewWidth * Theme.scale(Screen))
                    Layout.maximumHeight: Math.round(parent.height * Theme.applauncherPreviewMaxHeightRatio)
                    Layout.fillHeight: true
                    color: "transparent"
                    radius: Theme.panelOverlayRadius
                    visible: false

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Math.round(Theme.applauncherPreviewInnerMargin * Theme.scale(Screen))
                        color: "transparent"
                        clip: true

                        Image {
                            id: previewImage
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                            smooth: true
                        }
                    }
                }

        
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.uiSpacingLarge

            
                    Rectangle {
                        id: searchBar
                        color: "transparent"
                        radius: Math.round(Theme.panelOverlayRadius * appLauncherPanelRect.radiusScale)
                        height: Math.round(Theme.uiControlHeight * appLauncherPanelRect.compactScale)
                        Layout.fillWidth: true
                        border.color: "transparent"
                        border.width: 0

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Math.round(Theme.uiSpacingSmall * appLauncherPanelRect.compactScale)
                        anchors.rightMargin: Math.round(Theme.uiSpacingSmall * appLauncherPanelRect.compactScale)
                        spacing: Math.round(Theme.uiSpacingXSmall * appLauncherPanelRect.compactScale)

                            TextField {
                                id: searchField
                                placeholderText: "Search apps..."
                                color: Theme.textPrimary
                                placeholderTextColor: Theme.textSecondary
                                background: null
                                font.family: Theme.fontFamily
                                font.pixelSize: Math.round(Theme.fontSizeBody * Theme.scale(screen) * appLauncherPanelRect.compactScale)
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                onTextChanged: {
                                    try { Services.Clipboard.enabled = (appLauncherPanel.visible && searchField.text.startsWith(">clip")); } catch (e) {}
                                    const t = searchField.text || "";
                                    if (t === ">" || t.startsWith(">clip") || t.startsWith(">calc") || t.length <= 2) {
                                        root.updateFilterNow();
                                    } else {
                                        filterLater.interval = Math.max(0, appLauncherPanelRect.debounceMs);
                                        filterLater.restart();
                                    }
                                }
                                selectedTextColor: Theme.onAccent
                                selectionColor: Theme.accentPrimary
                                padding: Theme.uiSpacingNone
                                verticalAlignment: TextInput.AlignVCenter
                                leftPadding: Theme.uiSpacingNone
                                rightPadding: Theme.uiSpacingNone
                                topPadding: Theme.uiSpacingNone
                                bottomPadding: Theme.uiSpacingNone
                                font.bold: true
                                Component.onCompleted: contentItem.cursorColor = Theme.textPrimary
                                onActiveFocusChanged: contentItem.cursorColor = Theme.textPrimary

                                // Emacs-style editing/navigation helpers
                                property string killBuffer: ""
                                property bool lastWasKill: false
                                function isWordChar(ch) { return /[A-Za-z0-9_]/.test(ch); }
                                function nextWordPos(pos) {
                                    var s = text; var L = s.length; var i = Math.max(0, Math.min(L, pos));
                                    if (i >= L) return L;
                                    if (isWordChar(s[i])) { while (i < L && isWordChar(s[i])) i++; }
                                    else { while (i < L && !isWordChar(s[i])) i++; while (i < L && isWordChar(s[i])) i++; }
                                    return i;
                                }
                                function prevWordPos(pos) {
                                    var s = text; var i = Math.max(0, Math.min(s.length, pos));
                                    if (i <= 0) return 0;
                                    if (isWordChar(s[i-1])) { while (i > 0 && isWordChar(s[i-1])) i--; }
                                    else { while (i > 0 && !isWordChar(s[i-1])) i--; while (i > 0 && isWordChar(s[i-1])) i--; }
                                    return i;
                                }
                                function insertAtCursor(str) {
                                    var cp = searchField.cursorPosition; var s = searchField.text;
                                    searchField.text = s.slice(0, cp) + str + s.slice(cp);
                                    searchField.cursorPosition = cp + String(str).length;
                                }
                                function killRange(startPos, endPos) {
                                    var s = searchField.text; var a = Math.max(0, Math.min(s.length, startPos)); var b = Math.max(0, Math.min(s.length, endPos));
                                    if (b < a) { var tmp = a; a = b; b = tmp; }
                                    var killed = s.slice(a, b);
                                    if (searchField.lastWasKill) searchField.killBuffer += killed; else searchField.killBuffer = killed;
                                    searchField.text = s.slice(0, a) + s.slice(b);
                                    searchField.cursorPosition = a;
                                    searchField.lastWasKill = true;
                                }

                                Keys.onPressed: function(event) {
                                    // reset kill chain by default on any key; will set true for kill operations
                                    searchField.lastWasKill = false;
                                    // Control-based navigation
                                    if (event.modifiers & Qt.ControlModifier) {
                                        switch (event.key) {
                                            case Qt.Key_N: root.selectNext(); event.accepted = true; return;
                                            case Qt.Key_P: root.selectPrev(); event.accepted = true; return;
                                            case Qt.Key_G: appLauncherPanel.hidePanel(); event.accepted = true; return;
                                            case Qt.Key_A: searchField.cursorPosition = 0; event.accepted = true; return;
                                            case Qt.Key_E: searchField.cursorPosition = searchField.text.length; event.accepted = true; return;
                                            case Qt.Key_K: {
                                                // kill to end of line (single-line)
                                                var cp = searchField.cursorPosition;
                                                killRange(cp, searchField.text.length);
                                                event.accepted = true; return;
                                            }
                                            case Qt.Key_U: {
                                                // kill to beginning of line
                                                var cp2 = searchField.cursorPosition;
                                                killRange(0, cp2);
                                                event.accepted = true; return;
                                            }
                                            case Qt.Key_B: searchField.cursorPosition = Math.max(0, searchField.cursorPosition - 1); event.accepted = true; return;
                                            case Qt.Key_F: searchField.cursorPosition = Math.min(searchField.text.length, searchField.cursorPosition + 1); event.accepted = true; return;
                                            case Qt.Key_W: {
                                                var p = prevWordPos(searchField.cursorPosition);
                                                killRange(p, searchField.cursorPosition);
                                                event.accepted = true; return;
                                            }
                                            case Qt.Key_Y: {
                                                if (searchField.killBuffer && searchField.killBuffer.length > 0) {
                                                    insertAtCursor(searchField.killBuffer);
                                                    event.accepted = true; return;
                                                }
                                                if (searchField.paste) { searchField.paste(); event.accepted = true; return; }
                                                break;
                                            }
                                            case Qt.Key_D: { // delete char under cursor
                                                var cp = searchField.cursorPosition; var s = searchField.text;
                                                if (cp < s.length) { searchField.text = s.slice(0, cp) + s.slice(cp+1); }
                                                event.accepted = true; return;
                                            }
                                        }
                                    }
                                    // Alt-based word navigation
                                    if (event.modifiers & Qt.AltModifier) {
                                        switch (event.key) {
                                            case Qt.Key_F: searchField.cursorPosition = nextWordPos(searchField.cursorPosition); event.accepted = true; return;
                                            case Qt.Key_B: searchField.cursorPosition = prevWordPos(searchField.cursorPosition); event.accepted = true; return;
                                            case Qt.Key_D: { var n = nextWordPos(searchField.cursorPosition); killRange(searchField.cursorPosition, n); event.accepted = true; return; }
                                            case Qt.Key_Backspace: { var p2 = prevWordPos(searchField.cursorPosition); killRange(p2, searchField.cursorPosition); event.accepted = true; return; }
                                        }
                                    }
                                }

                                Keys.onDownPressed: root.selectNext()
                                Keys.onUpPressed: root.selectPrev()
                                Keys.onEnterPressed: root.activateSelected()
                                Keys.onReturnPressed: root.activateSelected()
                                Keys.onEscapePressed: appLauncherPanel.hidePanel()
                            }
                        }

                        Behavior on border.color { enabled: false; ColorFadeBehavior {} }
                        Behavior on border.width { enabled: false; NumberFadeBehavior {} }
                    }

            
                    Rectangle {
                        color: "transparent"
                        radius: Math.round(Theme.panelOverlayRadius * appLauncherPanelRect.radiusScale)
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        // Inner padding based on UI theme padding
                        property int innerPadding: Math.round(Theme.uiSpacingXSmall * Theme.scale(Screen) * appLauncherPanelRect.compactScale)

                        ListView {
                            id: appList
                            anchors.fill: parent
                            anchors.margins: parent.innerPadding
                        spacing: Math.round(Theme.uiSpacingXSmall * appLauncherPanelRect.compactScale)
                            model: root.filteredApps
                            currentIndex: root.selectedIndex
                            delegate: Item {
                                id: appDelegate
                                width: appList.width
                                // Hide entries without icons by collapsing height
                                height: (visible)
                                        ? ((modelData.isClipboard || modelData.isCommand)
                                            ? Math.round(Theme.applauncherListItemHeightLarge * Theme.scale(Screen) * appLauncherPanelRect.compactScale * 0.85)
                                            : Math.round(Theme.applauncherListItemHeight * Theme.scale(Screen) * appLauncherPanelRect.compactScale * 0.85))
                                        : 0
                                property bool hovered: mouseArea.containsMouse
                                property bool isSelected: index === root.selectedIndex

                                Rectangle {
                                    anchors.fill: parent
                                    color: isSelected ? Theme.accentPrimary
                                         : hovered ? Theme.overlayWeak
                                         : (appLauncherPanel.isPinned(modelData) ? Theme.surfaceVariant : "transparent")
                                    radius: Math.round(Theme.cornerRadiusLarge * appLauncherPanelRect.radiusScale)
                                    border.color: "transparent"
                                    border.width: 0

                                    Behavior on color { enabled: !Settings.settings.applauncherDisableAnimations; ColorFadeBehavior {} }
                                    Behavior on border.color { enabled: false; ColorFadeBehavior {} }
                                    Behavior on border.width { enabled: false; NumberFadeBehavior {} }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Math.round(Theme.uiSpacingSmall * appLauncherPanelRect.compactScale)
                                    anchors.rightMargin: Math.round(Theme.uiSpacingSmall * appLauncherPanelRect.compactScale)
                                    spacing: Math.round(Theme.uiSpacingSmall * appLauncherPanelRect.compactScale)
                                    // No icon cell — compact text-only layout

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Math.round(Theme.uiGapTiny * appLauncherPanelRect.compactScale)

                                        Text {
                                            text: modelData.name
                                            color: (hovered || isSelected) ? Theme.onAccent : (appLauncherPanel.isPinned(modelData) ? Theme.textPrimary : Theme.textPrimary)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Math.round(Theme.fontSizeSmall * Theme.scale(screen) * appLauncherPanelRect.compactScale)
                                            font.bold: hovered || isSelected
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: modelData.isCalculator ? (modelData.expr + " = " + modelData.result) : 
                                                  modelData.isClipboard ? modelData.content :
                                                  modelData.isCommand ? modelData.content :
                                                  (modelData.comment || modelData.genericName || "No description available")
                                            color: (hovered || isSelected) ? Theme.onAccent : (appLauncherPanel.isPinned(modelData) ? Theme.textSecondary : Theme.textSecondary)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Math.round(Theme.fontSizeCaption * Theme.scale(screen) * appLauncherPanelRect.compactScale)
                                            font.italic: !(modelData.comment || modelData.genericName)
                                            opacity: modelData.isClipboard ? Theme.applauncherClipboardEntryOpacity : modelData.isCommand ? Theme.applauncherCommandEntryOpacity : ((modelData.comment || modelData.genericName) ? 1.0 : Theme.applauncherNoMetaOpacity)
                                            elide: Text.ElideRight
                                            maximumLineCount: (modelData.isClipboard || modelData.isCommand) ? 2 : 1
                                            wrapMode: (modelData.isClipboard || modelData.isCommand) ? Text.WordWrap : Text.NoWrap
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: (modelData.isClipboard || modelData.isCommand) ? implicitHeight : contentHeight
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    MaterialIcon {
                                        icon: modelData.isCalculator ? "content_copy" : "chevron_right"
                                        size: Math.round(Theme.panelIconSizeSmall * Theme.scale(screen) * appLauncherPanelRect.compactScale)
                                        color: (hovered || isSelected)
                                            ? Theme.onAccent
                                            : (appLauncherPanel.isPinned(modelData) ? Theme.textPrimary : Theme.textSecondary)
                                        Layout.rightMargin: Theme.panelRowSpacingSmall
                                    }

            
                                    Item { width: Theme.panelRowSpacingSmall; height: Theme.uiGapTiny }
                                }
                                // All entries visible; icons removed
                                visible: true

                                Rectangle {
                                    id: ripple
                                    anchors.fill: parent
                                    color: Theme.onAccent
                                    opacity: 0.0
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: {

                                        if (pinArea.containsMouse) return;
                                        if (mouse.button === Qt.RightButton) {
                                            appLauncherPanel.togglePin(modelData);
                                            return;
                                        }
                                        if (Settings.settings.applauncherDisableAnimations) {
                                            ripple.opacity = 0.0;
                                        } else {
                                            ripple.opacity = Theme.uiRippleOpacity;
                                            rippleNumberAnimation.start();
                                        }
                                        root.selectedIndex = index;
                                        root.activateSelected();
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: ripple.opacity = Settings.settings.applauncherDisableAnimations ? 0.0 : Theme.uiRippleOpacity
                                    onReleased: ripple.opacity = 0.0
                                }

                                    RippleFadeBehavior { id: rippleNumberAnimation; target: ripple; property: "opacity"; to: 0.0 }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: Theme.uiSeparatorThickness
                                    radius: Math.round(Theme.uiSeparatorRadius * appLauncherPanelRect.radiusScale)
                                    color: Theme.borderSubtle
                                    opacity: index === appList.count - 1 ? 0 : 0.4
                                }

        
                                Item {
                                    id: pinArea
                                    width: Math.round(Theme.panelIconSize * Theme.scale(Screen) * appLauncherPanelRect.compactScale); height: Math.round(Theme.panelIconSize * Theme.scale(Screen) * appLauncherPanelRect.compactScale)
                                    z: 100
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        preventStealing: true
                                        z: 100
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        propagateComposedEvents: false
                                        onClicked: {
                                            appLauncherPanel.togglePin(modelData);
                                            event.accepted = true;
                                        }
                                    }

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        icon: "star"
                                        size: Math.round(Theme.fontSizeSmall * Theme.scale(screen) * appLauncherPanelRect.compactScale)
                                        color: (parent.MouseArea.containsMouse || hovered || isSelected)
                                            ? Theme.onAccent
                                            : (appLauncherPanel.isPinned(modelData) ? Theme.textPrimary : Theme.textDisabled)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Defer focusing the search field to avoid Wayland textinput focus warnings
        Timer {
            id: focusLater
            interval: 0
            repeat: false
            running: false
            onTriggered: searchField.forceActiveFocus()
        }
    }
}
