/*
  Copyright (C) 2017 Sebastian J. Wolf
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/functions.js" as Functions
import "../components"

Page {
    id: textPage
    allowedOrientations: Orientation.All

    property string contentId;
    property bool loading;

    Component.onCompleted: {
        if (textPage.contentId === "tos") {
            textHeader.title = qsTr("Twitter Terms of Service");
            textPage.loading = true;
            twitterApi.helpTos();
            return;
        }
        if (textPage.contentId === "privacy") {
            textHeader.title = qsTr("Twitter Privacy Policy");
            textPage.loading = true;
            twitterApi.helpPrivacy();
            return;
        }
        textNotification.show("Piepmatz doesn't know what you were asking for!");
    }

    Connections {
        target: twitterApi

        onHelpPrivacySuccessful: {
            textPage.loading = false;
            textContent.text = result.privacy;
        }
        onHelpPrivacyError: {
            textPage.loading = false;
            textNotification.show(errorMessage);
        }
        onHelpTosSuccessful: {
            textPage.loading = false;
            textContent.text = result.tos;
        }
        onHelpTosError: {
            textPage.loading = false;
            textNotification.show(errorMessage);
        }
    }

    SilicaFlickable {
        id: textContainer
        contentHeight: column.height
        anchors.fill: parent

        Notification {
            id: textNotification
        }

        LoadingIndicator {
            id: textLoadingIndicator
            visible: textPage.loading
            Behavior on opacity { NumberAnimation {} }
            opacity: textPage.loading ? 1 : 0
            height: parent.height
            width: parent.width
        }

        Column {
            id: column
            width: textPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: textHeader
            }

            Text {
                id: textContent
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                linkColor: Theme.highlightColor
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
            }

            VerticalScrollDecorator {}
        }

    }
}
