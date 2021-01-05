import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0

Column {
    id: searchButton
    property bool isActive: false

    width: parent.width
    ToolButton {
        id: searchButtonImage
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        contentItem: Image{
            source: searchButton.isActive ? "image://theme/icon-m-search?" + Theme.highlightColor : "image://theme/icon-m-search?" + Theme.primaryColor

        }

        //icon.source: searchButton.isActive ? "image://theme/icon-m-search?" + Theme.highlightColor : "image://theme/icon-m-search?" + Theme.primaryColor
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            handleSearchClicked();
        }
    }
    Label {
        id: searchButtonText
        text: qsTr("Search")
        font.pixelSize: Theme.fontSizeTiny * 7 / 8
        color: searchButton.isActive ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Label.WordWrap
        //truncationMode: TruncationMode.Fade
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: handleSearchClicked();
        }
    }
}
