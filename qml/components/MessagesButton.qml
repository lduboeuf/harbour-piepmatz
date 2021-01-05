import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0

Column {
    id: messagesButton
    property bool isActive: false

    width: parent.width
    ToolButton {
        id: messagesButtonImage
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        contentItem: Image {
            source: messagesButton.isActive ? "image://theme/icon-m-mail?" + Theme.highlightColor : "image://theme/icon-m-mail?" + Theme.primaryColor

        }

        //icon.source: messagesButton.isActive ? "image://theme/icon-m-mail?" + Theme.highlightColor : "image://theme/icon-m-mail?" + Theme.primaryColor
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            handleMessagesClicked();
        }
    }
    Label {
        id: messagesButtonText
        text: qsTr("Messages")
        font.pixelSize: Theme.fontSizeTiny * 7 / 8
        color: messagesButton.isActive ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Label.WordWrap
        //truncationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: handleMessagesClicked();
        }
    }
}
