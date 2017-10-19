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
import org.hildon.settings 1.0
import org.hildon.utils 1.0
import "definitions.js" as Definitions

Window {
    id: window

    visible: true
    title: "cuteClip"
    menuBar: MenuBar {
        MenuItem {
            ValueButton {
                style: ValueButtonStyle {
                    valueTextColor: platformStyle.activeTextColor
                    valueLayout: ValueLayout.ValueUnderTextCentered
                }
                text: qsTr("Clipboard monitor")
                valueText: settings.monitorEnabled ? qsTr("On") : qsTr("Off")
                onClicked: settings.monitorEnabled = !settings.monitorEnabled
            }
        }

        MenuItem {
            action: actionsAction
        }

        MenuItem {
            action: settingsAction
        }

        MenuItem {
            action: aboutAction
        }
    }

    Action {
        id: monitorAction

        shortcut: qsTr("Ctrl+M")
        autoRepeat: false
        onTriggered: {
            settings.monitorEnabled = !settings.monitorEnabled;
            informationBox.information(settings.monitorEnabled ? qsTr("Clipboard monitor on")
            : qsTr("Clipboard monitor off"));
        }
    }

    Action {
        id: actionsAction

        text: qsTr("Actions")
        shortcut: qsTr("Ctrl+K")
        autoRepeat: false
        onTriggered: popupManager.open(Qt.resolvedUrl("ActionsDialog.qml"), window)
    }

    Action {
        id: settingsAction

        text: qsTr("Settings")
        shortcut: qsTr("Ctrl+P")
        autoRepeat: false
        onTriggered: popupManager.open(Qt.resolvedUrl("SettingsDialog.qml"), window)
    }

    Action {
        id: aboutAction

        text: qsTr("About")
        shortcut: qsTr("Ctrl+H")
        autoRepeat: false
        onTriggered: popupManager.open(Qt.resolvedUrl("AboutDialog.qml"), window)
    }

    Button {
        id: clipButton

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: platformStyle.paddingMedium
        }
        text: qsTr("New clip")
        iconName: "general_add"
        shortcut: qsTr("Ctrl+N")
        autoRepeat: false
        activeFocusOnPress: false
        onClicked: {
            var dialog = popupManager.open(Qt.resolvedUrl("ClipDialog.qml"), window, {title: qsTr("New clip")});
            dialog.accepted.connect(function() { database.addClip(dialog.body); });
        }
    }

    ListView {
        id: clipView

        anchors {
            left: parent.left
            right: parent.right
            top: clipButton.bottom
            topMargin: platformStyle.paddingMedium
            bottom: parent.bottom
        }
        cacheBuffer: 400
        clip: true
        model: clipModel
        delegate: ClipDelegate {
            onClicked: {
                var dialog = popupManager.open(Qt.resolvedUrl("ClipDialog.qml"), window, {body: body});
                dialog.accepted.connect(function() { database.updateClip(id, dialog.body); });
            }
            onPressAndHold: popupManager.open(clipMenu, window)
        }

        Keys.onPressed: {
            if (event.text) {
                filterLoader.sourceComponent = filterBar;
                filterLoader.item.text = event.text;
                event.accepted = true;
            }
        }
    }

    Label {
        anchors.centerIn: parent
        font.pointSize: platformStyle.fontSizeLarge
        color: platformStyle.disabledTextColor
        text: qsTr("No clips")
        visible: clipModel.count == 0
    }

    InformationBox {
        id: informationBox

        function information(message) {
            label.text = message;
            show();
        }

        height: label.height + platformStyle.paddingLarge
        
        Label {
            id: label
            
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: platformStyle.paddingLarge
            }
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: platformStyle.reversedTextColor
        }
    }

    Loader {
        id: filterLoader

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    Component {
        id: filterBar

        FilterBar {
            onTextChanged: clipModel.filterFixedString = text
            onRejected: filterLoader.sourceComponent = undefined
            Component.onCompleted: forceActiveFocus()
            Component.onDestruction: clipView.forceActiveFocus()
        }
    }

    Component {
        id: clipMenu

        Menu {
            MenuItem {
                text: qsTr("Open with action")                
                visible: actionModel.count > 0
                onTriggered: popupManager.open(openDialog, window);
            }

            MenuItem {
                text: qsTr("Copy")
                onTriggered: clipboard.text = clipModel.get(clipView.currentIndex).body
            }

            MenuItem {
                text: qsTr("Delete")
                onTriggered: popupManager.open(deleteDialog, window,
                {text: qsTr("Delete clip") + " '" + clipModel.get(clipView.currentIndex).name + "'?"})
            }
        }
    }

    Component {
        id: openDialog

        ListPickSelector {
            title: qsTr("Open with action")
            model: actionModel
            textRole: "name"
            onSelected: {
                var action = actionModel.get(currentIndex);

                if (process.startDetached(action.command.replace("%c", clipModel.get(clipView.currentIndex).body))) {
                    informationBox.information(qsTr("Opening clip with") + " " + action.name);
                }
                else {
                    informationBox.information(qsTr("Unable to start process"));
                }
            }
        }
    }

    Component {
        id: deleteDialog

        MessageBox {
            onAccepted: database.removeClip(clipModel.get(clipView.currentIndex).id)
        }
    }

    ClipModel {
        id: clipModel
    }

    ActionModel {
        id: actionModel
    }

    Connections {
        target: clipboard
        onTextChanged: if ((clipboard.hasText) && (settings.monitorEnabled)
        && ((!Qt.application.active) || (!settings.disableMonitorWhenActive))) database.addClip(clipboard.text);
    }

    Process {
        id: process
    }

    Database {
        id: database

        onClipsFetched: {
            for (var i = 0; i < clips.length; i++) {
                clipModel.append(clips[i]);
            }
        }
        onClipAdded: {
            clipModel.append(clip);
            informationBox.information(qsTr("Clip added"));
        }
        onClipRemoved: {
            clipModel.remove(clipModel.match(0, "id", clipId));
            informationBox.information(qsTr("Clip deleted"));
        }
        onClipUpdated: {
            clipModel.set(clipModel.match(0, "id", clip.id), clip);
            informationBox.information(qsTr("Clip updated"));
        }
        onActionsFetched: {
            for (var i = 0; i < actions.length; i++) {
                actionModel.append(actions[i]);
            }
        }
        onActionAdded: {
            actionModel.append(action);
            informationBox.information(qsTr("Action added"));
        }
        onActionRemoved: {
            actionModel.remove(actionModel.match(0, "id", actionId));
            informationBox.information(qsTr("Action deleted"));
        }
        onActionUpdated: {
            actionModel.set(actionModel.match(0, "id", action.id), action);
            informationBox.information(qsTr("Action updated"));
        }
        onError: informationBox.information(errorString)
        onReady: {
            fetchClips();
            fetchActions();
        }
    }

    Settings {
        id: settings

        property bool monitorEnabled: false
        property bool disableMonitorWhenActive: true
        property int screenOrientation: Qt.WA_Maemo5LandscapeOrientation

        fileName: Definitions.APP_CONFIG_FILE
        onScreenOrientationChanged: screen.orientationLock = screenOrientation
    }

    contentItem.states: State {
        name: "Filter"
        when: filterLoader.item != null

        AnchorChanges {
            target: clipView
            anchors.bottom: filterLoader.top
        }
    }

    Component.onCompleted: {
        database.init();
        clipView.forceActiveFocus();
    }
}
