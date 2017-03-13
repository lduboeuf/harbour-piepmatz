import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import "../pages"
import "../js/functions.js" as Functions

ListItem {

    id: singleTweet

    property variant tweetModel;
    property string embeddedTweetId;
    property variant embeddedTweet;
    property bool hasEmbeddedTweet : false;

    contentHeight: tweetRow.height + 2 * Theme.paddingMedium
    contentWidth: parent.width

    Row {
        id: tweetRow
        width: parent.width - ( 2 * Theme.horizontalPageMargin )
        height: tweetAuthorColumn.height > tweetContentColumn.height ? tweetAuthorColumn.height + Theme.paddingSmall : tweetContentColumn.height + Theme.paddingSmall
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.paddingMedium

        Column {
            id: tweetAuthorColumn
            width: parent.width / 6
            height: parent.width / 6
            spacing: Theme.paddingSmall
            Image {
                id: tweetRetweetedImage
                source: "image://theme/icon-s-retweet"
                visible: tweetModel.retweeted_status ? true : false
                anchors.right: parent.right
                width: Theme.fontSizeExtraSmall
                height: Theme.fontSizeExtraSmall
            }
            Image {
                id: tweetInReplyToImage
                source: "image://theme/icon-s-repost"
                visible: tweetModel.in_reply_to_user_id_str ? true : false
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
                    source: Functions.findHiResImage(tweetModel.retweeted_status ? tweetModel.retweeted_status.user.profile_image_url_https : tweetModel.user.profile_image_url_https )
                    width: parent.width
                    height: parent.height
                    sourceSize {
                        width: parent.width
                        height: parent.height
                    }
                    visible: false
                }

                Rectangle {
                    id: tweetAuthorPictureMask
                    width: parent.width
                    height: parent.height
                    color: Theme.primaryColor
                    radius: parent.width / 7
                    visible: false
                }

                OpacityMask {
                    id: maskedTweetAuthorPicture
                    source: tweetAuthorPicture
                    maskSource: tweetAuthorPictureMask
                    anchors.fill: tweetAuthorPicture
                    visible: tweetAuthorPicture.status === Image.Ready ? true : false
                    opacity: tweetAuthorPicture.status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation {} }
                }

                ImageProgressIndicator {
                    image: tweetAuthorPicture
                    withPercentage: false
                }

            }
        }

        Column {
            id: tweetContentColumn
            width: parent.width * 5 / 6 - Theme.horizontalPageMargin
            spacing: Theme.paddingSmall

            Column {
                Text {
                    id: tweetRetweetedText
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    text: qsTr("Retweeted by %1").arg(tweetModel.user.name)
                    visible: tweetModel.retweeted_status ? true : false
                }

                Text {
                    id: tweetInReplyToText
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    text: qsTr("In reply to %1").arg(Functions.getUserNameById(tweetModel.in_reply_to_user_id, tweetModel.user, tweetModel.entities.user_mentions))
                    visible: tweetModel.in_reply_to_user_id_str ? true : false
                }
            }

            Row {
                id: tweetUserRow
                width: parent.width
                spacing: Theme.paddingSmall

                Text {
                    id: tweetUserNameText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    font.bold: true
                    color: Theme.primaryColor
                    text: tweetModel.retweeted_status ? tweetModel.retweeted_status.user.name : tweetModel.user.name
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Image {
                    id: tweetUserVerifiedImage
                    source: "image://theme/icon-s-installed"
                    visible: tweetModel.retweeted_status ? tweetModel.retweeted_status.user.verified : tweetModel.user.verified
                    width: Theme.fontSizeSmall
                    height: Theme.fontSizeSmall
                }

                Text {
                    id: tweetUserHandleText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    anchors.bottom: tweetUserNameText.bottom
                    text: qsTr("@%1").arg(tweetModel.retweeted_status ? tweetModel.retweeted_status.user.screen_name : tweetModel.user.screen_name)
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Text {
                width: parent.width
                id: tweetContentText
                text: Functions.enhanceText(tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel)
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                onLinkActivated: Qt.openUrlExternally(link)
                linkColor: Theme.highlightColor
            }

            Row {
                id: tweetInfoRow
                width: parent.width
                spacing: Theme.paddingSmall

                Row {
                    width: parent.width / 2
                    Text {
                        id: tweetDateText
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryColor
                        text:  Functions.getValidDate(tweetModel.retweeted_status ? tweetModel.retweeted_status.created_at : tweetModel.created_at).toLocaleString(Qt.locale(), Locale.ShortFormat)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                Row {
                    width: parent.width / 2
                    spacing: Theme.paddingSmall
                    Column {
                        width: parent.width / 6
                        Image {
                            id: tweetRetweetedCountImage
                            anchors.right: parent.right
                            source: "image://theme/icon-s-retweet"
                            width: Theme.fontSizeExtraSmall
                            height: Theme.fontSizeExtraSmall
                        }
                    }
                    Column {
                        width: parent.width / 3
                        Text {
                            id: tweetRetweetedCountText
                            font.pixelSize: Theme.fontSizeTiny
                            anchors.left: parent.left
                            color: Theme.secondaryColor
                            text: tweetModel.retweeted_status ? ( tweetModel.retweeted_status.retweet_count ? tweetModel.retweeted_status.retweet_count : " " ) : ( tweetModel.retweet_count ? tweetModel.retweet_count : " " )
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                    Column {
                        width: parent.width / 6
                        Image {
                            id: tweetFavoritesCountImage
                            anchors.right: parent.right
                            source: "image://theme/icon-s-favorite"
                            width: Theme.fontSizeExtraSmall
                            height: Theme.fontSizeExtraSmall
                        }
                    }
                    Column {
                        width: parent.width / 3
                        Text {
                            id: tweetFavoritesCountText
                            font.pixelSize: Theme.fontSizeTiny
                            anchors.left: parent.left
                            color: Theme.secondaryColor
                            text: tweetModel.retweeted_status ? ( tweetModel.retweeted_status.favorite_count ? tweetModel.retweeted_status.favorite_count : " " ) : ( tweetModel.favorite_count ? tweetModel.favorite_count : " " )
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }
            }

            ListModel {
                id: tweetImageListModel
            }

            SlideshowView {
                id: tweetImageSlideshow
                visible: Functions.hasImage(tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel)
                width: parent.width
                height: parent.width * 2 / 3
                model: Functions.getTweetImageModel(tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel, tweetImageListModel)
                delegate: Item {
                    width: parent.width
                    height: parent.height

                    Component {
                        id: singleImageComponent
                        ImagePage {
                            imageUrl: media_url_https
                            imageHeight: sizes.large.h
                            imageWidth: sizes.large.w
                        }
                    }

                    Image {
                        id: tweetImage
                        source: media_url_https
                        width: parent.width
                        height: parent.height
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready ? true : false
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation {} }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.push( singleImageComponent );
                            }
                        }
                    }
                    ImageProgressIndicator {
                        image: tweetImage
                        withPercentage: true
                    }
                }
            }

            Loader {
                id: videoLoader
                active: Functions.containsVideo(tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel)
                width: parent.width
                height: Functions.getVideoHeight(parent.width, tweetModel.retweeted_status ? tweetModel.retweeted_status : tweetModel)
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
                    visible: hasEmbeddedTweet
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

    Separator {
        id: tweetSeparator
        width: parent.width
        color: Theme.primaryColor
        horizontalAlignment: Qt.AlignHCenter
    }
}