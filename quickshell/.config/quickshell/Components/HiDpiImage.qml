import QtQuick

// HiDpiImage — Image with auto-calculated sourceSize for crisp rendering
// Usage: HiDpiImage { anchors.fill: parent; source: url; fillMode: Image.PreserveAspectCrop }
Image {
    id: root
    // If true, uses Screen.devicePixelRatio; else uses dpr property
    property bool autoDpr: true
    // Custom DPR if autoDpr is false
    property real dpr: 1.0

    asynchronous: true
    cache: true
    smooth: true
    mipmap: true

    sourceSize: Qt.size(
        Math.round(width  * (autoDpr ? Screen.devicePixelRatio : dpr)),
        Math.round(height * (autoDpr ? Screen.devicePixelRatio : dpr))
    )
}

