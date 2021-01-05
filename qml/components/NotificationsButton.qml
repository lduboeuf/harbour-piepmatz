import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0

Column {
    id: notificationsButton
    property bool isActive: false

    width: parent.width
    ToolButton {
        id: notificationsButtonImage
        contentItem: Image {
            source:notificationsButton.isActive ? "image://theme/icon-m-alarm?" + Theme.highlightColor : "image://theme/icon-m-alarm?" + Theme.primaryColor
            height: Theme.iconSizeMedium
            width: Theme.iconSizeMedium
        }
        //icon.source: notificationsButton.isActive ? "image://theme/icon-m-alarm?" + Theme.highlightColor : "image://theme/icon-m-alarm?" + Theme.primaryColor

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            handleNotificationsClicked();
        }
    }
    Label {
        id: notificationsButtonText
        text: qsTr("Notifications")
        font.pixelSize: Theme.fontSizeTiny * 7 / 8
        color: notificationsButton.isActive ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Label.WordWrap
        //runcationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: handleNotificationsClicked();
        }
    }
}
