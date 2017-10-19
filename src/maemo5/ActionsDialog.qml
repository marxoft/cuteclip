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
    
    title: qsTr("Actions")
    height: 360
    
    ListView {
        id: view
        
        anchors {
            left: parent.left
            right: button.left
            rightMargin: platformStyle.paddingMedium
            top: parent.top
            bottom: parent.bottom
        }
        model: actionModel
        delegate: ActionDelegate {
            onClicked: {
                var dialog = popupManager.open(Qt.resolvedUrl("ActionDialog.qml"), root,
                {name: name, command: command});
                dialog.accepted.connect(function() { database.updateAction(id, dialog.name, dialog.command); });
            }
            onPressAndHold: popupManager.open(actionMenu, root)
        }
    }
    
    Label {
        anchors.centerIn: view
        font.pointSize: platformStyle.fontSizeLarge
        color: platformStyle.disabledTextColor
        text: qsTr("No actions")
        visible: actionModel.count == 0
    }
        
    Button {
        id: button
        
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        style: DialogButtonStyle {}
        text: qsTr("New")
        shortcut: qsTr("Ctrl+N")
        autoRepeat: false
        onClicked: {
            var dialog = popupManager.open(Qt.resolvedUrl("ActionDialog.qml"), root, {title: qsTr("New action")});
            dialog.accepted.connect(function() { database.addAction(dialog.name, dialog.command); });
        }
    }
    
    Component {
        id: actionMenu
        
        Menu {        
            MenuItem {
                text: qsTr("Copy")
                onTriggered: clipboard.text = actionModel.get(view.currentIndex).command
            }

            MenuItem {
                text: qsTr("Delete")
                onTriggered: popupManager.open(deleteDialog, root,
                {text: qsTr("Delete action") + " '" + actionModel.get(view.currentIndex).name + "'?"})
            }
        }
    }

    Component {
        id: deleteDialog

        MessageBox {
            onAccepted: database.removeAction(actionModel.get(view.currentIndex).id)
        }
    }

    contentItem.states: State {
        name: "Portrait"
        when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation

        AnchorChanges {
            target: view
            anchors.right: parent.right
            anchors.bottom: button.top
        }

        PropertyChanges {
            target: view
            anchors.rightMargin: 0
            anchors.bottomMargin: platformStyle.paddingMedium
            clip: true
        }

        PropertyChanges {
            target: button
            width: parent.width
        }

        PropertyChanges {
            target: root
            height: 680
        }
    }
}
