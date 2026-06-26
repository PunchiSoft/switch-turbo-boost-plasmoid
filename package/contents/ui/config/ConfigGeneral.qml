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
    property string cfg_processorIconStyle: "auto"
    property string cfg_uiLanguage: "auto"
    property alias cfg_preferredPopupWidth: popupWidthSpin.value
    property alias cfg_preferredPopupHeight: popupHeightSpin.value

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

    function processorIconSource(iconName) {
        const normalized = iconName && iconName.length > 0 ? iconName : "auto";
        if (normalized === "amd") {
            return Qt.resolvedUrl("../../images/vendor-amd.svg");
        }
        if (normalized === "intel") {
            return Qt.resolvedUrl("../../images/vendor-intel.svg");
        }
        if (normalized === "project-chip") {
            return Qt.resolvedUrl("../../images/turbo-chip.svg");
        }
        if (normalized === "auto" || normalized === "cpu") {
            return Qt.resolvedUrl("../../images/vendor-cpu.svg");
        }
        return iconSource(normalized);
    }

    function processorIconLabel(iconName) {
        const normalized = iconName && iconName.length > 0 ? iconName : "auto";
        if (normalized === "auto") {
            return i18n("Automatico");
        }
        if (normalized === "amd") {
            return "AMD";
        }
        if (normalized === "intel") {
            return "Intel";
        }
        if (normalized === "cpu") {
            return "CPU";
        }
        if (normalized === "project-chip") {
            return i18n("Chip turbo");
        }
        return normalized;
    }

    Component.onCompleted: cfg_iconStyle = normalizeIconName(cfg_iconStyle)

    KIconThemes.IconDialog {
        id: iconDialog

        onIconNameChanged: iconName => page.cfg_iconStyle = page.normalizeIconName(iconName)
    }

    KIconThemes.IconDialog {
        id: processorIconDialog

        onIconNameChanged: iconName => page.cfg_processorIconStyle = page.normalizeIconName(iconName)
    }

    QQC2.Label {
        Kirigami.FormData.label: i18n("Icono del panel:")
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

    // ########################
    // Processor icon selection
    // ########################
    RowLayout {
        Kirigami.FormData.label: i18n("Icono del procesador:")
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            id: processorIconButton

            Layout.minimumWidth: Kirigami.Units.iconSizes.large + Kirigami.Units.smallSpacing * 2
            Layout.maximumWidth: Layout.minimumWidth
            Layout.minimumHeight: Layout.minimumWidth
            Layout.maximumHeight: Layout.minimumWidth
            onClicked: processorIconDialog.open()

            Kirigami.Icon {
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                source: page.processorIconSource(page.cfg_processorIconStyle)
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: page.processorIconLabel(page.cfg_processorIconStyle)
            elide: Text.ElideRight
            opacity: 0.75
        }
    }

    RowLayout {
        Kirigami.FormData.label: ""
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            text: i18n("Auto")
            onClicked: page.cfg_processorIconStyle = "auto"
        }

        QQC2.Button {
            text: "AMD"
            onClicked: page.cfg_processorIconStyle = "amd"
        }

        QQC2.Button {
            text: "Intel"
            onClicked: page.cfg_processorIconStyle = "intel"
        }

        QQC2.Button {
            text: "CPU"
            onClicked: page.cfg_processorIconStyle = "cpu"
        }

        QQC2.Button {
            text: i18n("Chip")
            onClicked: page.cfg_processorIconStyle = "project-chip"
        }
    }

    QQC2.Label {
        Kirigami.FormData.label: ""
        text: i18n("Haz clic en la miniatura para elegir un icono personalizado del sistema.")
        wrapMode: Text.WordWrap
        opacity: 0.75
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

    Item {
        Kirigami.FormData.isSection: true
    }

    // ################
    // Popup dimensions
    // ################
    RowLayout {
        Kirigami.FormData.label: i18n("Ancho del menu:")
        spacing: Kirigami.Units.smallSpacing

        QQC2.SpinBox {
            id: popupWidthSpin

            from: 216
            to: 640
            stepSize: 10
            editable: true
        }

        QQC2.Label {
            text: i18n("px")
            opacity: 0.75
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Alto del menu:")
        spacing: Kirigami.Units.smallSpacing

        QQC2.SpinBox {
            id: popupHeightSpin

            from: 180
            to: 720
            stepSize: 10
            editable: true
        }

        QQC2.Label {
            text: i18n("px")
            opacity: 0.75
        }
    }

    QQC2.Button {
        Kirigami.FormData.label: ""
        text: i18n("Restablecer tamano")
        icon.name: "edit-reset"
        onClicked: {
            popupWidthSpin.value = 252;
            popupHeightSpin.value = 466;
        }
    }
}
