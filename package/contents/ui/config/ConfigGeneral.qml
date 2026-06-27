/*
 * SPDX-FileCopyrightText: 2026 Punchisoft
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
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
    property string cfg_themeMode: "auto"
    property alias cfg_customBackgroundColor: backgroundColorField.text
    property alias cfg_customTextColor: textColorField.text
    property alias cfg_customMutedTextColor: mutedTextColorField.text
    property alias cfg_customAccentColor: accentColorField.text
    property alias cfg_customInactiveColor: inactiveColorField.text

    readonly property bool customThemeSelected: cfg_themeMode === "custom"
    property var colorDialogTarget: null

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

    function colorPreview(colorText, fallbackColor) {
        if (/^#[0-9a-fA-F]{6}$/.test(colorText)) {
            return colorText;
        }
        return fallbackColor;
    }

    function hexPair(value) {
        const hex = Math.max(0, Math.min(255, Math.round(value * 255))).toString(16);
        return hex.length === 1 ? "0" + hex : hex;
    }

    function colorToHex(colorValue) {
        return "#" + hexPair(colorValue.r) + hexPair(colorValue.g) + hexPair(colorValue.b);
    }

    function openColorDialog(field, fallbackColor) {
        colorDialogTarget = field;
        colorDialog.selectedColor = /^#[0-9a-fA-F]{6}$/.test(field.text) ? field.text : fallbackColor;
        colorDialog.open();
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

    Dialogs.ColorDialog {
        id: colorDialog

        title: i18n("Seleccionar color")
        onAccepted: {
            if (page.colorDialogTarget) {
                page.colorDialogTarget.text = page.colorToHex(selectedColor);
            }
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Icono del panel:")
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

    QQC2.Label {
        Kirigami.FormData.label: ""
        text: i18n("Elige el icono que se muestra en la barra o panel de Plasma.")
        wrapMode: Text.WordWrap
        opacity: 0.75
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
        text: i18n("Elige el icono que aparece dentro del menu flotante del plasmoide.")
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

    // ############
    // Visual theme
    // ############
    ListModel {
        id: themeModeModel

        ListElement {
            label: "Automático"
            value: "auto"
        }
        ListElement {
            label: "Personalizado"
            value: "custom"
        }
    }

    QQC2.ComboBox {
        id: themeModeCombo

        Kirigami.FormData.label: i18n("Apariencia:")
        textRole: "label"
        valueRole: "value"
        model: themeModeModel
        Component.onCompleted: {
            for (let i = 0; i < themeModeModel.count; i++) {
                if (themeModeModel.get(i).value === page.cfg_themeMode) {
                    currentIndex = i;
                    return;
                }
            }
            currentIndex = 0;
        }
        onActivated: function(index) {
            page.cfg_themeMode = themeModeModel.get(index).value;
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Fondo:")
        enabled: page.customThemeSelected
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Layout.preferredWidth
            radius: Kirigami.Units.smallSpacing / 2
            color: page.colorPreview(backgroundColorField.text, Kirigami.Theme.backgroundColor)
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: page.openColorDialog(backgroundColorField, Kirigami.Theme.backgroundColor)
            }
        }

        QQC2.TextField {
            id: backgroundColorField

            Layout.fillWidth: true
            text: "auto"
            placeholderText: i18n("auto o #242a32")
            validator: RegularExpressionValidator {
                regularExpression: /^(auto|#[0-9a-fA-F]{6})$/
            }
        }

        QQC2.Button {
            text: i18n("Auto")
            onClicked: backgroundColorField.text = "auto"
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Texto principal:")
        enabled: page.customThemeSelected
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Layout.preferredWidth
            radius: Kirigami.Units.smallSpacing / 2
            color: page.colorPreview(textColorField.text, Kirigami.Theme.textColor)
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: page.openColorDialog(textColorField, Kirigami.Theme.textColor)
            }
        }

        QQC2.TextField {
            id: textColorField

            Layout.fillWidth: true
            text: "auto"
            placeholderText: i18n("auto o #f3f6f8")
            validator: RegularExpressionValidator {
                regularExpression: /^(auto|#[0-9a-fA-F]{6})$/
            }
        }

        QQC2.Button {
            text: i18n("Auto")
            onClicked: textColorField.text = "auto"
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Texto secundario:")
        enabled: page.customThemeSelected
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Layout.preferredWidth
            radius: Kirigami.Units.smallSpacing / 2
            color: page.colorPreview(mutedTextColorField.text, Kirigami.Theme.disabledTextColor)
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: page.openColorDialog(mutedTextColorField, Kirigami.Theme.disabledTextColor)
            }
        }

        QQC2.TextField {
            id: mutedTextColorField

            Layout.fillWidth: true
            text: "auto"
            placeholderText: i18n("auto o #7f8994")
            validator: RegularExpressionValidator {
                regularExpression: /^(auto|#[0-9a-fA-F]{6})$/
            }
        }

        QQC2.Button {
            text: i18n("Auto")
            onClicked: mutedTextColorField.text = "auto"
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Color ON:")
        enabled: page.customThemeSelected
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Layout.preferredWidth
            radius: Kirigami.Units.smallSpacing / 2
            color: page.colorPreview(accentColorField.text, Kirigami.Theme.positiveTextColor)
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: page.openColorDialog(accentColorField, Kirigami.Theme.positiveTextColor)
            }
        }

        QQC2.TextField {
            id: accentColorField

            Layout.fillWidth: true
            text: "auto"
            placeholderText: i18n("auto o #2fbf71")
            validator: RegularExpressionValidator {
                regularExpression: /^(auto|#[0-9a-fA-F]{6})$/
            }
        }

        QQC2.Button {
            text: i18n("Auto")
            onClicked: accentColorField.text = "auto"
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Color OFF:")
        enabled: page.customThemeSelected
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Layout.preferredWidth
            radius: Kirigami.Units.smallSpacing / 2
            color: page.colorPreview(inactiveColorField.text, Kirigami.Theme.disabledTextColor)
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: page.openColorDialog(inactiveColorField, Kirigami.Theme.disabledTextColor)
            }
        }

        QQC2.TextField {
            id: inactiveColorField

            Layout.fillWidth: true
            text: "auto"
            placeholderText: i18n("auto o #7b828c")
            validator: RegularExpressionValidator {
                regularExpression: /^(auto|#[0-9a-fA-F]{6})$/
            }
        }

        QQC2.Button {
            text: i18n("Auto")
            onClicked: inactiveColorField.text = "auto"
        }
    }

    QQC2.Button {
        Kirigami.FormData.label: ""
        text: i18n("Restablecer apariencia")
        icon.name: "edit-reset"
        onClicked: {
            page.cfg_themeMode = "auto";
            themeModeCombo.currentIndex = 0;
            backgroundColorField.text = "auto";
            textColorField.text = "auto";
            mutedTextColorField.text = "auto";
            accentColorField.text = "auto";
            inactiveColorField.text = "auto";
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
