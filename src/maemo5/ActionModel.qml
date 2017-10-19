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

SortFilterProxyModel {
    function append(item) {
        sourceModel.append(item);
    }

    function insert(before, item) {
        sourceModel.insert(mapRowToSource(before), item);
    }

    function remove(index) {
        sourceModel.remove(mapRowToSource(index));
    }

    function get(index) {
        return sourceModel.get(mapRowToSource(index));
    }

    function set(index, item) {
        sourceModel.set(mapRowToSource(index), item);
    }

    function setProperty(index, name, value) {
        sourceModel.setProperty(mapRowToSource(index), name, value);
    }

    function clear() {
        sourceModel.clear();
    }

    function match(start, name, value) {
        for (var i = 0; i < sourceModel.count; i++) {
            var item = sourceModel.get(mapRowToSource(i));

            if ((item) && (item[name] == value)) {
                return i;
            }
        }

        return -1;
    }

    sourceModel: ListModel {}
    filterRole: "name"
    filterCaseSensitivity: Qt.CaseInsensitive
    sortRole: "name"
    sortCaseSensitivity: Qt.CaseInsensitive
    dynamicSortFilter: true
}
