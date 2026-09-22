import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "justin.ankerctl"

    property bool popupOpen: false
    property bool installed: false
    property bool running: false
    property bool enabled: false
    property bool busy: false
    property string statusText: "Checking..."
    property string serviceUrl: "http://127.0.0.1:4470"

    function close() { popupOpen = false }

    function refreshStatus() {
        if (statusProcess.running) return
        statusProcess.running = true
    }

    function runAction(action) {
        if (controlProcess.running) return
        busy = true
        controlProcess.command = [Quickshell.env("HOME") + "/.local/bin/omarchy-ankerctl", action]
        controlProcess.running = true
    }

    function applyStatus(raw) {
        try {
            var parsed = JSON.parse(String(raw || "{}"))
            installed = parsed.installed === true
            running = parsed.running === true
            enabled = parsed.enabled === true
            statusText = String(parsed.status || (running ? "Running" : "Stopped"))
            serviceUrl = String(parsed.url || "http://127.0.0.1:4470")
        } catch (error) {
            statusText = "Status unavailable"
        }
    }

    Component.onCompleted: refreshStatus()
    onPopupOpenChanged: if (popupOpen) refreshStatus()

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    BarIconButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        tooltipText: "Ankerctl - " + root.statusText
        active: root.popupOpen || root.running
        useActiveColor: true
        activeColor: root.running ? Color.accent : root.bar.foreground
        onPressed: function(mouseButton) {
            if (mouseButton === Qt.LeftButton) root.popupOpen = !root.popupOpen
            else if (mouseButton === Qt.RightButton) root.runAction(root.running || root.enabled ? "off" : "on")
        }
        iconComponent: Component {
            Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.78
                    height: parent.height * 0.58
                    radius: 2
                    color: "transparent"
                    border.color: button.foreground
                    border.width: 1.5
                }
                Rectangle {
                    x: parent.width * 0.24
                    y: parent.height * 0.18
                    width: parent.width * 0.52
                    height: parent.height * 0.1
                    radius: 1
                    color: button.foreground
                    opacity: 0.85
                }
                Rectangle {
                    x: parent.width * 0.32
                    y: parent.height * 0.54
                    width: parent.width * 0.36
                    height: parent.height * 0.08
                    radius: 1
                    color: root.running ? Color.accent : button.foreground
                    opacity: root.running ? 1.0 : 0.45
                }
            }
        }
    }

    PopupCard {
        id: popup
        anchorItem: button
        bar: root.bar
        owner: root
        open: root.popupOpen
        contentWidth: popup.fittedContentWidth(Style.space(340))
        contentHeight: popup.fittedContentHeight(column.implicitHeight)

        Column {
            id: column
            anchors.fill: parent
            spacing: Style.space(12)

            Text {
                text: "Ankerctl"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.title
                font.bold: true
            }

            Text {
                width: parent.width
                text: root.statusText + " - " + root.serviceUrl
                color: Qt.darker(root.bar.foreground, 1.35)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.body
                wrapMode: Text.WordWrap
            }

            Toggle {
                width: parent.width
                label: "OrcaSlicer bridge"
                description: root.running ? "Available at 127.0.0.1:4470" : "Stopped and disabled"
                checked: root.running || root.enabled
                enabled: root.installed && !root.busy
                onClicked: root.runAction(root.running || root.enabled ? "off" : "on")
            }

            Button {
                width: parent.width
                text: "Open web UI"
                enabled: root.running
                onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/omarchy-ankerctl", "open"])
            }

            Button {
                width: parent.width
                text: "Open OrcaSlicer"
                onClicked: Quickshell.execDetached(["uwsm-app", "--", "gtk-launch", "orcaslicer"])
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: root.refreshStatus()
    }

    Process {
        id: statusProcess
        command: [Quickshell.env("HOME") + "/.local/bin/omarchy-ankerctl", "status"]
        stdout: StdioCollector { id: statusOutput }
        onExited: {
            if (exitCode === 0) root.applyStatus(statusOutput.text)
            root.busy = false
        }
    }

    Process {
        id: controlProcess
        command: []
        stdout: StdioCollector { id: controlOutput }
        onExited: {
            if (exitCode === 0) root.applyStatus(controlOutput.text)
            root.busy = false
            root.refreshStatus()
        }
    }
}
