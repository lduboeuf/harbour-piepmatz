/*
    Copyright (C) 2017-20 Sebastian J. Wolf

    This file is part of Piepmatz.

    Piepmatz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Piepmatz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Piepmatz. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0
import "../pages"
import "../js/functions.js" as Functions
import "../js/twemoji.js" as Emoji

Row {

    property variant tweetUser;

    id: tweetUserRow
    width: parent.width
    spacing: LocalTheme.paddingSmall
    property string componentFontSize: ( accountModel.getFontSize() === "piepmatz" ? LocalTheme.fontSizeExtraSmall : LocalTheme.fontSizeSmall) ;
    property string iconFontSize: ( accountModel.getFontSize() === "piepmatz" ? LocalTheme.fontSizeSmall : LocalTheme.fontSizeMedium) ;

    Connections {
        target: accountModel
        onFontSizeChanged: {
            if (fontSize === "piepmatz") {
                componentFontSize = LocalTheme.fontSizeExtraSmall;
                iconFontSize = LocalTheme.fontSizeSmall;
            } else {
                componentFontSize = LocalTheme.fontSizeSmall;
                iconFontSize = LocalTheme.fontSizeMedium;
            }
        }
    }

    Text {
        id: tweetUserNameText
        font.pixelSize: componentFontSize
        font.bold: true
        color: LocalTheme.primaryColor
        text: Emoji.emojify(tweetUser.name, componentFontSize)
        textFormat: Text.StyledText
        elide: Text.ElideRight
        maximumLineCount: 1
        width: if (tweetUser.name.length > 25) { parent.width / 2 }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileModel": tweetUser});
            }
        }
        onTruncatedChanged: {
            // There is obviously a bug in QML in truncating text with images.
            // We simply remove Emojis then...
            if (truncated) {
                text = text.replace(/\<img [^>]+\/\>/g, "");
            }
        }
    }

    Image {
        id: tweetUserVerifiedImage
        source: "image://theme/ok"
        visible: tweetUser.verified
        width: iconFontSize
        height: iconFontSize
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileModel": tweetUser});
            }
        }
    }

    Image {
        id: tweetUserProtectedImage
        source: "image://theme/lock"
        visible: tweetUser.protected
        width: iconFontSize
        height: iconFontSize
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileModel": tweetUser});
            }
        }
    }

    Text {
        id: tweetUserHandleText
        font.pixelSize: componentFontSize
        width: parent.width - ( tweetUserVerifiedImage.visible ? tweetUserVerifiedImage.width : 0 ) - ( tweetUserProtectedImage.visible ? tweetUserProtectedImage.width : 0 ) - tweetUserNameText.width - ( 2 * LocalTheme.paddingSmall )
        color: LocalTheme.secondaryColor
        anchors.bottom: tweetUserNameText.bottom
        text: qsTr("@%1").arg(tweetUser.screen_name)
        elide: Text.ElideRight
        maximumLineCount: 1
        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileModel": tweetUser});
            }
        }
    }
}

