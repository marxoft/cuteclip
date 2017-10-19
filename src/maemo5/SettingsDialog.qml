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

Dialog {
    id: root

    title: qsTr("Settings")
    height: Math.min(360, column.height + platformStyle.paddingMedium)

    Column {
        id: column

        anchors {
            left: parent.left
            right: acceptButton.left
            rightMargin: platformStyle.paddingMedium
            top: parent.top
        }
        spacing: platformStyle.paddingMedium

        CheckBox {
            width: parent.width
            text: qsTr("Disable clipboard monitor inside cuteClip")
            checked: settings.disableMonitorWhenActive
            onCheckedChanged: settings.disableMonitorWhenActive = checked
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Screen orientation")
        }

        ButtonRow {
            width: parent.width

            ExclusiveGroup {
                id: orientationGroup
            }

            Button {
                text: qsTr("Landscape")
                exclusiveGroup: orientationGroup
                checkable: true
                checked: settings.screenOrientation == Qt.WA_Maemo5LandscapeOrientation
                onClicked: settings.screenOrientation = Qt.WA_Maemo5LandscapeOrientation
            }

            Button {
                text: qsTr("Portrait")
                exclusiveGroup: orientationGroup
                checkable: true
                checked: settings.screenOrientation == Qt.WA_Maemo5PortraitOrientation
                onClicked: settings.screenOrientation = Qt.WA_Maemo5PortraitOrientation
            }

            Button {
                text: qsTr("Automatic")
                exclusiveGroup: orientationGroup
                checkable: true
                checked: settings.screenOrientation == Qt.WA_Maemo5AutoOrientation
                onClicked: settings.screenOrientation = Qt.WA_Maemo5AutoOrientation
            }
        }
    }

    Button {
        id: acceptButton

        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        text: qsTr("Done")
        style: DialogButtonStyle {}
        onClicked: root.accept()
    }

    contentItem.states: State {
        name: "Portrait"
        when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation

        AnchorChanges {
            target: column
            anchors.right: parent.right
        }

        PropertyChanges {
            target: column
            anchors.rightMargin: 0
        }

        PropertyChanges {
            target: acceptButton
            width: parent.width
        }

        PropertyChanges {
            target: root
            height: Math.min(680, column.height + acceptButton.height + platformStyle.paddingMedium * 2)
        }
    }
}
