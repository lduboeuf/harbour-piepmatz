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
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0
import "../pages"
import "../js/functions.js" as Functions
import "../js/twemoji.js" as Emoji

Item {

    id: tweetElementItem

    property variant tweetModel;
    //onTweetModelChanged: console.log('tweetModel', JSON.stringify(tweetModel))
    property string tweetId : ( tweetModel.retweeted_status ? tweetModel.retweeted_status.id_str : tweetModel.id_str );
    // TODO: attributes favorited and retweeted are only temporary workarounds until we are able to update and replace individual tweets in the model
    // does not work completely if model is reloaded (e.g. during scrolling)
    property bool favorited : ( tweetModel.retweeted_status ? tweetModel.retweeted_status.favorited : tweetModel.favorited );
    property bool retweeted : ( tweetModel.retweeted_status ? tweetModel.retweeted_status.retweeted : tweetModel.retweeted );
    property string embeddedTweetId;
    property variant embeddedTweet;
    property bool hasEmbeddedTweet : false;
    property string referenceUrl;
    property variant referenceMetadata;
    property bool hasReference : false;
    property bool extendedMode : false;
    property bool withSeparator : true;
    property bool isRetweetMention : false;
    property string componentFontSize: ( accountModel.getFontSize() === "piepmatz" ? Theme.fontSizeTiny : Theme.fontSizeExtraSmall) ;
    property string infoTextFontSize: ( accountModel.getFontSize() === "piepmatz" ? Theme.fontSizeExtraSmall : Theme.fontSizeSmall) ;
    property string infoIconFontSize: Theme.fontSizeMedium;

    width: parent.width
    height: tweetRow.height + tweetAdditionalRow.height + tweetSeparator.height + 3 * Theme.paddingMedium

    Behavior on height {
        PropertyAnimation { easing.type: Easing.OutBack; duration: 200 }
        enabled: accountModel.getUseLoadingAnimations()
    }

    Connections {
        target: accountModel
        onFontSizeChanged: {
            if (fontSize === "piepmatz") {
                componentFontSize = Theme.fontSizeTiny;
                infoTextFontSize = Theme.fontSizeExtraSmall;
            } else {
                componentFontSize = Theme.fontSizeExtraSmall;
                infoTextFontSize = Theme.fontSizeSmall;
            }
        }
    }

    Column {
        id: tweetColumn
        width: parent.width - ( 2 * Theme.horizontalPageMargin )
        spacing: Theme.paddingSmall
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Row {
            id: tweetRow
            width: parent.width
            spacing: Theme.paddingMedium

            Column {
                id: tweetAuthorColumn
                width: tweetModel.fakeTweet ? 0 : ( parent.width / 6 )
                height: parent.width / 6
                spacing: Theme.paddingSmall
                Image {
                    id: tweetRetweetedImage
                    source: "image://theme/retweet"
                    visible: tweetModel.retweeted_status ? true : false
                    anchors.right: parent.right
                    width: tweetElementItem.isRetweetMention ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
                    height: tweetElementItem.isRetweetMention ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
                }
                Image {
                    id: tweetInReplyToImage
                    source: "image://theme/mail-forward"
                    visible: tweetModel.in_reply_to_status_id_str ? true : false
                    anchors.right: parent.right
                    width: Theme.fontSizeExtraSmall
                    height: Theme.fontSizeExtraSmall
                }
                Image {
                    id: tweetDirectImage
                    source: "image://theme/email"
                    visible: (tweetModel.in_reply_to_user_id_str && !tweetModel.in_reply_to_status_id_str) ? true : false
                    anchors.right: parent.right
                    width: Theme.fontSizeExtraSmall
                    height: Theme.fontSizeExtraSmall
                }

                Item {
                    id: tweetAuthorItem
                    width: parent.width
                    height: parent.width

                    Image {
                        id: tweetAuthorPicture
                        z: 42
                        source: Functions.findBiggerImage(tweetModel.retweeted_status ? ( tweetElementItem.isRetweetMention ? tweetModel.user.profile_image_url_https : tweetModel.retweeted_status.user.profile_image_url_https ) : tweetModel.user.profile_image_url_https )
                        width: parent.width
                        height: parent.height
                        visible: false
                    }

                    Rectangle {
                        id: tweetAuthorPictureErrorShade
                        z: 42
                        width: parent.width
                        height: parent.height
                        color: "lightgrey"
                        visible: false
                    }

                    Rectangle {
                        id: tweetAuthorPictureMask
                        z: 42
                        width: parent.width
                        height: parent.height
                        color: Theme.primaryColor
                        radius: parent.width / 7
                        visible: false
                    }

                    OpacityMask {
                        id: maskedTweetAuthorPicture
                        z: 42
                        source: tweetAuthorPicture.status === Image.Error ? tweetAuthorPictureErrorShade : tweetAuthorPicture
                        maskSource: tweetAuthorPictureMask
                        anchors.fill: tweetAuthorPicture
                        visible: ( tweetAuthorPicture.status === Image.Ready || tweetAuthorPicture.status === Image.Error ) ? true : false
                        opacity: tweetAuthorPicture.status === Image.Ready ? 1 : ( tweetAuthorPicture.status === Image.Error ? 0.3 : 0 )
                        Behavior on opacity { NumberAnimation {} }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileModel": tweetModel.retweeted_status ? ( tweetElementItem.isRetweetMention ? tweetModel.user : tweetModel.retweeted_status.user ) : tweetModel.user});
                            }
                        }
                    }

                    ImageProgressIndicator {
                        image: tweetAuthorPicture
                        withPercentage: false
                    }

                }
            }

            Column {
                id: tweetContentColumn
                width: tweetModel.fakeTweet ? ( parent.width - Theme.horizontalPageMargin ) : ( parent.width * 5 / 6 - Theme.horizontalPageMargin )

                spacing: Theme.paddingSmall

                Column {
                    Text {
                        id: tweetRetweetedText
                        font.pixelSize: tweetElementItem.isRetweetMention ? Theme.fontSizeExtraSmall : componentFontSize
                        color: tweetElementItem.isRetweetMention ? Theme.primaryColor : Theme.secondaryColor
                        text: qsTr("Retweeted by %1").arg(( tweetElementItem.isRetweetMention ? "<b>" : "" ) + Emoji.emojify(tweetModel.user.name, componentFontSize) + ( tweetElementItem.isRetweetMention ? "</b>" : "" ))
                        textFormat: Text.StyledText
                        visible: tweetModel.retweeted_status ? true : false
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: tweetContentColumn.width
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileModel": tweetModel.user});

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

                    Text {
                        id: tweetInReplyToText
                        font.pixelSize: componentFontSize
                        color: Theme.secondaryColor
                        text: qsTr("In reply to %1").arg(Emoji.emojify(Functions.getUserNameById(tweetModel.in_reply_to_user_id, tweetModel.user, tweetModel.entities.user_mentions), componentFontSize))
                        textFormat: Text.StyledText
                        visible: tweetModel.in_reply_to_status_id_str ? true : false
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: tweetContentColumn.width
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileName": Functions.getScreenNameById(tweetModel.in_reply_to_user_id, tweetModel.user, tweetModel.entities.user_mentions)});
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

                    Text {
                        id: tweetDirectText
                        font.pixelSize: componentFontSize
                        color: Theme.secondaryColor
                        text: qsTr("Tweet to %1").arg(Emoji.emojify(Functions.getUserNameById(tweetModel.in_reply_to_user_id, tweetModel.user, tweetModel.entities.user_mentions), componentFontSize))
                        textFormat: Text.StyledText
                        visible: (tweetModel.in_reply_to_user_id_str && !tweetModel.in_reply_to_status_id_str) ? true : false
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: tweetContentColumn.width
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../pages/ProfilePage.qml"), {"profileName": Functions.getScreenNameById(tweetModel.in_reply_to_user_id, tweetModel.user, tweetModel.entities.user_mentions)});
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
                }

                TweetUser {
                    id: tweetUserRow
                    tweetUser: tweetModel.retweeted_status ? tweetModel.retweeted_status.user : tweetModel.user
                    visible: !tweetElementItem.isRetweetMention && !tweetModel.fakeTweet
                }

                TweetText {
                    id: tweetContentText
                    tweet: tweetModel
                    truncateText: tweetElementItem.isRetweetMention
                }

                Connections {
                    target: twitterApi
                    onGetOpenGraphSuccessful: {
                        if (referenceUrl === result.url) {
                            tweetElementItem.referenceMetadata = result;
                            tweetElementItem.hasReference = true;
                        }
                    }
                }

                Component {
                    id: openGraphComponent

                    Column {
                        id: openGraphColumn
                        Timer {
                            id: openGraphVisibleTimer
                            interval: 250
                            repeat: false
                            onTriggered: {
                                openGraphColumn.visible = true;
                            }
                        }

                        Component.onCompleted: {
                            openGraphVisibleTimer.start();
                        }
                        visible: false
                        opacity: visible ? 1 : 0
                        Behavior on opacity { NumberAnimation {} }
                        spacing: Theme.paddingSmall
                        Rectangle {
                            width: parent.width
                            color: Theme.primaryColor
                            height: 1
                            //horizontalAlignment: Qt.AlignHCenter
                        }

                        Item {
                            id: openGraphImageItem
                            width: parent.width
                            height: parent.width * 2 / 3
                            visible: referenceMetadata.image ? true : false
                            Image {
                                id: openGraphImage

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        openGraphImageItem.visible = false;
                                    }
                                }

                                width: parent.width
                                height: parent.height
                                fillMode: Image.PreserveAspectCrop
                                visible: status === Image.Ready ? true : false
                                opacity: status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation {} }
                                source: referenceMetadata.image ? referenceMetadata.image : ""
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (referenceMetadata.url) {
                                            pageStack.push(Qt.resolvedUrl("../pages/ImagePage.qml"), {"imageUrl": openGraphImage.source, "imageHeight": openGraphImage.sourceSize.height, "imageWidth": openGraphImage.sourceSize.height, "tweet": tweetModel});
                                            // Qt.openUrlExternally(referenceMetadata.url);
                                        }
                                    }
                                }
                            }
                            ImageProgressIndicator {
                                image: openGraphImage
                                withPercentage: false
                            }
                        }

                        Text {
                            //visible: referenceMetadata.description ? true : false
                            width: parent.width
                            id: openGraphText
                            //text: referenceMetadata.description ? Emoji.emojify(Functions.htmlDecode(referenceMetadata.description), componentFontSize) : ""
                            text: referenceMetadata.description
                            font.pixelSize: componentFontSize
                            color: Theme.primaryColor
                            wrapMode: Text.Wrap
                            textFormat: Text.StyledText
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            onTruncatedChanged: {
                                // There is obviously a bug in QML in truncating text with images.
                                // We simply remove Emojis then...
                                if (truncated) {
                                    text = text.replace(/\<img [^>]+\/\>/g, "");
                                }
                            }
                        }

                        Text {
                            visible: referenceMetadata.url ? true : false
                            width: parent.width
                            id: openGraphLink
                            text: "<a href=\"" + referenceMetadata.url + "\">" + Emoji.emojify(Functions.htmlDecode(referenceMetadata.title), componentFontSize) + "</a>"
                            font.pixelSize: componentFontSize
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            textFormat: Text.StyledText
                            onLinkActivated: {
                                Functions.handleLink(link);
                            }
                            linkColor: Theme.highlightColor
                        }

                        Rectangle {
                            width: parent.width
                            color: Theme.primaryColor
                            height: 1
                                                      //horizontalAlignment: Qt.AlignHCenter
                        }
                    }
                }

                Loader {
                    id: openGraphLoader
                    active: tweetElementItem.hasReference
                    width: parent.width
                    sourceComponent: openGraphComponent
                }

                Row {
                    id: tweetSourceRow
                    width: parent.width
                    visible: tweetElement.extendedMode && !tweetModel.fakeTweet
                    spacing: Theme.paddingSmall
                    Text {
                        id: tweetSourceText
                        width: parent.width
                        font.pixelSize: Theme.fontSizeExtraSmall
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        color: Theme.secondaryColor
                        text: qsTr("Tweeted with %1").arg((tweetModel.retweeted_status ? tweetModel.retweeted_status.source : tweetModel.source).replace(/\<[^\>]+\>/g, ""))
                    }
                }

                Row {
                    id: tweetPlaceRow
                    width: parent.width
                    visible: tweetElement.extendedMode && Functions.containsPlace(tweetModel)
                    spacing: Theme.paddingSmall
                    Image {
                        id: tweetPlaceImage
                        source: "image://theme/location"
                        width: Theme.fontSizeSmall
                        height: Theme.fontSizeSmall
                    }
                    Text {
                        id: tweetPlaceText
                        width: parent.width - Theme.paddingSmall - tweetPlaceImage.width
                        font.pixelSize: Theme.fontSizeExtraSmall
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        color: Theme.secondaryColor
                        text: tweetPlaceRow.visible ? ( tweetModel.retweeted_status ? tweetModel.retweeted_status.place.full_name : tweetModel.place.full_name ) : ""
                    }
                }

                Row {
                    id: tweetInfoRow
                    width: parent.width
                    height: Theme.fontSizeLarge
                    spacing: Theme.paddingSmall
                    visible: !tweetModel.fakeTweet

                    Connections {
                        target: twitterApi
                        onFavoriteSuccessful: {
                            if (tweetElementItem.tweetId === result.id_str) {
                                tweetFavoritesCountImage.visible = true;
                                tweetFavoritesCountImage.source = "image://theme/icon-s-favorite?" + Theme.highlightColor;
                                tweetFavoritesCountText.color = Theme.highlightColor;
                                tweetFavoritesCountText.text = Functions.getShortenedCount(Functions.getFavoritesCount(result));
                                tweetElementItem.favorited = true;
                            }
                        }
                        onFavoriteError: {
                            tweetFavoritesCountImage.visible = true;
                        }
                        onUnfavoriteSuccessful: {
                            if (tweetElementItem.tweetId === result.id_str) {
                                tweetFavoritesCountImage.visible = true;
                                tweetFavoritesCountImage.source = "image://theme/icon-s-favorite?" + Theme.primaryColor;
                                tweetFavoritesCountText.color = Theme.secondaryColor;
                                tweetFavoritesCountText.text = Functions.getShortenedCount(Functions.getFavoritesCount(result));
                                tweetElementItem.favorited = false;
                            }
                        }
                        onUnfavoriteError: {
                            tweetFavoritesCountImage.visible = true;
                        }
                        onRetweetSuccessful: {
                            if (tweetElementItem.tweetId === result.retweeted_status.id_str) {
                                tweetRetweetedCountImage.visible = true;
                                tweetRetweetedCountImage.source = "image://theme/icon-s-retweet?" + Theme.highlightColor;
                                tweetRetweetedCountText.color = Theme.highlightColor;
                                tweetRetweetedCountText.text = Functions.getShortenedCount(Functions.getRetweetCount(result));
                                tweetElementItem.retweeted = true;
                            }
                        }
                        onRetweetError: {
                            tweetRetweetedCountImage.visible = true;
                        }
                        onUnretweetSuccessful: {
                            if (tweetElementItem.tweetId === result.id_str) {
                                tweetRetweetedCountImage.visible = true;
                                tweetRetweetedCountImage.source = "image://theme/icon-s-retweet?" + Theme.primaryColor;
                                tweetRetweetedCountText.color = Theme.secondaryColor;
                                tweetRetweetedCountText.text = Functions.getShortenedCount(Functions.getRetweetCount(result));
                                tweetElementItem.retweeted = false;
                            }
                        }
                        onUnretweetError: {
                            tweetRetweetedCountImage.visible = true;
                        }
                    }

                    Timer {
                        id: tweetDateUpdater
                        interval: 60000
                        running: true
                        repeat: true
                        onTriggered: {
                            //TODO
                            tweetDateText.text = Qt.formatDate(Functions.getValidDate(tweetModel.retweeted_status ? tweetModel.retweeted_status.created_at : tweetModel.created_at));
                        }
                    }

                    Row {
                        width: parent.width * 9 / 20
                        height: parent.height
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            id: tweetDateText
                            font.pixelSize: infoTextFontSize
                            color: Theme.secondaryColor
                            text:  Qt.formatDate(Functions.getValidDate(tweetModel.retweeted_status ? tweetModel.retweeted_status.created_at : tweetModel.created_at))
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    Row {
                        width: parent.width * 11 / 20
                        height: parent.height
                        spacing: Theme.paddingSmall
                        Column {
                            width: parent.width / 6
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: !Functions.getRelevantTweet(tweetModel).user.protected
                            Image {
                                id: tweetRetweetedCountImage
                                anchors.right: parent.right

                                source: "image://theme/retweet"
                                width: infoIconFontSize
                                height: infoIconFontSize
                                opacity: Functions.getRelevantTweet(tweetModel).user.protected ? 0.2 : 1
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tweetRetweetedCountImage.visible = false;
                                        tweetElementItem.retweeted ? twitterApi.unretweet(tweetElementItem.tweetId) : twitterApi.retweet(tweetElementItem.tweetId);
                                    }

                                }
                            }
                            ColorOverlay {
                                    //anchors.fill: tweetRetweetedCountImage
                                    source: tweetRetweetedCountImage
                                    color: tweetModel.retweeted_status ? tweetModel.retweeted_status.retweeted ? Theme.highlightColor : Theme.primaryColor  : tweetModel.retweeted ? Theme.highlightColor  : Theme.primaryColor
                            }
                            BusyIndicator {
                                id: tweetRetweetBusyIndicator
                                anchors.right: parent.right
                                running: visible
                                //size: BusyIndicatorSize.ExtraSmall
                                visible: !tweetRetweetedCountImage.visible
                            }
                        }
                        Column {
                            width: parent.width / 3
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: !Functions.getRelevantTweet(tweetModel).user.protected
                            Text {
                                id: tweetRetweetedCountText
                                font.pixelSize: infoTextFontSize
                                anchors.left: parent.left
                                color: tweetModel.retweeted_status ? ( tweetModel.retweeted_status.retweeted ? Theme.highlightColor : Theme.secondaryColor ) : ( tweetModel.retweeted ? Theme.highlightColor : Theme.secondaryColor )
                                text: Functions.getShortenedCount(Functions.getRetweetCount(tweetModel))
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tweetRetweetedCountImage.visible = false;
                                        tweetElementItem.retweeted ? twitterApi.unretweet(tweetElementItem.tweetId) : twitterApi.retweet(tweetElementItem.tweetId);
                                    }

                                }
                            }
                        }
                        Column {
                            width: parent.width / 6
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: tweetFavoritesCountImage
                                anchors.right: parent.right
                                source: tweetModel.retweeted_status ? ( tweetModel.retweeted_status.favorited ? ( "image://theme/like?" + Theme.highlightColor ) : "image://theme/like" ) : ( tweetModel.favorited ? ( "image://theme/like?" + Theme.highlightColor ) : "image://theme/like" )
                                width: infoIconFontSize
                                height: infoIconFontSize
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tweetFavoritesCountImage.visible = false;
                                        tweetElementItem.favorited ? twitterApi.unfavorite(tweetElementItem.tweetId) : twitterApi.favorite(tweetElementItem.tweetId);
                                    }

                                }
                            }
                            BusyIndicator {
                                id: tweetFavoriteBusyIndicator
                                anchors.right: parent.right
                                running: visible
                                //size: BusyIndicatorSize.ExtraSmall
                                visible: !tweetFavoritesCountImage.visible
                            }
                        }
                        Column {
                            width: parent.width / 3
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                id: tweetFavoritesCountText
                                font.pixelSize: infoTextFontSize
                                anchors.left: parent.left
                                color: tweetModel.retweeted_status ? ( tweetModel.retweeted_status.favorited ? Theme.highlightColor : Theme.secondaryColor ) : ( tweetModel.favorited ? Theme.highlightColor : Theme.secondaryColor )
                                text: Functions.getShortenedCount(Functions.getFavoritesCount(tweetModel))
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tweetFavoritesCountImage.visible = false;
                                        tweetElementItem.favorited ? twitterApi.unfavorite(tweetElementItem.tweetId) : twitterApi.favorite(tweetElementItem.tweetId);
                                    }

                                }
                            }
                        }
                    }
                }

            }
        }

        Row {
            id: tweetAdditionalRow
            width: parent.width
            spacing: Theme.paddingMedium

            Column {
                id: dummyLeftColumn
                width: parent.width / 6
                height: Theme.fontSizeTiny
            }

            Column {
                id: tweetAdditionalRightColumn
                width: parent.width * 5 / 6 - Theme.horizontalPageMargin

                spacing: Theme.paddingSmall

                TweetImageSlideshow {
                    id: tweetImageSlideshow
                    visible: !tweetElementItem.isRetweetMention && Functions.hasImage(tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel)
                    tweet: tweetModel
                }

                Loader {
                    id: videoLoader
                    active: !tweetElementItem.isRetweetMention && Functions.containsVideo(tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel)
                    width: parent.width
                    height: tweetElementItem.isRetweetMention ? 0 : Functions.getVideoHeight(parent.width, tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel)
                    sourceComponent: tweetVideoComponent
                }

                Component {
                    id: tweetVideoComponent
                    TweetVideo {
                        tweet: tweetModel
                    }
                }

                Connections {
                    target: twitterApi
                    onShowStatusSuccessful: {
                        if (embeddedTweetId === result.id_str) {
                            embeddedTweet = result;
                            hasEmbeddedTweet = true;
                        }
                    }
                }

                Component {
                    id: embeddedTweetComponent
                    EmbeddedTweet {
                        id: embeddedTweetItem
                        tweetModel: embeddedTweet

                        Timer {
                            id: embeddedTweetVisibleTimer
                            interval: 250
                            repeat: false
                            onTriggered: {
                                embeddedTweetItem.visible = true;
                            }
                        }

                        Component.onCompleted: {
                            embeddedTweetVisibleTimer.start();
                        }
                        visible: false
                        opacity: visible ? 1 : 0
                        Behavior on opacity { NumberAnimation {} }
                    }
                }

                Loader {
                    id: embeddedTweetLoader
                    active: hasEmbeddedTweet
                    width: parent.width
                    sourceComponent: embeddedTweetComponent
                }
            }
        }
    }

    Rectangle {
        id: tweetSeparator

        anchors {
            top: tweetColumn.bottom
            topMargin: Theme.paddingMedium
        }

        width: parent.width
        color: Theme.primaryColor
        //horizontalAlignment: Qt.AlignHCenter
        visible: tweetElementItem.withSeparator
    }

}

