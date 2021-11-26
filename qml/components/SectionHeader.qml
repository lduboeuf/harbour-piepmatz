import QtQuick 2.0
import QtQuick.Controls 2.2

Label {
    x: LocalTheme.paddingLarge
    height: LocalTheme.itemSizeExtraSmall
    width: (parent ? parent.width : Screen.width) - LocalTheme.paddingLarge * 2
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignRight
    font.pixelSize: LocalTheme.fontSizeSmall
    wrapMode: Label.WordWrap
    color: LocalTheme.highlightColor
}
