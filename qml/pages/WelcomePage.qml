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
import QtQuick 2.2
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0

Page {
    id: welcomePage
    //allowedOrientations: Orientation.All
    title: qsTr("Welcome to Piepmatz!")

    Column {
        y: ( parent.height - ( errorInfoLabel.height + wunderfitzErrorImage.height + errorOkButton.height + ( 3 * LocalTheme.paddingSmall ) ) ) / 2
        width: parent.width
        id: pinErrorColumn
        spacing: LocalTheme.paddingSmall

        Behavior on opacity { NumberAnimation {} }
        opacity: 0
        visible: false

        Image {
            id: wunderfitzErrorImage
            source: "../../images/" + accountModel.getImagePath() + "piepmatz.svg"
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            fillMode: Image.PreserveAspectFit
            width: 1/2 * parent.width
        }

        ToolTip {
            id: errorInfoLabel
            font.pixelSize: LocalTheme.fontSizeLarge
            text: ""
        }

        Button {
            id: errorOkButton
            text: qsTr("OK")
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                pinErrorColumn.opacity = 0;
                welcomeFlickable.opacity = 1;
                pinErrorColumn.visible = false;
                welcomeFlickable.visible = true;
            }
        }
    }

    Column {
        y: ( parent.height - ( wunderfitzPinImage.height + enterPinLabel.height + enterPinField.height + enterPinButton.height + ( 3 * LocalTheme.paddingSmall ) ) ) / 2
        width: parent.width
        id: enterPinColumn
        spacing: LocalTheme.paddingSmall

        Behavior on opacity { NumberAnimation {} }
        opacity: 0
        visible: false

        Image {
            id: wunderfitzPinImage
            source: "../../images/" + accountModel.getImagePath() + "piepmatz.svg"
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            fillMode: Image.PreserveAspectFit
            width: 1/2 * parent.width
        }

        ToolTip {
            id: enterPinLabel
            font.pixelSize: LocalTheme.fontSizeLarge
            text: qsTr("Please enter the Twitter PIN:")
        }

        TextField {
            id: enterPinField
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            inputMethodHints: Qt.ImhDigitsOnly
            font.pixelSize: LocalTheme.fontSizeExtraLarge
            width: parent.width - 4 * LocalTheme.paddingLarge
            horizontalAlignment: TextInput.AlignHCenter
        }

        Button {
            id: enterPinButton
            text: qsTr("OK")
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                accountModel.enterPin(enterPinField.text)
                enterPinColumn.opacity = 0;
                enterPinColumn.visible = false;
            }
        }
    }

    Column {
        y: ( parent.height - ( wunderfitzLinkingErrorImage.height + linkingErrorInfoLabel.height + errorOkButton.height + ( 3 * LocalTheme.paddingSmall ) ) ) / 2
        width: parent.width
        id: linkingErrorColumn
        spacing: LocalTheme.paddingSmall

        Behavior on opacity { NumberAnimation {} }
        opacity: 0
        visible: false

        Image {
            id: wunderfitzLinkingErrorImage
            source: "../../images/" + accountModel.getImagePath() + "piepmatz.svg"
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            fillMode: Image.PreserveAspectFit
            width: 1/2 * parent.width
        }

        ToolTip {
            id: linkingErrorInfoLabel
            font.pixelSize: LocalTheme.fontSizeLarge
            text: qsTr("Unable to authenticate you with the entered PIN.")
        }

        Button {
            id: enterPinAgainButton
            text: qsTr("Enter PIN again")
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                linkingErrorColumn.opacity = 0;
                enterPinColumn.opacity = 1;
                linkingErrorColumn.visible = false;
                enterPinColumn.visible = true;
            }
        }

        Button {
            id: restartAuthenticationButton
            text: qsTr("Restart authentication")
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            onClicked: {
                linkingErrorColumn.opacity = 0;
                welcomeFlickable.opacity = 1;
                linkingErrorColumn.visible = false;
                welcomeFlickable.visible = true;
            }
        }
    }

    Flickable {
        id: welcomeFlickable
        anchors.fill: parent
        contentHeight: column.height
        Behavior on opacity { NumberAnimation {} }

        Connections {
            target: accountModel
            onPinRequestSuccessful: {
                console.log("URL: " + url)
                Qt.openUrlExternally(url)
                welcomeFlickable.visible = false
                enterPinColumn.visible = true
                welcomeFlickable.opacity = 0
                enterPinColumn.opacity = 1
            }
            onPinRequestError: {
                errorInfoLabel.text = errorMessage
                welcomeFlickable.visible = false
                pinErrorColumn.visible = true
                welcomeFlickable.opacity = 0
                pinErrorColumn.opacity = 1
                console.log("Error Message: " + errorMessage)
            }
            onLinkingSuccessful: {
                console.log("Linking successful, moving on to my tweets...")
                pageStack.clear()
                pageStack.push(overviewPage)
            }
            onLinkingFailed: {
                enterPinColumn.visible = false
                linkingErrorColumn.visible = true
                enterPinColumn.opacity = 0
                linkingErrorColumn.opacity = 1
                console.log("Linking error, proceeding to error page!")
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: LocalTheme.paddingLarge

//            PageHeader {
//                title: qsTr("Welcome to Piepmatz!")
//            }

            Image {
                id: wunderfitzImage
                source: "../../images/" + accountModel.getImagePath() + "piepmatz.svg"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                fillMode: Image.PreserveAspectFit
                width: 1/2 * parent.width
            }

            Label {
                wrapMode: Text.Wrap
                x: LocalTheme.horizontalPageMargin
                width: parent.width - ( 2 * LocalTheme.horizontalPageMargin )
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Please login to Twitter to continue.")
                font.pixelSize: LocalTheme.fontSizeSmall
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Button {
                text: qsTr("Log in to Twitter")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: {
                    accountModel.obtainPinUrl()
                }
            }

            Label {
                wrapMode: Text.Wrap
                x: LocalTheme.horizontalPageMargin
                width: parent.width - ( 2 * LocalTheme.horizontalPageMargin )
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("If you don't have a Twitter account yet, please sign up first.")
                font.pixelSize: LocalTheme.fontSizeSmall
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Text {
                text: "<a href=\"https://twitter.com/\">" + qsTr("Sign up for Twitter") + "</a>"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                font.pixelSize: LocalTheme.fontSizeSmall
                linkColor: LocalTheme.highlightColor

                onLinkActivated: Qt.openUrlExternally("https://twitter.com/")
            }

        }

    }
}

