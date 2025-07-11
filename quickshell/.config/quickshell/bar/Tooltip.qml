import QtQuick
import Quickshell
import "root:/" // for Globals

LazyLoader {
  id: root

  // The item to display the tooltip at. If set to null the tooltip will be hidden.
  property Item relativeItem: null

  // Tracks the item after relativeItem is unset.
  property Item displayItem: null

  property PopupContext popupContext: Globals.popupContext

  property bool hoverable: false;
  readonly property bool hovered: item?.hovered ?? false

  // The content to show in the tooltip.
  required default property Component contentDelegate

  active: displayItem != null && popupContext.popup == this

  onRelativeItemChanged: {
    if (relativeItem == null) {
      if (item != null) item.hideTimer.start();
    } else {
      if (item != null) item.hideTimer.stop();
      displayItem = relativeItem;
      popupContext.popup = this;
    }
  }

  PopupWindow {
    anchor {
      window: root.displayItem.QsWindow.window
      rect.y: anchor.window.height + 3
      rect.x: anchor.window.contentItem.mapFromItem(root.displayItem, root.displayItem.width / 2, 0).x
      edges: Edges.Top
      gravity: Edges.Bottom
    }

    visible: true

    property alias hovered: body.containsMouse;

    property Timer hideTimer: Timer {
      interval: 250

      // unloads the popup by causing active to become false
      onTriggered: root.popupContext.popup = null;
    }

    color: "transparent"

    // don't accept mouse input if !hoverable
    Region { id: emptyRegion }
    mask: root.hoverable ? null : emptyRegion

    width: body.implicitWidth
    height: body.implicitHeight

    MouseArea {
      id: body

      anchors.fill: parent
      implicitWidth: content.implicitWidth + 10
      implicitHeight: content.implicitHeight + 10

      hoverEnabled: root.hoverable

      Rectangle {
        anchors.fill: parent

        radius: 5
        border.width: 1
        color: palette.active.toolTipBase
        border.color: palette.active.light

        Loader {
          id: content
          anchors.centerIn: parent
          sourceComponent: contentDelegate
          active: true
        }
      }
    }
  }
}
