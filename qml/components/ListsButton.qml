import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0

Column {
    id: listsButton
    property bool isActive: false

    width: parent.width
    ToolButton {
        id: listsButtonImage
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        contentItem: Image {
            source: listsButton.isActive ? "image://theme/icon-m-note?" + Theme.highlightColor : "image://theme/icon-m-note?" + Theme.primaryColor

        }

        //icon.source: listsButton.isActive ? "image://theme/icon-m-note?" + Theme.highlightColor : "image://theme/icon-m-note?" + Theme.primaryColor
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            handleListsClicked();
        }
    }
    Label {
        id: listsButtonText
        text: qsTr("Lists")
        font.pixelSize: Theme.fontSizeTiny * 7 / 8
        color: listsButton.isActive ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Label.WordWrap
        //truncationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: handleListsClicked();
        }
    }
}
