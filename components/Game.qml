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

// "THE BEER-WARE LICENSE" (Revision 42):
// Martin Bříza <m@rtinbriza.cz> wrote this file.
// As long as you retain this notice you can do whatever you want
// with this stuff.
// If we meet some day, and you think this stuff is worth it,
// you can buy me a beer in return.

import QtQuick 2.0
import Ubuntu.Components 0.1

Rectangle {
    id: app
    height: width
    focus: true
    color: "#88888888"
    radius: 4

    property variant numbers: []
    property variant savedNumbers: saveNumbers()
    property int cols: 4
    property int rows: 4
    property int finalValue: 2048
    property int score: 0
    property bool won: false

    signal victory
    signal defeat

    function numberAt(col, row) {
        for (var i = 0; i < numbers.length; i++) {
            if (numbers[i].col == col && numbers[i].row == row)
                return numbers[i]
        }
    }
    function popNumberAt(col, row) {
        var tmp = numbers
        for (var i = 0; i < tmp.length; i++) {
            if (tmp[i].col == col && tmp[i].row == row) {
                tmp[i].disappear()
                tmp.splice(i, 1)
            }
        }
        numbers = tmp
    }
    function purge() {
        score = 0
        won = false
        var tmp = numbers
        for (var i = 0; i < tmp.length; i++) {
            tmp[i].destroy()
        }
        tmp = new Array()
        numbers = tmp
        gen2();
        gen2();
    }
    function load() {
        var dbNumbers = gameDoc.contents.numbers
        var tmp = numbers
        var newNumber
        for (var i = 0; i < dbNumbers.length; i++) {
            newNumber = number.createObject(cellGrid,{"number": dbNumbers[i][0],"col": dbNumbers[i][1],"row": dbNumbers[i][2]})
            tmp.push(newNumber)
        }
        numbers = tmp
        score = gameDoc.contents.score
        won = gameDoc.contents.won
    }
    function loadSavedState() {
        var tmp = numbers
        var newNumber
        for (var i = 0; i < savedNumbers.length; i++) {
            newNumber = number.createObject(cellGrid,{"number": savedNumbers[i][0],"col": savedNumbers[i][1],"row": savedNumbers[i][2]})
            tmp.push(newNumber)
        }
        numbers = tmp
    }
    function checkNotStuck() {
        for (var i = 0; i < app.cols; i++) {
            for (var j = 0; j < app.rows; j++) {
                if (!numberAt(i, j))
                    return true
                if (numberAt(i+1,j) && numberAt(i,j).number == numberAt(i+1,j).number)
                    return true
                if (numberAt(i-1,j) && numberAt(i,j).number == numberAt(i-1,j).number)
                    return true
                if (numberAt(i,j+1) && numberAt(i,j).number == numberAt(i,j+1).number)
                    return true
                if (numberAt(i,j-1) && numberAt(i,j).number == numberAt(i,j-1).number)
                    return true
            }
        }
        return false
    }
    function saveNumbers() {
        var returnNumbers = new Array(app.numbers.length)
        for (var i = 0; i < app.numbers.length; i++) {
            returnNumbers[i] = new Array(3)
            returnNumbers[i] = [app.numbers[i].number, app.numbers[i].col, app.numbers[i].row]
        }
        return returnNumbers
    }

    Component {
        id: number

        UbuntuShape {
            id: colorRect
            color: number <=    1 ? "transparent" :
                   number <=    2 ? "#eee4da" :
                   number <=    4 ? "#ede0c8" :
                   number <=    8 ? "#f2b179" :
                   number <=   16 ? "#f59563" :
                   number <=   32 ? "#f67c5f" :
                   number <=   64 ? "#f65e3b" :
                   number <=  128 ? "#edcf72" :
                   number <=  256 ? "#edcc61" :
                   number <=  512 ? "#edc850" :
                   number <= 1024 ? "#edc53f" :
                   number <= 2048 ? "#edc22e" :
                                    "#3c3a32"

            property int col
            property int row

            property int number: Math.random() > 0.9 ? 4 : 2

            x: cells.getAt(col, row).x
            y: cells.getAt(col, row).y
            width: cells.getAt(col, row).width
            height: cells.getAt(col, row).height

            Timer {
                id: newNumTimer
                running: false
                interval: 100
                onTriggered: zoomIn.xScale = zoomIn.yScale = 1
                onRunningChanged: if (running) zoomIn.xScale = zoomIn.yScale = 1.2
            }

            function move(h, v) {
                if (h == col && v == row)
                    return false
                if (app.numberAt(h, v)) {
                    number += app.numberAt(h, v).number
                    app.score += number
                    if (number == finalValue && !won) {
                        won = true
                        app.victory()
                    }
                    app.popNumberAt(h, v)
                    newNumTimer.start()
                }
                col = h
                row = v
                return true
            }

            function disappear() {
                disappearAnimation.start()
            }


           Label {
                id: text

                width: parent.width * 0.9
                height: parent.height * 0.9
                anchors.centerIn: parent

                font.pixelSize: parent.height / 2.5
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: number <= 4 ? "#656565" : "#f2f3f4"

                text: parent.number > 1 ? parent.number : ""
            }

            Behavior on x {
                NumberAnimation {
                    duration: 60
                    easing {
                        type: Easing.InOutQuad
                    }
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: 60
                    easing {
                        type: Easing.InOutQuad
                    }
                }
            }

            NumberAnimation on opacity {
                id: disappearAnimation
                duration: 80
                running: false
                to: 0
                onStopped: colorRect.destroy()
            }

            transform: Scale {
                id: zoomIn
                origin.x: colorRect.width / 2
                origin.y: colorRect.height / 2
                xScale: 0
                yScale: 0
                Behavior on xScale {
                    NumberAnimation {
                        duration: 200
                        easing {
                            type: Easing.InOutQuad
                        }
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: 200
                        easing {
                            type: Easing.InOutQuad
                        }
                    }
                }
            }

            Component.onCompleted: {
                zoomIn.xScale = 1
                zoomIn.yScale = 1
            }
        }
    }

    Item {
        anchors.centerIn: parent
        height: parent.height / 32 * 31
        width: parent.width / 32 * 31

        Grid {
            id: cellGrid
            width: parent.width
            height: parent.height
            anchors.bottom: parent.bottom
            rows: app.rows
            columns: app.cols
            spacing: (parent.width + parent.height) / app.rows / app.cols / 4

            property real cellWidth: (width - (columns - 1) * spacing) / columns
            property real cellHeight: (height - (rows - 1) * spacing) / rows

            Repeater {
                id: cells
                model: app.cols * app.rows
                function getAt(h, v) {
                    return itemAt(h + v * app.cols)
                }
                function getRandom() {
                    return itemAt(Math.floor((Math.random() * 16)%16))
                }
                function getRandomFree() {
                    var free = new Array()
                    for (var i = 0; i < app.cols; i++) {
                        for (var j = 0; j < app.rows; j++) {
                            if (!numberAt(i, j)) {
                                free.push(getAt(i, j))
                            }
                        }
                    }
                    return free[Math.floor(Math.random()*free.length)]
                }
                UbuntuShape {
                    width: parent.cellWidth
                    height: parent.cellHeight
                    color: "#F0F0F0"
                    opacity: 0.3

                    property int col : index % app.cols
                    property int row : index / app.cols
                }
            }
        }
    }


    MouseArea {
        anchors.fill: parent
        property int minimumLength: app.width < app.height ? app.width / 5 : app.height / 5
        property int startX
        property int startY
        onPressed: {
            startX = mouse.x
            startY = mouse.y
        }
        onReleased: {
            var length = Math.sqrt(Math.pow(mouse.x - startX, 2) + Math.pow(mouse.y - startY, 2))
            if (length < minimumLength)
                return
            var diffX = mouse.x - startX
            var diffY = mouse.y - startY
            // not sure what the exact angle is but it feels good
            if (Math.abs(Math.abs(diffX) - Math.abs(diffY)) < minimumLength / 2)
                return
            if (Math.abs(diffX) > Math.abs(diffY))
                if (diffX > 0)
                    app.move(1, 0)
                else
                    app.move(-1, 0)
            else
                if (diffY > 0)
                    app.move(0, 1)
                else
                    app.move(0, -1)
        }
    }
    function gen2() {
        var tmp = numbers
        var cell = cells.getRandomFree()
        var newNumber = number.createObject(cellGrid,{"col":cell.col,"row":cell.row})
        tmp.push(newNumber)
        numbers = tmp
    }
    // oh  my, this HAS TO be rewritten
    function move(col, row) {
        var somethingMoved = false
        var tmp = numbers
        if (col > 0) {
            for (var j = 0; j < app.rows; j++) {
                var filled = 0
                var canMerge = false
                for (var i = app.cols - 1; i >= 0; i--) {
                    if (numberAt(i,j)) {
                        if (canMerge) {
                            if (numberAt(i,j).number == numberAt(app.cols-filled,j).number) {
                                canMerge = false
                                filled--
                            }
                        }
                        else {
                            canMerge = true
                        }
                        if (numberAt(i,j).move(app.cols-1-filled,j))
                            somethingMoved = true
                        filled++
                    }
                }
            }
        }
        if (col < 0) {
            for (var j = 0; j < app.rows; j++) {
                var filled = 0
                var canMerge = false
                for (var i = 0; i < app.cols; i++) {
                    if (numberAt(i,j)) {
                        if (canMerge) {
                            if (numberAt(i,j).number == numberAt(filled-1,j).number) {
                                canMerge = false
                                filled--
                            }
                        }
                        else {
                            canMerge = true
                        }
                        if (numberAt(i,j).move(filled,j))
                            somethingMoved = true
                        filled++
                    }
                }
            }
        }
        if (row > 0) {
            for (var i = 0; i < app.cols; i++) {
                var filled = 0
                var canMerge = false
                for (var j = app.rows - 1; j >= 0; j--) {
                    if (numberAt(i,j)) {
                        if (canMerge) {
                            if (numberAt(i,j).number == numberAt(i,app.rows-filled).number) {
                                canMerge = false
                                filled--
                            }
                        }
                        else {
                            canMerge = true
                        }
                        if (numberAt(i,j).move(i,app.rows-1-filled))
                            somethingMoved = true
                        filled++
                    }
                }
            }
        }
        if (row < 0) {
            for (var i = 0; i < app.cols; i++) {
                var filled = 0
                var canMerge = false
                for (var j = 0; j < app.rows; j++) {
                    if (numberAt(i,j)) {
                        if (canMerge) {
                            if (numberAt(i,j).number == numberAt(i,filled-1).number) {
                                canMerge = false
                                filled--
                            }
                        }
                        else {
                            canMerge = true
                        }
                        if (numberAt(i,j).move(i,filled))
                            somethingMoved = true
                        filled++
                    }
                }
            }
        }
        if (somethingMoved)
            gen2()
        if (!checkNotStuck())
            app.defeat()
    }
}
