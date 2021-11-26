/*
    Copyright (C) 2017-19 Sebastian J. Wolf

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
import "../components"
import "../js/functions.js" as Functions
import "../js/twitter-text.js" as TwitterText
import "../js/twemoji.js" as Emoji

Page {
    id: conversationPage
    allowedOrientations: Orientation.All

    focus: true
    Keys.onLeftPressed: {
        pageStack.pop();
    }
    Keys.onEscapePressed: {
        pageStack.pop();
    }
    Keys.onDownPressed: {
        conversationListView.flick(0, - parent.height);
    }
    Keys.onUpPressed: {
        conversationListView.flick(0, parent.height);
    }
    Keys.onPressed: {
        if (event.key === Qt.Key_T) {
            conversationListView.scrollToTop();
            event.accepted = true;
        }
        if (event.key === Qt.Key_B) {
            conversationListView.scrollToBottom();
            event.accepted = true;
        }
        if (event.key === Qt.Key_PageDown) {
            conversationListView.flick(0, - parent.height * 2);
            event.accepted = true;
        }
        if (event.key === Qt.Key_PageUp) {
            conversationListView.flick(0, parent.height * 2);
            event.accepted = true;
        }
    }

    property variant conversationModel;
    property string myUserId;
    property bool loaded : true;

    function getRemainingCharacters(text) {
        return 10000 - TwitterText.getTweetLength(text);
    }

    AppNotification {
        id: conversationNotification
    }

    Connections {
        target: twitterApi

        onDirectMessagesNewSuccessful: {
            var newMessages = conversationListView.model;
            newMessages.push(result.event);
            conversationListView.model = newMessages;

            conversationListView.positionViewAtEnd();
        }

        onDirectMessagesNewError: {
            conversationNotification.show(errorMessage);
        }
    }

    ProfileHeader {
        id: profileHeader
        profileModel: conversationModel.user
        width: parent.width
    }


    Flickable {
        id: conversationContainer
        width: parent.width
        height: parent.height - profileHeader.height
        anchors.bottom: parent.bottom

        LoadingIndicator {
            id: conversationLoadingIndicator
            visible: !loaded
            Behavior on opacity { NumberAnimation {} }
            opacity: loaded ? 0 : 1
            height: parent.height
            width: parent.width
        }

        Column {
            id: messageListColumn
            width: parent.width
            height: parent.height
            anchors.bottom: parent.bottom

            ListView {
                id: conversationListView
                Component.onCompleted: positionViewAtEnd();

                width: parent.width
                height: parent.height

                clip: true

                model: conversationModel.messages
                delegate: ListItem {

                    id: messageListItem
                    contentHeight: messageTextItem.height + ( 2 * LocalTheme.paddingMedium )
                    contentWidth: parent.width

                    Column {
                        id: messageTextItem

                        spacing: LocalTheme.paddingSmall

                        width: parent.width
                        height: messageText.height + messageDateText.height + ( 2 * LocalTheme.paddingMedium )
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: (modelData.message_create.sender_id === conversationPage.myUserId) ? 4 * LocalTheme.horizontalPageMargin : LocalTheme.horizontalPageMargin
                                right: parent.right
                                rightMargin: (modelData.message_create.sender_id === conversationPage.myUserId) ? LocalTheme.horizontalPageMargin : 4 * LocalTheme.horizontalPageMargin
                            }

                            id: messageText
                            text: Emoji.emojify(Functions.enhanceSimpleText(modelData.message_create.message_data.text, modelData.message_create.message_data.entities), LocalTheme.fontSizeSmall)
                            font.pixelSize: LocalTheme.fontSizeSmall
                            color: modelData.message_create.sender_id === conversationPage.myUserId ? LocalTheme.highlightColor : LocalTheme.primaryColor
                            wrapMode: Text.Wrap
                            textFormat: Text.StyledText
                            onLinkActivated: {
                                Functions.handleLink(link);
                            }
                            horizontalAlignment: (modelData.message_create.sender_id === conversationPage.myUserId) ? Text.AlignRight : Text.AlignLeft
                            linkColor: LocalTheme.highlightColor
                        }

                        Timer {
                            id: messageDateUpdater
                            interval: 60000
                            running: true
                            repeat: true
                            onTriggered: {
                                messageDateText.text = Format.formatDate(new Date(parseInt(modelData.created_timestamp)), Formatter.DurationElapsed);
                            }
                        }

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: (modelData.message_create.sender_id === conversationPage.myUserId) ? 4 * LocalTheme.horizontalPageMargin : LocalTheme.horizontalPageMargin
                                right: parent.right
                                rightMargin: (modelData.message_create.sender_id === conversationPage.myUserId) ? LocalTheme.horizontalPageMargin : 4 * LocalTheme.horizontalPageMargin
                            }

                            id: messageDateText
                            text: Format.formatDate(new Date(parseInt(modelData.created_timestamp)), Formatter.DurationElapsed);
                            font.pixelSize: LocalTheme.fontSizeTiny
                            color: modelData.message_create.sender_id === conversationPage.myUserId ? LocalTheme.highlightColor : LocalTheme.primaryColor
                            horizontalAlignment: (modelData.message_create.sender_id === conversationPage.myUserId) ? Text.AlignRight : Text.AlignLeft
                        }

                    }

                }

                footer: footerComponent

                VerticalScrollDecorator { flickable: conversationListView }
            }

            Component {
                id: footerComponent
                Row {
                    id: newMessageRow
                    width: parent.width - LocalTheme.horizontalPageMargin
                    height: sendMessageColumn.height + ( 2 * LocalTheme.paddingLarge )
                    anchors.left: parent.left
                    spacing: LocalTheme.paddingMedium
                    Column {
                        id: sendMessageColumn
                        width: parent.width - LocalTheme.fontSizeMedium - ( 2 * LocalTheme.paddingMedium )
                        anchors.verticalCenter: parent.verticalCenter
                        TextArea {
                            id: newMessageTextField
                            width: parent.width
                            font.pixelSize: LocalTheme.fontSizeSmall
                            placeholderText: qsTr("New message to %1").arg(conversationModel.user.name)
                            labelVisible: false
                            errorHighlight: remainingCharactersText.text < 0
                        }
                        Text {
                            id: remainingCharactersText
                            text: qsTr("%1 characters left").arg(Number(getRemainingCharacters(newMessageTextField.text)).toLocaleString(Qt.locale(), "f", 0))
                            color: remainingCharactersText.text < 0 ? LocalTheme.highlightColor : LocalTheme.primaryColor
                            font.pixelSize: LocalTheme.fontSizeTiny
                            font.bold: remainingCharactersText.text < 0 ? true : false
                            anchors.left: parent.left
                            anchors.leftMargin: LocalTheme.horizontalPageMargin
                        }
                    }

                    Column {
                        width: LocalTheme.fontSizeMedium
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: LocalTheme.paddingLarge
                        IconButton {
                            id: newMessageSendButton
                            icon.source: "image://theme/icon-m-chat"
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: {
                                twitterApi.directMessagesNew(newMessageTextField.text, conversationModel.user.id_str);
                                newMessageTextField.text = "";
                                newMessageTextField.focus = false;
                            }
                        }
                    }
                }

            }


        }

    }

}

