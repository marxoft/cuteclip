/**
 * Copyright (C) 2017 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.0
import org.hildon.components 1.0
import "definitions.js" as Definitions

Dialog {
    id: root

    title: qsTr("About")
    height: Math.min(360, flow.height + platformStyle.paddingMedium)

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: flow.height

        Flow {
            id: flow

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            spacing: platformStyle.paddingMedium

            Image {
                id: icon

                width: 64
                height: 64
                source: "image://icon/cuteclip"
            }

            Label {
                width: parent.width - icon.width - platformStyle.paddingMedium
                height: 64
                verticalAlignment: Text.AlignVCenter
                font.pointSize: platformStyle.fontSizeLarge
                font.bold: true
                text: "cuteClip " + Definitions.VERSION_NUMBER
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("cuteClip is a simple notes application with a clipboard monitor and the option to open stored text clips with user-defined actions.")
                + "<br><br>"
                + qsTr("Keyboard shortcuts:")
                + "<br><br>"
                + qsTr("Ctrl+N: Add a new clip/action.")
                + "<br>"
                + qsTr("Ctrl+S: Save a clip/action.")
                + "<br>"
                + qsTr("Ctrl+M: Toggle the clipboard monitor.")
                + "<br>"
                + qsTr("Ctrl+K: Show the actions dialog.")
                + "<br>"
                + qsTr("Ctrl+P: Show the settings dialog.")
                + "<br>"
                + qsTr("Ctrl+H: Show the about dialog.")
                + "<br><br>&copy; Stuart Howarth 2017"
            }
        }
    }

    contentItem.states: State {
        name: "Portrait"
        when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation

        PropertyChanges {
            target: root
            height: Math.min(680, flow.height + platformStyle.paddingMedium)
        }
    }
}
