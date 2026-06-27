/*
 * SPDX-FileCopyrightText: 2026 Punchisoft
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Rectangle {
    id: control

    property bool checked: false
    property color accentColor: "#2fbf71"
    property color inactiveColor: "#7b828c"
    property color surfaceColor: Kirigami.Theme.backgroundColor
    property color knobColor: Kirigami.Theme.textColor
    property string onText: "ON"
    property string offText: "OFF"

    signal clicked()

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
    radius: height / 2
    color: !enabled
        ? Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, 0.55)
        : mouse.containsMouse
            ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.24)
            : Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.16)
    border.color: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, enabled ? 0.68 : 0.25)
    border.width: 1
    opacity: enabled ? 1 : 0.55

    readonly property color activeColor: checked ? accentColor : inactiveColor

    Rectangle {
        id: knob

        width: parent.height - Kirigami.Units.smallSpacing
        height: width
        radius: width / 2
        y: Kirigami.Units.smallSpacing / 2
        x: control.checked ? parent.width - width - y : y
        color: control.knobColor
        border.color: Qt.rgba(control.activeColor.r, control.activeColor.g, control.activeColor.b, 0.24)
        border.width: 1

        Behavior on x {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.gridUnit * 2.15
        anchors.rightMargin: Kirigami.Units.gridUnit * 0.65
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: control.checked ? control.onText : control.offText
            color: control.activeColor
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        enabled: control.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: control.clicked()
    }
}
