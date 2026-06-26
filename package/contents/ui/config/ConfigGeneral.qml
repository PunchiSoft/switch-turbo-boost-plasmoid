/*
 * SPDX-FileCopyrightText: 2026 Punchisoft
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property string cfg_iconStyle: "cpu"
    property string cfg_uiLanguage: "auto"

    // ###############
    // Icon selection
    // ###############
    function normalizeIconName(iconName) {
        if (iconName === "chip") {
            return "project-chip";
        }
        if (iconName === "bolt") {
            return "flash-symbolic";
        }
        if (iconName === "gauge") {
            return "speedometer";
        }
        if (iconName === "flash") {
            return "flash-symbolic";
        }
        if (iconName === "performance") {
            return "power-profile-performance-symbolic";
        }
        if (iconName === "systemmonitor-cpu") {
            return "org.kde.plasma.systemmonitor.cpu";
        }
        return iconName && iconName.length > 0 ? iconName : "cpu";
    }

    function iconSource(iconName) {
        const normalized = normalizeIconName(iconName);
        if (normalized === "project-chip") {
            return Qt.resolvedUrl("../../images/turbo-chip.svg");
        }
        return normalized;
    }

    Component.onCompleted: cfg_iconStyle = normalizeIconName(cfg_iconStyle)

    KIconThemes.IconDialog {
        id: iconDialog

        onIconNameChanged: iconName => page.cfg_iconStyle = page.normalizeIconName(iconName)
    }

    QQC2.Label {
        Kirigami.FormData.label: i18n("Icono:")
        text: i18n("Haz clic en la miniatura para elegir un icono del sistema.")
        wrapMode: Text.WordWrap
    }

    RowLayout {
        Kirigami.FormData.label: ""
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            id: iconButton

            Layout.minimumWidth: Kirigami.Units.iconSizes.large + Kirigami.Units.smallSpacing * 2
            Layout.maximumWidth: Layout.minimumWidth
            Layout.minimumHeight: Layout.minimumWidth
            Layout.maximumHeight: Layout.minimumWidth
            onClicked: iconDialog.open()

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                source: page.iconSource(page.cfg_iconStyle)
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: page.cfg_iconStyle === "project-chip" ? i18n("Chip del proyecto") : page.cfg_iconStyle
            elide: Text.ElideRight
            opacity: 0.75
        }
    }

    QQC2.Button {
        Kirigami.FormData.label: ""
        text: i18n("Usar chip del proyecto")
        icon.name: "edit-reset"
        onClicked: page.cfg_iconStyle = "project-chip"
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    // ##################
    // Basic localization
    // ##################
    ListModel {
        id: languageModel

        ListElement {
            label: "Automático"
            value: "auto"
        }
        ListElement {
            label: "Español"
            value: "es"
        }
        ListElement {
            label: "English"
            value: "en"
        }
    }

    QQC2.ComboBox {
        Kirigami.FormData.label: i18n("Idioma:")
        textRole: "label"
        valueRole: "value"
        model: languageModel
        Component.onCompleted: {
            for (let i = 0; i < languageModel.count; i++) {
                if (languageModel.get(i).value === page.cfg_uiLanguage) {
                    currentIndex = i;
                    return;
                }
            }
            currentIndex = 0;
        }
        onActivated: function(index) {
            page.cfg_uiLanguage = languageModel.get(index).value;
        }
    }
}
