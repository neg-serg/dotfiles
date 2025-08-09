// Bar/Modules/NetworkUsage.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var    screen: null
    property int    desiredHeight: 24
    property int    fontPixelSize: 0
    property bool   useTheme: true
    property color  textColor: useTheme ? Theme.textPrimary : "#ffffff"
    property color  bgColor:   "transparent"
    property int    iconSpacing: 4
    property string deviceMatch: ""
    property var    cmd: deviceMatch ? ["rsmetrx", "--continuous", deviceMatch] 
                                     : ["rsmetrx", "--continuous"]
    property string displayText: "—"
    
    implicitHeight: desiredHeight
    implicitWidth: lineBox.implicitWidth
    width: implicitWidth
    height: desiredHeight

    Rectangle {
        anchors.fill: parent
        color: bgColor
        visible: bgColor !== "transparent"
    }

    Row {
        id: lineBox
        spacing: iconSpacing
        anchors.verticalCenter: parent.verticalCenter

        Label {
            id: label
            text: displayText
            color: textColor
            font.family: Theme.fontFamily
            font.pixelSize: fontPixelSize > 0
                             ? fontPixelSize
                             : Theme.fontSizeSmall * Theme.scale(screen)
            padding: 6
        }
    }

    Process {
        id: runner
        running: true
        command: cmd
        
        // onErrorOccurred: {
        //     console.error("NetworkUsage error:", errorString)
        //     displayText = "err"
        //     restartTimer.start()
        // }
        
        stdout: StdioCollector {
            id: collector
            waitForEnd: false
            
            onTextChanged: {
                // Ручная обработка потока данных
                const rawText = text;
                const lines = rawText.split('\n');
                
                // Обрабатываем все полные строки
                for (let i = 0; i < lines.length - 1; i++) {
                    const line = lines[i].trim();
                    if (line) parseJsonLine(line);
                }
                
                // Сохраняем неполную строку для следующего обновления
                collector.text = lines[lines.length - 1];
            }
        }
    }

    Timer {
        id: healthTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // Проверяем, не завершился ли процесс
            if (runner.status === Process.Finished) {
                console.log("Process finished, restarting...")
                runner.start()
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 5000
        onTriggered: {
            console.log("Restarting network monitor...")
            runner.start()
        }
    }

    function parseJsonLine(line) {
        try {
            const data = JSON.parse(line);
            
            // Проверяем структуру данных
            if (typeof data.rx_kib_s === "number" && 
                typeof data.tx_kib_s === "number") {
                
                // Обновляем отображение
                root.displayText = formatData(data);
            } else {
                throw "Invalid data format";
            }
        } catch (e) {
            console.error("JSON parse error:", e, "Line:", line);
            displayText = "err";
        }
    }

    function formatData(data) {
        if (data.rx_kib_s === 0 && data.tx_kib_s === 0) {
            return "0";
        }
        
        return `${fmtKiBps(data.rx_kib_s)}/${fmtKiBps(data.tx_kib_s)}`;
    }

    function fmtKiBps(kib) {
        if (kib >= 1024 * 1024) return (kib / (1024 * 1024)).toFixed(1) + "G";
        if (kib >= 1024) return (kib / 1024).toFixed(1) + "M";
        return kib.toFixed(1) + "K";
    }

    Component.onCompleted: {
        console.log("Starting network monitor:", cmd.join(" "));
    }
}
