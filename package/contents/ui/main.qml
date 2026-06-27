/*
 * SPDX-FileCopyrightText: 2026 Punchisoft
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // ################
    // Backend commands
    // ################
    readonly property string helperBase: "/usr/local/libexec/switch-turbo-boost-plasmoid"
    readonly property string statusCommand: helperBase + "/get-turbo-status.sh"
    readonly property string cpuInfoCommand: helperBase + "/get-cpu-info.sh"
    readonly property string vendorCommand: helperBase + "/get-cpu-vendor.sh"
    readonly property string onCommand: "pkexec " + helperBase + "/set-turbo-on.sh"
    readonly property string offCommand: "pkexec " + helperBase + "/set-turbo-off.sh"
    readonly property bool inPanel: [
        PlasmaCore.Types.TopEdge,
        PlasmaCore.Types.RightEdge,
        PlasmaCore.Types.BottomEdge,
        PlasmaCore.Types.LeftEdge,
    ].includes(Plasmoid.location)

    // #############
    // Runtime state
    // #############
    property bool turboOn: false
    property bool available: false
    property bool actionRunning: false
    property string statusText: root.t("Comprobando...", "Checking...")
    property string detailText: ""
    property string cpuVendor: "unknown"
    property string cpuModelName: ""
    property string lastReadText: root.t("Pendiente", "Pending")

    // ############
    // Visual tokens
    // ############
    readonly property string themeMode: Plasmoid.configuration.themeMode || "auto"
    readonly property bool customTheme: themeMode === "custom"
    readonly property color popupBackgroundColor: customTheme ? root.safeColor(Plasmoid.configuration.customBackgroundColor, Kirigami.Theme.backgroundColor) : Kirigami.Theme.backgroundColor
    readonly property color primaryTextColor: customTheme ? root.safeColor(Plasmoid.configuration.customTextColor, Kirigami.Theme.textColor) : Kirigami.Theme.textColor
    readonly property color secondaryTextColor: customTheme ? root.safeColor(Plasmoid.configuration.customMutedTextColor, Kirigami.Theme.disabledTextColor) : Kirigami.Theme.disabledTextColor
    readonly property color subtleTextColor: root.withAlpha(primaryTextColor, 0.66)
    readonly property color onColor: customTheme ? root.safeColor(Plasmoid.configuration.customAccentColor, Kirigami.Theme.positiveTextColor) : Kirigami.Theme.positiveTextColor
    readonly property color offColor: customTheme ? root.safeColor(Plasmoid.configuration.customInactiveColor, Kirigami.Theme.disabledTextColor) : Kirigami.Theme.disabledTextColor
    readonly property color unavailableColor: Kirigami.Theme.disabledTextColor
    readonly property color accentColor: available ? (turboOn ? onColor : offColor) : unavailableColor
    readonly property color indicatorColor: available ? accentColor : Kirigami.Theme.disabledTextColor
    readonly property string uiLanguage: Plasmoid.configuration.uiLanguage || "auto"
    readonly property int popupConfiguredWidth: Math.max(Kirigami.Units.gridUnit * 12, Number(Plasmoid.configuration.preferredPopupWidth || 252))
    readonly property int popupConfiguredHeight: Math.max(Kirigami.Units.gridUnit * 10, Number(Plasmoid.configuration.preferredPopupHeight || 466))
    readonly property string effectiveUiLanguage: {
        if (uiLanguage === "es" || uiLanguage === "en") {
            return uiLanguage;
        }

        const localeName = Qt.locale().name.toLowerCase();
        if (localeName.startsWith("en")) {
            return "en";
        }
        return "es";
    }
    readonly property string stateLabel: available ? (turboOn ? root.t("ON", "ON") : root.t("OFF", "OFF")) : root.t("N/D", "N/A")
    readonly property string stateDescription: available
        ? (turboOn ? root.t("Permite mayor rendimiento cuando el sistema lo requiere.", "Allows higher performance when the system needs it.")
                   : root.t("Prioriza temperatura, ruido y consumo energetico.", "Prioritizes temperature, noise, and power consumption."))
        : root.t("No se encontro un control de boost compatible en este equipo.", "No compatible boost control was found on this computer.")
    readonly property string vendorText: {
        if (cpuVendor === "amd") {
            return root.t("AMD detectado", "AMD detected");
        }
        if (cpuVendor === "intel") {
            return root.t("Intel detectado", "Intel detected");
        }
        return root.t("CPU detectada", "CPU detected");
    }
    readonly property string boostTechnologyText: {
        if (cpuVendor === "amd") {
            return root.t("Precision Boost / Core Performance Boost", "Precision Boost / Core Performance Boost");
        }
        if (cpuVendor === "intel") {
            return root.t("Turbo Boost", "Turbo Boost");
        }
        return root.t("CPU Boost", "CPU Boost");
    }
    readonly property string boostTechnologyLabel: root.t("Tecnologia: ", "Technology: ") + root.boostTechnologyText

    // ##############
    // Icon selection
    // ##############
    readonly property string iconStyle: Plasmoid.configuration.iconStyle || "cpu"
    readonly property string processorIconStyle: Plasmoid.configuration.processorIconStyle || "auto"
    readonly property var panelIcon: root.iconSource(iconStyle)
    readonly property var processorIcon: root.processorIconSource(processorIconStyle)

    function iconSource(style) {
        if (style === "project-chip" || style === "chip") {
            return Qt.resolvedUrl("../images/turbo-chip.svg");
        }
        if (style === "bolt") {
            return "flash-symbolic";
        }
        if (style === "gauge") {
            return "speedometer";
        }
        if (style === "performance") {
            return "power-profile-performance-symbolic";
        }
        if (style === "systemmonitor-cpu") {
            return "org.kde.plasma.systemmonitor.cpu";
        }
        if (style === "cpu") {
            return "cpu";
        }
        if (style === "flash") {
            return "flash-symbolic";
        }
        if (style === "speedometer") {
            return "speedometer";
        }
        return style;
    }

    function processorIconSource(style) {
        const normalizedStyle = style && style.length > 0 ? style : "auto";
        const resolvedStyle = normalizedStyle === "auto" ? cpuVendor : normalizedStyle;
        if (resolvedStyle === "amd") {
            return Qt.resolvedUrl("../images/vendor-amd.svg");
        }
        if (resolvedStyle === "intel") {
            return Qt.resolvedUrl("../images/vendor-intel.svg");
        }
        if (resolvedStyle === "project-chip") {
            return Qt.resolvedUrl("../images/turbo-chip.svg");
        }
        if (resolvedStyle === "cpu" || resolvedStyle === "unknown") {
            return Qt.resolvedUrl("../images/vendor-cpu.svg");
        }
        return root.iconSource(resolvedStyle);
    }

    Plasmoid.icon: inPanel ? "cpu-symbolic" : "cpu"
    Plasmoid.status: available ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.busy: actionRunning
    preferredRepresentation: compactRepresentation
    switchWidth: popupConfiguredWidth
    switchHeight: popupConfiguredHeight

    // ################
    // Text helper
    // ################
    function t(es, en) {
        if (effectiveUiLanguage === "es") {
            return es;
        }
        if (effectiveUiLanguage === "en") {
            return en;
        }
        return es;
    }

    function withAlpha(colorValue, alpha) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, alpha);
    }

    function safeColor(colorText, fallbackColor) {
        const normalized = String(colorText || "");
        if (normalized.toLowerCase() === "auto") {
            return fallbackColor;
        }
        if (/^#[0-9a-fA-F]{6}$/.test(normalized)) {
            return normalized;
        }
        return fallbackColor;
    }

    // ################
    // Command handling
    // ################
    function exitCode(data) {
        if (data["exit code"] !== undefined) {
            return Number(data["exit code"]);
        }
        if (data["exitCode"] !== undefined) {
            return Number(data["exitCode"]);
        }
        return 0;
    }

    function outputText(data, key) {
        const value = data[key] || "";
        return String(value).trim();
    }

    function refreshStatus() {
        executable.connectSource(statusCommand);
    }

    function refreshVendor() {
        executable.connectSource(cpuInfoCommand);
    }

    function valueFromOutput(stdout, key) {
        const lines = stdout.split("\n");
        const prefix = key + "=";
        for (let index = 0; index < lines.length; index += 1) {
            if (lines[index].startsWith(prefix)) {
                return lines[index].slice(prefix.length).trim();
            }
        }
        return "";
    }

    function setStatusFromOutput(stdout, stderr, code) {
        if (code !== 0) {
            available = false;
            statusText = root.boostTechnologyText + root.t(" no disponible", " unavailable");
            detailText = stderr || stdout;
            return;
        }

        const normalized = stdout.toLowerCase();
        if (normalized === "on") {
            turboOn = true;
            available = true;
            statusText = root.boostTechnologyText + " " + root.t("ON", "ON");
            detailText = "";
            lastReadText = root.t("ahora", "now");
        } else if (normalized === "off") {
            turboOn = false;
            available = true;
            statusText = root.boostTechnologyText + " " + root.t("OFF", "OFF");
            detailText = "";
            lastReadText = root.t("ahora", "now");
        } else {
            available = false;
            statusText = root.t("Estado desconocido", "Unknown status");
            detailText = stdout || stderr;
            lastReadText = root.t("ahora", "now");
        }
    }

    function toggleTurbo() {
        if (!available || actionRunning) {
            return;
        }

        actionRunning = true;
        statusText = turboOn ? root.t("Apagando...", "Turning off...") : root.t("Encendiendo...", "Turning on...");
        executable.connectSource(turboOn ? offCommand : onCommand);
    }

    Plasma5Support.DataSource {
        id: executable

        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            const stdout = root.outputText(data, "stdout");
            const stderr = root.outputText(data, "stderr");
            const code = root.exitCode(data);

            executable.disconnectSource(sourceName);

            // The executable datasource multiplexes status, vendor detection and toggle commands.
            if (sourceName === root.statusCommand) {
                root.setStatusFromOutput(stdout, stderr, code);
                return;
            }

            if (sourceName === root.cpuInfoCommand) {
                if (code !== 0) {
                    executable.connectSource(root.vendorCommand);
                    return;
                }
                const normalizedVendor = root.valueFromOutput(stdout, "vendor").toLowerCase();
                root.cpuVendor = ["amd", "intel"].includes(normalizedVendor) ? normalizedVendor : "unknown";
                root.cpuModelName = root.valueFromOutput(stdout, "model");
                if (root.available && !root.actionRunning) {
                    root.statusText = root.boostTechnologyText + " " + (root.turboOn ? root.t("ON", "ON") : root.t("OFF", "OFF"));
                }
                return;
            }

            if (sourceName === root.vendorCommand) {
                const normalizedVendor = stdout.toLowerCase();
                root.cpuVendor = ["amd", "intel"].includes(normalizedVendor) ? normalizedVendor : "unknown";
                if (root.available && !root.actionRunning) {
                    root.statusText = root.boostTechnologyText + " " + (root.turboOn ? root.t("ON", "ON") : root.t("OFF", "OFF"));
                }
                return;
            }

            root.actionRunning = false;
            if (code !== 0) {
                root.statusText = root.t("Accion cancelada o sin permisos", "Action canceled or permission denied");
                root.detailText = stderr || stdout;
            }
            root.refreshStatus();
        }
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
    }

    Component.onCompleted: {
        root.refreshStatus();
        root.refreshVendor();
    }

    // #############
    // Panel icon
    // #############
    compactRepresentation: MouseArea {
        id: compact

        Layout.minimumWidth: Kirigami.Units.gridUnit * 2
        Layout.minimumHeight: Kirigami.Units.gridUnit * 2
        implicitWidth: Kirigami.Units.gridUnit * 2
        implicitHeight: Kirigami.Units.gridUnit * 2
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        Rectangle {
            id: iconBackground

            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) - Kirigami.Units.smallSpacing
            height: width
            radius: Kirigami.Units.smallSpacing
            color: compact.containsMouse || root.expanded ? root.withAlpha(root.accentColor, 0.16) : "transparent"
            border.color: root.withAlpha(root.accentColor, root.available ? 0.62 : 0.28)
            border.width: 1

            Kirigami.Icon {
                anchors.centerIn: parent
                width: parent.width * 0.68
                height: width
                source: root.panelIcon
                color: root.available ? root.indicatorColor : Kirigami.Theme.disabledTextColor
                opacity: root.available ? 1 : 0.55
            }

            Rectangle {
                width: Kirigami.Units.smallSpacing
                height: width
                radius: width / 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 1
                color: root.indicatorColor
                border.color: root.withAlpha(root.primaryTextColor, 0.22)
                border.width: 1
            }
        }
    }

    // ############
    // Popup card
    // ############
    fullRepresentation: PlasmaExtras.Representation {
        Layout.minimumWidth: root.popupConfiguredWidth
        Layout.minimumHeight: root.popupConfiguredHeight
        Layout.preferredWidth: root.popupConfiguredWidth
        Layout.preferredHeight: root.popupConfiguredHeight
        Layout.maximumWidth: root.popupConfiguredWidth
        Layout.maximumHeight: root.popupConfiguredHeight
        implicitWidth: root.popupConfiguredWidth
        implicitHeight: root.popupConfiguredHeight
        width: root.popupConfiguredWidth
        height: root.popupConfiguredHeight
        collapseMarginsHint: true

        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.smallSpacing * 1.5
            color: root.popupBackgroundColor
            border.color: root.withAlpha(root.primaryTextColor, 0.12)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.gridUnit
                spacing: Kirigami.Units.smallSpacing * 1.3

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Rectangle {
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2.4
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2.4
                        radius: Kirigami.Units.smallSpacing
                        color: root.withAlpha(root.accentColor, 0.13)
                        border.color: root.withAlpha(root.accentColor, 0.36)
                        border.width: 1

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: parent.width * 0.7
                            height: width
                            source: root.processorIcon
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        PlasmaExtras.Heading {
                            Layout.fillWidth: true
                            level: 4
                            text: root.t("Switch Turbo Boost", "Switch Turbo Boost")
                            color: root.primaryTextColor
                            elide: Text.ElideRight
                        }

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: root.vendorText
                            color: root.subtleTextColor
                            elide: Text.ElideRight
                        }

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            visible: root.cpuModelName.length > 0
                            text: root.cpuModelName
                            color: root.secondaryTextColor
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Kirigami.Units.smallSpacing * 1.4
                        Layout.preferredHeight: Kirigami.Units.smallSpacing * 1.4
                        Layout.alignment: Qt.AlignTop
                        radius: width / 2
                        color: root.indicatorColor
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.withAlpha(root.primaryTextColor, 0.10)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        text: root.boostTechnologyLabel
                        color: root.subtleTextColor
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    TurboSwitch {
                        checked: root.turboOn && root.available
                        accentColor: root.onColor
                        inactiveColor: root.offColor
                        surfaceColor: root.popupBackgroundColor
                        knobColor: root.primaryTextColor
                        onText: root.t("ON", "ON")
                        offText: root.t("OFF", "OFF")
                        enabled: root.available && !root.actionRunning
                        onClicked: root.toggleTurbo()
                    }
                }

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: root.stateDescription
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    color: root.subtleTextColor
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Rectangle {
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 1.8
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.45
                        radius: Kirigami.Units.smallSpacing
                        color: refreshMouse.containsMouse ? root.withAlpha(root.primaryTextColor, 0.12) : root.withAlpha(root.primaryTextColor, 0.06)
                        border.color: root.withAlpha(root.primaryTextColor, 0.10)
                        border.width: 1
                        opacity: root.actionRunning ? 0.55 : 1

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: Kirigami.Units.iconSizes.small
                            height: width
                            source: "view-refresh-symbolic"
                            color: root.subtleTextColor
                        }

                        MouseArea {
                            id: refreshMouse

                            anchors.fill: parent
                            enabled: !root.actionRunning
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.refreshStatus();
                                root.refreshVendor();
                            }
                        }
                    }

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: root.t("Comprobar estado", "Check status")
                        color: root.secondaryTextColor
                        elide: Text.ElideRight
                    }

                    PlasmaComponents3.Label {
                        text: root.t("Ultima lectura: ", "Last read: ") + root.lastReadText
                        color: root.secondaryTextColor
                    }
                }

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    visible: root.detailText.length > 0
                    text: root.detailText
                    wrapMode: Text.WordWrap
                    color: root.subtleTextColor
                    opacity: 0.75
                }
            }
        }
    }
}
