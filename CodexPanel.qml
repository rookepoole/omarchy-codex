import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Optional Omarchy Quattro surface for the separately installed graphical app.
// This widget owns no package, authentication, rendering, or keybinding state.
// Removing it therefore cannot remove or reconfigure omarchy-codex.
Panel {
  id: root

  moduleName: "io.github.rookepoole.omarchy-codex"
  ipcTarget: "io.github.rookepoole.omarchy-codex"

  readonly property color foreground: bar ? bar.barForeground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.45)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property bool installed: false
  property bool refreshing: false
  property string integrationVersion: ""
  property string packageVersion: ""
  property string appVersion: ""
  property string statusOutput: ""
  property int selectedAction: 0

  readonly property var actions: installed ? [
    { key: "launch", icon: "󰚩", label: "Launch graphical Codex" },
    { key: "update", icon: "󰑐", label: "Update Omarchy Codex" },
    { key: "doctor", icon: "󰒓", label: "Run diagnostics" },
    { key: "docs", icon: "󰈙", label: "Open documentation" }
  ] : [
    { key: "install", icon: "󰋼", label: "Open installation instructions" },
    { key: "refresh", icon: "󰑐", label: "Check again" }
  ]

  function valueAfterPrefix(line, prefix) {
    return line.indexOf(prefix) === 0 ? line.slice(prefix.length).trim() : ""
  }

  function readStatus(raw) {
    var lines = String(raw || "").split("\n")
    integrationVersion = ""
    packageVersion = ""
    appVersion = ""
    for (var i = 0; i < lines.length; i++) {
      var value = valueAfterPrefix(lines[i], "Omarchy integration:")
      if (value !== "") integrationVersion = value
      value = valueAfterPrefix(lines[i], "Pacman package:")
      if (value !== "") packageVersion = value
      value = valueAfterPrefix(lines[i], "OpenAI app:")
      if (value !== "") appVersion = value
    }
    installed = integrationVersion !== "" && integrationVersion !== "unknown"
  }

  function refresh() {
    if (statusProc.running) return
    refreshing = true
    statusOutput = ""
    statusProc.running = true
  }

  function moveSelection(delta) {
    if (actions.length === 0) return
    selectedAction = Math.max(0, Math.min(actions.length - 1, selectedAction + delta))
  }

  function activate(action) {
    if (!action || !bar) return
    switch (action.key) {
      case "launch":
        bar.run("omarchy-codex launch")
        close()
        break
      case "update":
        bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-codex update")
        close()
        break
      case "doctor":
        bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-codex doctor")
        close()
        break
      case "docs":
      case "install":
        bar.run("xdg-open https://github.com/rookepoole/omarchy-codex")
        close()
        break
      case "refresh":
        refresh()
        break
    }
  }

  function activateSelected() {
    if (selectedAction >= 0 && selectedAction < actions.length)
      activate(actions[selectedAction])
  }

  onInstalledChanged: selectedAction = 0
  onOpenedChanged: if (opened) {
    selectedAction = 0
    refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }
  Component.onCompleted: refresh()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: [
      "bash",
      "-lc",
      "command -v omarchy-codex >/dev/null 2>&1 && exec omarchy-codex version"
    ]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.statusOutput = text
        root.readStatus(text)
      }
    }
    onExited: function(exitCode) {
      root.refreshing = false
      if (exitCode !== 0) {
        root.installed = false
        root.integrationVersion = ""
        root.packageVersion = ""
        root.appVersion = ""
      }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰚩"
    active: root.opened
    tooltipText: root.installed
      ? "Codex " + (root.appVersion || root.integrationVersion)
      : "Codex app is not installed"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton && root.installed) root.activate({ key: "launch" })
      else if (buttonCode === Qt.MiddleButton) root.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) { root.moveSelection(dy !== 0 ? dy : dx) }
      onActivateRequested: root.activateSelected()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === "r" || text === "R") root.refresh()
      }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(14)

        PanelHero {
          width: parent.width
          title: "Codex"
          meta: root.refreshing
            ? "CHECKING INSTALLATION"
            : (root.installed ? "GRAPHICAL APP READY" : "APP NOT INSTALLED")
          detail: root.integrationVersion === "" ? "" : "v" + root.integrationVersion
          foreground: root.foreground
          fontFamily: root.fontFamily
          iconComponent: Component {
            Text {
              text: "󰚩"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.display
            }
          }
        }

        PanelSeparator {
          width: parent.width
          foreground: root.foreground
        }

        Column {
          width: parent.width
          spacing: Style.space(7)

          PanelSectionHeader {
            text: "INSTALLATION"
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          InfoPair {
            label: "Integration"
            value: root.installed ? root.integrationVersion : "Not installed"
          }
          InfoPair {
            visible: root.installed
            label: "Pacman package"
            value: root.packageVersion || "Unknown"
          }
          InfoPair {
            visible: root.installed
            label: "OpenAI app"
            value: root.appVersion || "Unknown"
          }
        }

        Text {
          visible: !root.installed && !root.refreshing
          width: parent.width
          text: "This optional panel never installs or removes the app. Follow the repository instructions, then press Check again."
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          wrapMode: Text.WordWrap
        }

        PanelSeparator {
          width: parent.width
          foreground: root.foreground
        }

        Column {
          width: parent.width
          spacing: Style.space(6)

          Repeater {
            model: root.actions

            Button {
              required property var modelData
              required property int index
              width: parent.width
              text: modelData.label
              iconText: modelData.icon
              leftAlign: true
              bordered: true
              hasCursor: root.selectedAction === index
              foreground: root.foreground
              fontFamily: root.fontFamily
              onClicked: {
                root.selectedAction = index
                root.activate(modelData)
              }
              onHovered: function(isHovered) {
                if (isHovered) root.selectedAction = index
              }
            }
          }
        }

        Text {
          width: parent.width
          text: "j/k select · Enter open · r refresh · Esc close"
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }

  component InfoPair: Row {
    property string label: ""
    property string value: ""

    width: parent.width
    spacing: Style.space(8)

    Text {
      text: parent.label
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
    Item {
      width: Math.max(0, parent.width - parent.children[0].implicitWidth
        - parent.children[2].implicitWidth - parent.spacing * 2)
      height: 1
    }
    Text {
      text: parent.value
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
  }
}
