/*
 * Copyright (C) 2014 Filip Dobrocký <filip.dobrocky@gmail.com>
 * This file is part of 2048Native.
 *
 * Chords is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Chords is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chords.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Ubuntu.Components 0.1

Page {
    property string version: "0.1.1"

    title: i18n.tr("About")

    Flickable {
        anchors {
            fill: parent
            margins: units.gu(1)
        }
        contentWidth: aboutColumn.width
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            width: parent.parent.width
            spacing: units.gu(1)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "2048Native"
                fontSize: "large"
            }

            UbuntuShape {
                width: units.gu(12); height: units.gu(12)
                anchors.horizontalCenter: parent.horizontalCenter

                radius: "medium"
                image: Image {
                    source: Qt.resolvedUrl("2048.png")
                }
            }

            Label {
                width: parent.width

                linkColor: UbuntuColors.orange
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<b>Version:</b> " + version + "<br><br>
<b>Swipe or use your arrow keys to move the tiles. When two tiles with the same number touch, they merge into one!</b><br><br>
Based on <a href=\"http://gabrielecirulli.github.io/2048/\">2048</a> by <a href=\"http://gabrielecirulli.com/\">Gabriele Cirulli</a>.
Code from <a href=\"https://github.com/MartinBriza/2048.qml\">2048.qml</a> by <a href=\"http://ma.rtinbriza.cz\">Martin Bříza</a> is used in this app.<br>"


                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                width: parent.width

                linkColor: UbuntuColors.orange
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<b>Author:</b> Filip Dobrocký<br>
<b>Contact:</b> <a href=\"https://plus.google.com/u/0/106056788722129106018/posts\">Filip Dobrocký (Google Plus)</a><br>
<b>License:</b> <a href=\"http://www.gnu.org/licenses/gpl.txt\">GNU GPL v3</a><br>
<b>Source code:</b> <a href=\"https://github.com/filip-dobrocky/2048\">GitHub</a><br>
<b>Bug tracker:</b> <a href=\"https://github.com/filip-dobrocky/2048/issues\">GitHub</a>"

                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: "<b>Copyright (C) 2014 Filip Dobrocký &lt;filip.dobrocky@gmail.com&gt;</b><br>"
            }
        }
    }
}
