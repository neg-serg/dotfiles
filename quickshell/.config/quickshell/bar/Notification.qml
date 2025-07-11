import QtQuick

Text {
    required property int id
    required property string body
    required property string summary
    property int margin

    text: `- ${summary}: ${body}`
}

