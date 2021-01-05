import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0

Column {
    id: profileButton
    property bool isActive: false

    width: parent.width
    ToolButton {
        id: profileButtonImage
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        contentItem: Image{
            source: profileButton.isActive ? "image://theme/icon-m-person?" + Theme.highlightColor : "image://theme/icon-m-person?" + Theme.primaryColor

        }

        //icon.source: profileButton.isActive ? "image://theme/icon-m-person?" + Theme.highlightColor : "image://theme/icon-m-person?" + Theme.primaryColor
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            handleProfileClicked();
        }
    }
    Label {
        id: profileButtonText
        text: qsTr("Profile")
        font.pixelSize: Theme.fontSizeTiny * 7 / 8
        color: profileButton.isActive ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Label.WordWrap
        //truncationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: handleProfileClicked();
        }
    }
}
