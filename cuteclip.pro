TEMPLATE = subdirs

maemo5 {
    src.files = \
        src/maemo5/AboutDialog.qml \
        src/maemo5/ActionDelegate.qml \
        src/maemo5/ActionDialog.qml \
        src/maemo5/ClipDelegate.qml \
        src/maemo5/ClipDialog.qml \
        src/maemo5/ClipModel.qml \
        src/maemo5/Database.qml \
        src/maemo5/definitions.js \
        src/maemo5/FilterBar.qml \
        src/maemo5/MainWindow.qml \
        src/maemo5/SettingsDialog.qml \
        src/maemo5/utils.js

    src.path = /opt/cuteclip/qml

    launcher.files = src/maemo5/cuteclip
    launcher.path = /usr/bin

    desktop.files = desktop/maemo5/cuteclip.desktop
    desktop.path = /usr/share/applications/hildon

    icon48.files = desktop/maemo5/48/cuteclip.png
    icon48.path = /usr/share/icons/hicolor/48x48/apps

    icon64.files = desktop/maemo5/64/cuteclip.png
    icon64.path = /usr/share/icons/hicolor/64x64/apps

    INSTALLS += \
        src \
        launcher \
        desktop \
        icon48 \
        icon64
}
