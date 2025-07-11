import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Hyprland
import "../"

BarText {
  // text: {
  //   var str = activeWindowTitle
  //   return str.length > chopLength ? str.slice(0, chopLength) + '...' : str;
  // }

  property int chopLength
  property string activeWindowTitle

  Process {
    id: titleProc
    command: ["sh", "-c", "hyprctl activewindow | grep title: | sed 's/^[^:]*: //'"]
    running: true

    stdout: SplitParser {
      onRead: data => activeWindowTitle = data
    }
  }

  Component.onCompleted: {
    Hyprland.rawEvent.connect(hyprEvent)
  }

  function hyprEvent(e) {
    titleProc.running = true
  }
}

