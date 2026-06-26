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
    property string lastReadText: root.t("Pendiente", "Pending")

    // ############
    // Visual tokens
    // ############
    readonly property color onColor: "#2fbf71"
    readonly property color offColor: "#b56b6b"
    readonly property color unavailableColor: "#7b828c"
    readonly property color accentColor: available ? (turboOn ? onColor : offColor) : unavailableColor
    readonly property color indicatorColor: available ? accentColor : Kirigami.Theme.disabledTextColor
    readonly property string uiLanguage: Plasmoid.configuration.uiLanguage || "auto"
    readonly property string stateLabel: available ? (turboOn ? root.t("ON", "ON") : root.t("OFF", "OFF")) : root.t("N/D", "N/A")
    readonly property string stateDescription: available
        ? (turboOn ? root.t("Permite mayor rendimiento cuando el sistema lo requiere.", "Allows higher performance when the system needs it.")
                   : root.t("Prioriza temperatura, ruido y consumo energetico.", "Prioritizes temperature, noise, and power consumption."))
        : root.t("No se encontro un control de Turbo Boost compatible en este equipo.", "No compatible Turbo Boost control was found on this computer.")
    readonly property string vendorText: {
        if (cpuVendor === "amd") {
            return root.t("AMD detectado", "AMD detected");
        }
        if (cpuVendor === "intel") {
            return root.t("Intel detectado", "Intel detected");
        }
        return root.t("CPU detectada", "CPU detected");
    }

    // ##############
    // Icon selection
    // ##############
    readonly property string iconStyle: Plasmoid.configuration.iconStyle || "cpu"
    readonly property var popupIcon: {
        if (iconStyle === "project-chip" || iconStyle === "chip") {
            return Qt.resolvedUrl("../images/turbo-chip.svg");
        }
        if (iconStyle === "bolt") {
            return "flash-symbolic";
        }
        if (iconStyle === "gauge") {
            return "speedometer";
        }
        if (iconStyle === "performance") {
            return "power-profile-performance-symbolic";
        }
        if (iconStyle === "systemmonitor-cpu") {
            return "org.kde.plasma.systemmonitor.cpu";
        }
        if (iconStyle === "cpu") {
            return "cpu";
        }
        if (iconStyle === "flash") {
            return "flash-symbolic";
        }
        if (iconStyle === "speedometer") {
            return "speedometer";
        }
        return iconStyle;
    }

    Plasmoid.icon: inPanel ? "cpu-symbolic" : "cpu"
    Plasmoid.status: available ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.busy: actionRunning
    preferredRepresentation: compactRepresentation
    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 12

    // ################
    // Text helper
    // ################
    function t(es, en) {
        if (uiLanguage === "es") {
            return es;
        }
        if (uiLanguage === "en") {
            return en;
        }
        return i18n(es);
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
        executable.connectSource(vendorCommand);
    }

    function setStatusFromOutput(stdout, stderr, code) {
        if (code !== 0) {
            available = false;
            statusText = root.t("Turbo Boost no disponible", "Turbo Boost unavailable");
            detailText = stderr || stdout;
            return;
        }

        const normalized = stdout.toLowerCase();
        if (normalized === "on") {
            turboOn = true;
            available = true;
            statusText = root.t("Turbo Boost ON", "Turbo Boost ON");
            detailText = "";
            lastReadText = root.t("ahora", "now");
        } else if (normalized === "off") {
            turboOn = false;
            available = true;
            statusText = root.t("Turbo Boost OFF", "Turbo Boost OFF");
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

            if (sourceName === root.vendorCommand) {
                const normalizedVendor = stdout.toLowerCase();
                root.cpuVendor = ["amd", "intel"].includes(normalizedVendor) ? normalizedVendor : "unknown";
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
            color: compact.containsMouse || root.expanded ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.16) : "transparent"
            border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, root.available ? 0.62 : 0.28)
            border.width: 1

            Kirigami.Icon {
                anchors.centerIn: parent
                width: parent.width * 0.68
                height: width
                source: root.popupIcon
                color: root.available ? root.indicatorColor : "#8a949f"
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
                border.color: "#1a1f25"
                border.width: 1
            }
        }
    }

    // ############
    // Popup card
    // ############
    fullRepresentation: PlasmaExtras.Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 12
        collapseMarginsHint: true

        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.smallSpacing * 1.5
            border.color: Qt.rgba(1, 1, 1, 0.10)
            border.width: 1
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#242a32"
                }
                GradientStop {
                    position: 1
                    color: "#171b21"
                }
            }

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
                        color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.13)
                        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.36)
                        border.width: 1

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: parent.width * 0.7
                            height: width
                            source: root.popupIcon
                            color: root.indicatorColor
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        PlasmaExtras.Heading {
                            Layout.fillWidth: true
                            level: 4
                            text: root.t("Switch Turbo Boost", "Switch Turbo Boost")
                            color: "#f3f6f8"
                            elide: Text.ElideRight
                        }

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: root.vendorText
                            color: "#aab4bf"
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
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.t("Turbo Boost", "Turbo Boost")
                        color: "#c8d0d8"
                        font.bold: true
                    }

                    TurboSwitch {
                        checked: root.turboOn && root.available
                        accentColor: root.onColor
                        inactiveColor: root.offColor
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
                    color: "#aab4bf"
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
                        color: refreshMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.06)
                        border.color: Qt.rgba(1, 1, 1, 0.10)
                        border.width: 1
                        opacity: root.actionRunning ? 0.55 : 1

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: Kirigami.Units.iconSizes.small
                            height: width
                            source: "view-refresh-symbolic"
                            color: "#c8d0d8"
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
                        text: root.t("Estado actualizado", "Status updated")
                        color: "#7f8994"
                        elide: Text.ElideRight
                    }

                    PlasmaComponents3.Label {
                        text: root.lastReadText
                        color: "#7f8994"
                    }
                }

                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    visible: root.detailText.length > 0
                    text: root.detailText
                    wrapMode: Text.WordWrap
                    color: "#b7c0ca"
                    opacity: 0.75
                }
            }
        }
    }
}
