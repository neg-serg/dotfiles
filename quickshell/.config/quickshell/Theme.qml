pragma Singleton

import QtQuick
import Quickshell

Singleton {
  property Item get: black
  Item {
    id: black
    property string barBgColor: "#cc000000" 
    property string buttonBorderColor: "#BBBBBB"
    property string buttonBackgroundColor: "#222222"
    property bool buttonBorderShadow: true
    property bool onTop: false
    property string iconColor: "blue"
    property string iconPressedColor: "dark_blue"
  }
}

