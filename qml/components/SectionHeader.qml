import QtQuick 2.0
import QtQuick.Controls 2.2

Label {
    x: Theme.paddingLarge
    height: Theme.itemSizeExtraSmall
    width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignRight
    font.pixelSize: Theme.fontSizeSmall
    wrapMode: Label.WordWrap
    color: Theme.highlightColor
}
