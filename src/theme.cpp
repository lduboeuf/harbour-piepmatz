/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

#include "theme.h"

//QScopedPointer<Theme> Theme::m_instance(0);

//Theme *Theme::instance() {
//    if (m_instance.isNull())
//        m_instance.reset(new Theme);

//    return m_instance.data();
//}

Theme::Theme(QObject *parent) : QObject(parent) { }

int Theme::fontSizeTiny() const {
    return 16; }
int Theme::fontSizeExtraSmall() const {
    return 18; }
int Theme::fontSizeSmall() const {
    return 20; }
int Theme::fontSizeMedium() const {
    return 24; }
int Theme::fontSizeLarge() const {
    return 26; }
int Theme::fontSizeExtraLarge() const {
    return 28; }
int Theme::fontSizeHuge() const {
    return 32; }

int Theme::iconSizeSmall() const
{
    return 24;
}

int Theme::iconSizeMedium() const
{
    return 36;
}

int Theme::iconSizeLarge() const
{
    return 48;
}

int Theme::paddingSmall() const {
    return 6; }
int Theme::paddingMedium() const {
    return 8; }
int Theme::paddingLarge() const {
    return 10; }

int Theme::horizontalPageMargin() const
{
    return 10;
}

QString Theme::primaryColor() const {
    return "#222222"; }
QString Theme::secondaryColor() const {
    return "#888888"; }
QString Theme::highlightColor() const {
    return "#cc6633"; }
QString Theme::secondaryHighlightColor() const {
    return "#888888"; }
QString Theme::primaryColorInverted() const {
    return "#ffffff"; }
QString Theme::secondaryColorInverted() const {
    return "#aaaaaa"; }
QString Theme::highlightColorInverted() const {
    return "#dd7744"; }
QString Theme::secondaryHighlightColorInverted() const {
    return "#aaaaaa"; }

