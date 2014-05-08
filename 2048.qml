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
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db
import "components"

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    id: mainView

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.filip-dobrocky.2048native"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    width: units.gu(45)
    height: units.gu(70)

    focus: true

    U1db.Database {
        id: db
        path: "2048native"
    }

    U1db.Document {
        id: gameDoc
        docId: 'game'
        database: db
        create: true
        defaults: { 'numbers': [], 'score': 0, 'won': false }
    }

    U1db.Document {
        id: bestDoc
        docId: 'best'
        database: db
        create: true
        defaults: { 'best': 0 }
    }

    U1db.Document {
        id: themeDoc
        docId: 'theme'
        database: db
        create: true
        defaults: { 'theme': "Ambiance" }

        onContentsChanged: Theme.name = "Ubuntu.Components.Themes." + themeDoc.contents.theme
    }

    PageStack {
        id: pageStack

        Component.onCompleted: push(gamePage)

        Page {
            id: gamePage
            title: "2048Native"
            visible: false
            tools: ToolbarItems {
                ToolbarButton {
                    text: i18n.tr("About")
                    iconName: "help"
                    onTriggered: pageStack.push(aboutPage)
                }

                ToolbarButton {
                    text: i18n.tr("Theme")
                    iconName: (themeDoc.contents.theme == "Ambiance") ? "torch-on" : "torch-off"
                    onTriggered: themeDoc.contents = (themeDoc.contents.theme == "Ambiance") ? { 'theme': "SuruDark" } : { 'theme': "Ambiance" }
            }

            ToolbarButton {
                text: i18n.tr("Restart")
                iconName: "reload"
                onTriggered: PopupUtils.open(restartDialogComponent)
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: units.gu(1)

            Row {
                id: scores
                width: game.width
                height: units.gu(6)
                spacing: units.gu(1)

                UbuntuShape {
                    width: (parent.width - units.gu(1)) / 2
                    height: parent.height
                    color: "#88888888"

                    Column {
                        anchors.centerIn: parent

                        Label {
                            id: scoreLabel
                            text: i18n.tr("SCORE")
                            fontSize: "small"
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }

                        Label {
                            width: scoreLabel.width
                            text: "<b>" + game.score + "</b>"
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }
                }

                UbuntuShape {
                    width: (parent.width - units.gu(1)) / 2
                    height: parent.height
                    color: "#88888888"

                    Column {
                        anchors.centerIn: parent

                        Label {
                            id: bestLabel
                            text: i18n.tr("BEST")
                            fontSize: "small"
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }

                        Label {
                            width: bestLabel.width
                            text: "<b>" + game.best + "</b>"
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }
                }
            }

            Game {
                id: game
                width: (parent.parent.width < parent.parent.height)
                       ? parent.parent.width - units.gu(4)
                       : parent.parent.height - scores.height - units.gu(5)

                property int best: bestDoc.contents.best

                onVictory: PopupUtils.open(victoryDialogComponent)
                onDefeat: PopupUtils.open(defeatDialogComponent)
                onScoreChanged: if (score > best) best = score

                Component.onCompleted: {
                    //db.putDoc({'numbers': []}, 'numbers')
                    if (gameDoc.contents.numbers.length == 0 || gameDoc.contents == undefined) purge()
                    else load()
                }
                Component.onDestruction: {
                    gameDoc.contents = { 'numbers': saveNumbers(), 'score': score, 'won': won }
                    bestDoc.contents = { 'best': best }
                }
            }
        }

        Component {
            id: restartDialogComponent

            Dialog {
                id: restartDialog
                title: i18n.tr("Restart")
                text: i18n.tr("Are you sure you want to restart the game?")

                Button {
                    text: i18n.tr("Yes")
                    onClicked: {
                        game.purge()
                        PopupUtils.close(restartDialog)
                    }
                }

                Button {
                    text: i18n.tr("No")
                    color: UbuntuColors.warmGrey
                    onClicked: {
                        PopupUtils.close(restartDialog)
                    }
                }

                Component.onCompleted: mainView.focus = false
                Component.onDestruction: mainView.focus = true
            }
        }

        Component {
            id: victoryDialogComponent

            Dialog {
                id: victoryDialog
                title: i18n.tr("You win!")

                Button {
                    text: i18n.tr("Keep going")
                    onClicked: {
                        PopupUtils.close(victoryDialog)
                    }
                }

                Button {
                    text: i18n.tr("Restart")
                    color: UbuntuColors.warmGrey
                    onClicked: {
                        game.purge()
                        PopupUtils.close(victoryDialog)
                    }
                }

                Component.onCompleted: mainView.focus = false
                Component.onDestruction: mainView.focus = true
            }
        }

        Component {
            id: defeatDialogComponent

            Dialog {
                id: defeatDialog
                title: i18n.tr("Game over.")
                text: i18n.tr("Score") + ": " + game.score

                Button {
                    text: i18n.tr("Restart")
                    onClicked: {
                        game.purge()
                        PopupUtils.close(defeatDialog)
                    }
                }

                Button {
                    text: i18n.tr("Quit game")
                    color: UbuntuColors.warmGrey
                    onClicked: {
                        game.purge()
                        Qt.quit()
                    }
                }

                Component.onCompleted: mainView.focus = false
                Component.onDestruction: mainView.focus = true
            }
        }
    }

    AboutPage {
        id: aboutPage
        visible: false
    }
}

Keys.onPressed: {
    if (event.key == Qt.Key_Left)
        game.move(-1, 0)
    if (event.key == Qt.Key_Right)
        game.move(1, 0)
    if (event.key == Qt.Key_Up)
        game.move(0, -1)
    if (event.key == Qt.Key_Down)
        game.move(0, 1)
}
}
