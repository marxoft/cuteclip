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
import "utils.js" as Utils

QtObject {
    signal clipAdded(variant clip)
    signal clipsFetched(variant clips)
    signal clipRemoved(int clipId)
    signal clipUpdated(variant clip)

    signal actionAdded(variant action)
    signal actionsFetched(variant actions)
    signal actionRemoved(int actionId)
    signal actionUpdated(variant action)

    signal error(string errorString)
    signal ready

    function _getDB() {
        return openDatabaseSync("cuteclip", "1.0", "cuteClip database", 10000000);
    }

    function init() {
        var db = _getDB();
        db.transaction(function(tx) {
            //tx.executeSql("DROP TABLE IF EXISTS clips");
            //tx.executeSql("DROP TABLE IF EXISTS actions");
            tx.executeSql("CREATE TABLE IF NOT EXISTS clips(name TEXT COLLATE NOCASE, body TEXT COLLATE NOCASE, modified TEXT COLLATE NOCASE)");
            tx.executeSql("CREATE TABLE IF NOT EXISTS actions(name TEXT COLLATE NOCASE, command TEXT COLLATE NOCASE)");
            ready();
        });
    }

    function fetchClips() {
        var db = _getDB();
        db.readTransaction(function(tx) {
            var result = tx.executeSql("SELECT rowid, name, body, modified FROM clips ORDER BY modified DESC").rows;
            var clips = [];

            for (var i = 0; i < result.length; i++) {
                var item = result.item(i);
                clips.push({"id": item.rowid, "name": item.name, "body": item.body,
                "modified": Utils.dateFromISOString(item.modified)});
            }

            clipsFetched(clips);
        });
    }

    function fetchClip(clipId) {
        var db = _getDB();
        db.readTransaction(function(tx) {
            var result = tx.executeSql("SELECT rowid, name, body, modified FROM clips WHERE rowid = ?", [clipId]).rows;
            var clips = [];

            for (var i = 0; i < result.length; i++) {
                var item = result.item(i);
                clips.push({"id": item.rowid, "name": item.name, "body": item.body,
                "modified": Utils.dateFromISOString(item.modified)});
            }

            clipsFetched(clips);
        });
    }

    function addClip(body) {
        var db = _getDB();
        db.transaction(function(tx) {
            var name = Utils.simplifyString(body).substr(0, 100);
            var modified = new Date();
            var result = tx.executeSql("INSERT INTO clips VALUES (?, ?, ?)", [name, body, modified]);

            if (result.rowsAffected > 0) {
                clipAdded({"id": result.insertId, "name": name, "body": body, "modified": modified});
            }
            else {
                error(qsTr("Cannot add clip to database"));
            }
        });
    }

    function removeClip(clipId) {
        var db = _getDB();
        db.transaction(function(tx) {
            var result = tx.executeSql("DELETE FROM clips WHERE rowid = ?", clipId);

            if (result.rowsAffected > 0) {
                clipRemoved(clipId);
            }
            else {
                error(qsTr("Cannot delete clip from database"));
            }
        });
    }

    function updateClip(clipId, body) {
        var db = _getDB();
        db.transaction(function(tx) {
            var name = Utils.simplifyString(body).substr(0, 100);
            var modified = new Date();
            var result = tx.executeSql("UPDATE clips SET name = ?, body = ?, modified = ? WHERE rowid = ?",
            [name, body, modified, clipId]);

            if (result.rowsAffected > 0) {
                clipUpdated({"id": clipId, "name": name, "body": body, "modified": modified});
            }
            else {
                error(qsTr("Cannot update clip in database"));
            }
        });
    }

    function fetchActions() {
        var db = _getDB();
        db.readTransaction(function(tx) {
            var result = tx.executeSql("SELECT rowid, name, command FROM actions ORDER BY name ASC").rows;
            var actions = [];

            for (var i = 0; i < result.length; i++) {
                var item = result.item(i);
                actions.push({"id": item.rowid, "name": item.name, "command": item.command});
            }

            actionsFetched(actions);
        });
    }

    function fetchAction(actionId) {
        var db = _getDB();
        db.readTransaction(function(tx) {
            var result = tx.executeSql("SELECT rowid, name, command FROM actions WHERE rowid = ?",
            [actionId]).rows;
            var actions = [];

            for (var i = 0; i < result.length; i++) {
                var item = result.item(i);
                actions.push({"id": item.rowid, "name": item.name, "command": item.command});
            }

            actionsFetched(actions);
        });
    }

    function addAction(name, command) {
        var db = _getDB();
        db.transaction(function(tx) {
            var result = tx.executeSql("INSERT INTO actions VALUES (?, ?)", [name, command]);

            if (result.rowsAffected > 0) {
                actionAdded({"id": result.insertId, "name": name, "command": command});
            }
            else {
                error(qsTr("Cannot add action to database"));
            }
        });
    }

    function removeAction(actionId) {
        var db = _getDB();
        db.transaction(function(tx) {
            var result = tx.executeSql("DELETE FROM actions WHERE rowid = ?", actionId);

            if (result.rowsAffected > 0) {
                actionRemoved(actionId);
            }
            else {
                error(qsTr("Cannot delete action from database"));
            }
        });
    }

    function updateAction(actionId, name, command) {
        var db = _getDB();
        db.transaction(function(tx) {
            var result = tx.executeSql("UPDATE actions SET name = ?, command = ? WHERE rowid = ?",
            [name, command, actionId]);

            if (result.rowsAffected > 0) {
                actionUpdated({"id": actionId, "name": name, "command": command});
            }
            else {
                error(qsTr("Cannot update action in database"));
            }
        });
    }
}
