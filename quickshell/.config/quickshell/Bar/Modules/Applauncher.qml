import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Components
import "../../Helpers/Utils.js" as Utils
import qs.Settings

import "../../Helpers" as Helpers

PanelWithOverlay {
    // Smoke test to ensure Helpers.Fuzzy is available at runtime
    Component.onCompleted: {
        try {
            var res = Helpers.Fuzzy.single('term', 'terminal');
        
        } catch (e) {
            console.warn('[Applauncher] Fuzzy smoke failed:', e);
        }
    }
    Timer {
        id: clipboardTimer
        interval: (typeof Theme !== 'undefined' && Theme.applauncherClipboardPollMs !== undefined)
                  ? Theme.applauncherClipboardPollMs : 1000
        repeat: true
        running: appLauncherPanel.visible && searchField.text.startsWith(">clip")
        onTriggered: {
            updateClipboardHistory();
        }
    }

    property var clipboardHistory: []
    property bool clipboardInitialized: false

    Process {
        id: clipboardTypeProcess
        property bool isLoading: false
        property var currentTypes: []

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                currentTypes = String(stdout.text).trim().split('\n').filter(t => t);

                const imageType = currentTypes.find(t => t.startsWith('image/'));
                if (imageType) {
                    clipboardImageProcess.mimeType = imageType;
                    clipboardImageProcess.command = ["sh", "-c", `wl-paste -n -t "${imageType}" | base64 -w 0`];
                    clipboardImageProcess.running = true;
                } else {

                    clipboardHistoryProcess.command = ["wl-paste", "-n", "--type", "text/plain"];
                    clipboardHistoryProcess.running = true;
                }
            } else {

                clipboardTypeProcess.isLoading = false;
            }
        }

        stdout: StdioCollector {}
    }

    Process {
        id: clipboardImageProcess
        property string mimeType: ""

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                const base64 = stdout.text.trim();
                if (base64) {
                    const entry = {
                        type: 'image',
                        mimeType: mimeType,
                        data: `data:${mimeType};base64,${base64}`,
                        timestamp: new Date().getTime()
                    };
                    
    
                    const exists = clipboardHistory.find(item => 
                        item.type === 'image' && item.data === entry.data
                    );

                    if (!exists) {
                        clipboardHistory = [entry, ...clipboardHistory].slice(0, 20);
                        root.updateFilter();
                    }
                }
            }
            
            if (!clipboardHistoryProcess.isLoading) {
                clipboardInitialized = true;
            }
            clipboardTypeProcess.isLoading = false;
        }

        stdout: StdioCollector {}
    }

    Process {
        id: clipboardHistoryProcess
        property bool isLoading: false

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                const content = String(stdout.text).trim();
                if (content && !content.startsWith("vscode-file://")) {
                    const entry = {
                        type: 'text',
                        content: content,
                        timestamp: new Date().getTime()
                    };

    
                    const exists = clipboardHistory.find(item => {
                        if (item.type === 'text') {
                            return item.content === content;
                        }
        
                        return item === content;
                    });

                    if (!exists) {
        
                        const newHistory = clipboardHistory.map(item => {
                            if (typeof item === 'string') {
                                return {
                                    type: 'text',
                                    content: item,
                                    timestamp: new Date().getTime()
                                };
                            }
                            return item;
                        });
                        
                        clipboardHistory = [entry, ...newHistory].slice(0, 20);
                    }
                }
            } else {

                clipboardHistoryProcess.isLoading = false;
            }
            clipboardInitialized = true;
            clipboardTypeProcess.isLoading = false;
            root.updateFilter();
        }

        stdout: StdioCollector {}
    }

    

    function updateClipboardHistory() {
        if (!clipboardTypeProcess.isLoading && !clipboardHistoryProcess.isLoading) {
            clipboardTypeProcess.isLoading = true;
            clipboardTypeProcess.command = ["wl-paste", "-l"];
            clipboardTypeProcess.running = true;
        }
    }

    id: appLauncherPanel
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    
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
        root.updateFilter();
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
        property bool shouldBeVisible: false
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        function showAt() {
            appLauncherPanel.visible = true;
            shouldBeVisible = true;
            searchField.forceActiveFocus();
            root.selectedIndex = 0;
            root.appModel = DesktopEntries.applications.values;
            root.updateFilter();
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
            color: Theme.background
            bottomLeftRadius: Theme.applauncherCornerRadius
            bottomRightRadius: Theme.applauncherCornerRadius

            property var appModel: DesktopEntries.applications.values
            property var filteredApps: []
            property int selectedIndex: 0
            // Bottom-docked animation: slide from offscreen bottom to bottom with small margin
            property int bottomMargin: Theme.applauncherBottomMargin
            property int targetY: Utils.clamp(parent.height - height - bottomMargin, 0, parent.height)
            property int offscreenYBottom: parent.height + Theme.applauncherOffscreenShift
            y: appLauncherPanelRect.shouldBeVisible ? targetY : offscreenYBottom
            Behavior on y {
                NumberAnimation {
                    duration: Theme.applauncherEnterAnimMs
                    easing.type: Theme.uiEasingQuick
                }
            }
            scale: appLauncherPanelRect.shouldBeVisible ? 1 : 0
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.applauncherScaleAnimMs
                    easing.type: Theme.uiEasingInOut
                }
            }
            onScaleChanged: {
                if (scale === 0 && !appLauncherPanelRect.shouldBeVisible) {
                    appLauncherPanel.visible = false;
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

            function updateFilter() {
                var query = searchField.text ? searchField.text.toLowerCase() : "";
                var apps = root.appModel.slice();
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
                    if (!clipboardInitialized) {
                        updateClipboardHistory();
                    }
                    const searchTerm = query.slice(5).trim();
                    
                    clipboardHistory.forEach(function(clip, index) {
                        let searchContent = clip.type === 'image' ? 
                            clip.mimeType : 
                            clip.content || clip;  // Support both new object format and old string format
                            
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
                                        // Convert base64 image data back to binary and copy to clipboard
                                        const base64Data = clip.data.split(',')[1];
                                        clipboardTypeProcess.command = ["sh", "-c", `echo '${base64Data}' | base64 -d | wl-copy -t '${clip.mimeType}'`];
                                        clipboardTypeProcess.running = true;
                                    }
                                };
                            } else {
                                const textContent = clip.content || clip;  // Support both new object format and old string format
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
                    var fuzzyResults = Helpers.Fuzzy.go(query, apps, {
                        keys: ["name", "comment", "genericName"]
                    });
                    results = results.concat(fuzzyResults.map(function (r) {
                        return r.obj;
                    }));
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
                // Sort pinned alphabetically
                pinned.sort(function(a, b) {
                    return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
                });
                root.filteredApps = pinned.concat(unpinned);
                root.selectedIndex = 0;
            }

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

            Component.onCompleted: updateFilter()

            RowLayout {
                anchors.fill: parent
                anchors.margins: Math.round(Theme.applauncherContentMargin * Theme.scale(Screen))
                spacing: Theme.uiSpacingLarge

        
                Rectangle {
                    id: previewPanel
                    Layout.preferredWidth: Math.round(Theme.applauncherPreviewWidth * Theme.scale(Screen))
                    Layout.maximumHeight: Math.round(parent.height * Theme.applauncherPreviewMaxHeightRatio)
                    Layout.fillHeight: true
                    color: Theme.surface
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
                        color: Theme.surfaceVariant
                        radius: Theme.panelOverlayRadius
                        height: Theme.uiControlHeight
                        Layout.fillWidth: true
                        border.color: searchField.activeFocus ? Theme.accentPrimary : Theme.outline
                        border.width: searchField.activeFocus ? 2 : 1

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Theme.uiPaddingMedium
                            anchors.rightMargin: Theme.uiPaddingMedium
                            spacing: Theme.uiSpacingSmall

                            MaterialIcon {
                                icon: "search"
                                size: Math.round(Theme.panelIconSizeSmall * Theme.scale(screen))
                                color: searchField.activeFocus ? Theme.accentPrimary : Theme.textSecondary
                                Layout.alignment: Qt.AlignVCenter
                            }

                            TextField {
                                id: searchField
                                placeholderText: "Search apps..."
                                color: Theme.textPrimary
                                placeholderTextColor: Theme.textSecondary
                                background: null
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeBody * Theme.scale(screen)
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                onTextChanged: root.updateFilter()
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

                                Keys.onDownPressed: root.selectNext()
                                Keys.onUpPressed: root.selectPrev()
                                Keys.onEnterPressed: root.activateSelected()
                                Keys.onReturnPressed: root.activateSelected()
                                Keys.onEscapePressed: appLauncherPanel.hidePanel()
                            }
                        }

                        Behavior on border.color { ColorAnimation { duration: Theme.uiAnimQuickMs; easing.type: Theme.uiEasingQuick } }
                        Behavior on border.width { NumberAnimation { duration: Theme.uiAnimQuickMs; easing.type: Theme.uiEasingQuick } }
                    }

            
                    Rectangle {
                        color: Theme.surface
                        radius: Theme.panelOverlayRadius
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        // Inner padding based on UI theme padding
                        property int innerPadding: Math.round(Theme.uiPaddingMedium * Theme.scale(Screen))

                        ListView {
                            id: appList
                            anchors.fill: parent
                            anchors.margins: parent.innerPadding
                        spacing: Theme.uiSpacingXSmall
                            model: root.filteredApps
                            currentIndex: root.selectedIndex
                            delegate: Item {
                                id: appDelegate
                                width: appList.width
                                height: (modelData.isClipboard || modelData.isCommand)
                                        ? Math.round(Theme.applauncherListItemHeightLarge * Theme.scale(Screen))
                                        : Math.round(Theme.applauncherListItemHeight * Theme.scale(Screen))
                                property bool hovered: mouseArea.containsMouse
                                property bool isSelected: index === root.selectedIndex

                                Rectangle {
                                    anchors.fill: parent
                                    color: (hovered || isSelected)
                                        ? Theme.accentPrimary
                                        : (appLauncherPanel.isPinned(modelData) ? Theme.surfaceVariant : "transparent")
                                    radius: Theme.cornerRadiusLarge
                                    border.color: appLauncherPanel.isPinned(modelData)
                                        ? "transparent"
                                        : (hovered || isSelected ? Theme.accentPrimary : "transparent")
                                    border.width: appLauncherPanel.isPinned(modelData) ? 0 : (hovered || isSelected ? 2 : 0)

                                    Behavior on color { ColorAnimation { duration: Theme.uiAnimQuickMs; easing.type: Theme.uiEasingQuick } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.uiAnimQuickMs; easing.type: Theme.uiEasingQuick } }
                                    Behavior on border.width { NumberAnimation { duration: Theme.uiAnimQuickMs; easing.type: Theme.uiEasingQuick } }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: Theme.uiSpacingSmall
                                    anchors.rightMargin: Theme.uiSpacingSmall
                                    spacing: Theme.uiSpacingSmall

                                    Item {
                                        width: Math.round(Theme.panelIconSize * Theme.scale(Screen))
                                        height: Math.round(Theme.panelIconSize * Theme.scale(Screen))
                                        property bool iconLoaded: !modelData.isCalculator && !modelData.isClipboard && !modelData.isCommand && iconImg.status === Image.Ready && iconImg.source !== "" && iconImg.status !== Image.Error
                                        
                                        Image {
                                            id: clipboardImage
                                            anchors.fill: parent
                                            visible: modelData.type === 'image'
                                            source: modelData.data || ""
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            cache: true

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                propagateComposedEvents: true
                                                onContainsMouseChanged: {
                                                    if (containsMouse && modelData.type === 'image') {
                                                        previewImage.source = modelData.data;
                                                        previewPanel.visible = true;
                                                    } else {
                                                        previewPanel.visible = false;
                                                    }
                                                }
                                                onMouseXChanged: mouse.accepted = false
                                                onMouseYChanged: mouse.accepted = false
                                                onClicked: mouse.accepted = false
                                            }
                                        }

                                        IconImage {
                                            id: iconImg
                                            anchors.fill: parent
                                            asynchronous: true
                                            source: modelData.isCalculator ? "qrc:/icons/calculate.svg" : 
                                                    modelData.isClipboard ? "qrc:/icons/" + modelData.icon + ".svg" :
                                                    modelData.isCommand ? "qrc:/icons/" + modelData.icon + ".svg" :
                                                    Quickshell.iconPath(modelData.icon, "application-x-executable")
                                            visible: (modelData.isCalculator || modelData.isClipboard || modelData.isCommand || parent.iconLoaded) && modelData.type !== 'image'
                                        }
                                        
                                        MaterialIcon {
                                            anchors.centerIn: parent
                                            visible: !modelData.isCalculator && !modelData.isClipboard && !modelData.isCommand && !parent.iconLoaded && modelData.type !== 'image'
                                            icon: Settings.settings.trayFallbackIcon || "broken_image"
                                            size: Math.round(Theme.panelIconSizeSmall * Theme.scale(screen))
                                            color: Theme.accentPrimary
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Theme.uiGapTiny

                                        Text {
                                            text: modelData.name
                                            color: (hovered || isSelected) ? Theme.onAccent : (appLauncherPanel.isPinned(modelData) ? Theme.textPrimary : Theme.textPrimary)
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSmall * Theme.scale(screen)
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
                                            font.pixelSize: Theme.fontSizeCaption * Theme.scale(screen)
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
                                        size: Math.round(Theme.panelIconSizeSmall * Theme.scale(screen))
                                        color: (hovered || isSelected)
                                            ? Theme.onAccent
                                            : (appLauncherPanel.isPinned(modelData) ? Theme.textPrimary : Theme.textSecondary)
                                        Layout.rightMargin: Theme.panelRowSpacingSmall
                                    }

            
                                    Item { width: Theme.panelRowSpacingSmall; height: Theme.uiGapTiny }
                                }

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
                                        ripple.opacity = Theme.uiRippleOpacity;
                                        rippleNumberAnimation.start();
                                        root.selectedIndex = index;
                                        root.activateSelected();
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: ripple.opacity = Theme.uiRippleOpacity
                                    onReleased: ripple.opacity = 0.0
                                }

                                    NumberAnimation { id: rippleNumberAnimation; target: ripple; property: "opacity"; to: 0.0; duration: Theme.uiAnimRippleMs; easing.type: Theme.uiEasingRipple }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: Theme.uiSeparatorThickness
                                    radius: Theme.uiSeparatorRadius
                                    color: Theme.borderSubtle
                                    opacity: index === appList.count - 1 ? 0 : 1.0
                                }

        
                                Item {
                                    id: pinArea
                                    width: Math.round(Theme.panelIconSize * Theme.scale(Screen)); height: Math.round(Theme.panelIconSize * Theme.scale(Screen))
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
                                        size: Theme.fontSizeSmall * Theme.scale(screen)
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
    }
}
