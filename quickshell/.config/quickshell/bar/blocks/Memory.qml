import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

BarBlock {
  id: text
  content: BarText {
    symbolText: `- ${Math.floor(percentFree)}%`
  }

  property real percentFree

  Process {
    id: memProc
    command: ["sh", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
    running: true

    stdout: SplitParser {
      onRead: data => percentFree = data
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: memProc.running = true
  }
}
