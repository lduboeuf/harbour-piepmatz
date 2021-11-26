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
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2 //import Sailfish.Silica 1.0
import "pages"
import "components"

MainView
{

    id: appWindow
    visible: true
    height: 700
    width: 400

    property bool isWifi: accountModel.isWiFi();
    property string linkPreviewMode: accountModel.getLinkPreviewMode();

    Component {
        id: aboutPage
        AboutPage {}
    }

    Component {
        id: welcomePage
        WelcomePage {}
    }

    Component {
        id: overviewPage
        OverviewPage {}
    }

    Component {
        id: newTweetPage
        NewTweetPage {}
    }

    Component {
        id: attachImagesPage
        AttachImagesPage {}
    }

    Component {
        id: registrationPage
        RegistrationPage {}
    }

    Component {
        id: settingsPage
        SettingsPage {}
    }

    StackView {
        id: pageStack
        anchors.fill: parent
        initialItem: accountModel.isLinked() ? overviewPage : welcomePage
    }

    //initialPage: ( wagnis.isRegistered() && wagnis.hasFeature("contribution") ) ? (accountModel.isLinked() ? overviewPage : welcomePage) : registrationPage
    //initialPage: accountModel.isLinked() ? overviewPage : welcomePage
    //cover: Qt.resolvedUrl("pages/CoverPage.qml")
    //allowedOrientations: defaultAllowedOrientations

}

