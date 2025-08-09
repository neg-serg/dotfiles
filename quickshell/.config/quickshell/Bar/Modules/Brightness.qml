import QtQuick
import Quickshell
import Quickshell.Io
import qs.Components
import qs.Settings

Item {
    id: brightnessDisplay
    property int brightness: -1
    property int previousBrightness: -1
    property var screen: (typeof modelData !== 'undefined' ? modelData : null)
    property string monitorName: screen ? screen.name : "DP-1"
    property bool isSettingBrightness: false
    property bool hasPendingSet: false
    property int pendingSetValue: -1
    property bool firstChange: true 

    width: pill.width
    height: pill.height
    
    Process {
        id: getBrightnessProcess
        command: [Quickshell.shellDir + "/Programs/zigbrightness", "get", monitorName]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim()
                const val = parseInt(output)
                if (isNaN(val)) return

                if (val < 0) {
                    brightnessDisplay.visible = false
                }
                else if (val >= 0 && val !== previousBrightness) {
                    brightnessDisplay.visible = true
                    previousBrightness = brightness
                    brightness = val
                    pill.text = brightness + "%"

                    if (firstChange) {
                        firstChange = false
                    }
                    else {
                        pill.show()
                    }
                }
            }
        }
    }
    
    function getBrightness() {
        if (isSettingBrightness) {
            return
        }
        
        getBrightnessProcess.running = true
    }
    
    Process {
        id: setBrightnessProcess
        property int targetValue: -1
        command: [Quickshell.shellDir + "/Programs/zigbrightness", "set", monitorName, targetValue.toString()]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim()
                const val = parseInt(output)
                
                if (!isNaN(val) && val >= 0) {
                    brightness = val
                    pill.text = brightness + "%"
                    pill.show()
                }
                
                isSettingBrightness = false
                
                if (hasPendingSet) {
                    hasPendingSet = false
                    const pendingValue = pendingSetValue
                    pendingSetValue = -1
                    setBrightness(pendingValue)
                }
            }
        }
    }
    
    function setBrightness(newValue) {
        newValue = Math.max(0, Math.min(100, newValue))
        
        if (isSettingBrightness) {
            hasPendingSet = true
            pendingSetValue = newValue
            return
        }
        
        isSettingBrightness = true
        setBrightnessProcess.targetValue = newValue
        setBrightnessProcess.running = true
    }

    PillIndicator {
        id: pill
        icon: "brightness_high"
        text: brightness >= 0 ? brightness + "%" : "--"
        pillColor: Theme.surfaceVariant
        iconCircleColor: Theme.accentPrimary
        iconTextColor: Theme.backgroundPrimary
        textColor: Theme.textPrimary
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                getBrightness()
                brightnessTooltip.tooltipVisible = true
                pill.showDelayed()
            }
            onExited: {
                brightnessTooltip.tooltipVisible = false
                pill.hide()
            }
            
            onWheel: function(wheel) {
                const delta = wheel.angleDelta.y > 0 ? 5 : -5
                const newBrightness = brightness + delta
                setBrightness(newBrightness)
            }
        }
        StyledTooltip {
            id: brightnessTooltip
            text: "Brightness: " + brightness + "%"
            positionAbove: false
            tooltipVisible: false
            targetItem: pill
            delay: 1500
        }
    }

    Component.onCompleted: {
        getBrightness()
    }
}