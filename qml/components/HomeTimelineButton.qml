import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0

Column {
    id: homeTimelineButton
    property bool isActive: false
    width: parent.width

    ToolButton {
        id: homeButtonImage
        contentItem: Image {
            source: homeTimelineButton.isActive ? "image://theme/icon-m-home?" + Theme.highlightColor : "image://theme/icon-m-home?" + Theme.primaryColor
            height: Theme.iconSizeMedium
            width: Theme.iconSizeMedium
        }

        //icon.source: homeTimelineButton.isActive ? "image://theme/icon-m-home?" + Theme.highlightColor : "image://theme/icon-m-home?" + Theme.primaryColor

        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            handleHomeClicked();
        }

    }

    Label {
        id: homeButtonText
        text: qsTr("Timeline")
        font.pixelSize: Theme.fontSizeTiny * 7 / 8
        color: homeTimelineButton.isActive ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Label.WordWrap
        //truncationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: handleHomeClicked();
        }
    }


}
