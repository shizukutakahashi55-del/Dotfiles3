import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool isOpen: true

    PanelWindow {
        id: panel
        screen: Quickshell.screens[0]
        anchors { left: true; top: true; bottom: true }
        
        width: isOpen ? 440 : 0
        color: "transparent"
        exclusiveZone: 0

        Behavior on width {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: panel_bg
            clip: true
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 0
            color: "#11111b"
            border.color: "#cba6f755"
            border.width: 2
            radius: 16
            opacity: isOpen ? 1.0 : 0.0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "WALLS"
                        font.pixelSize: 20; font.bold: true; font.letterSpacing: 4
                        color: "#cba6f7"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: wallpaperModel.count + " walls"
                        font.pixelSize: 10; color: "#6c7086"
                    }
                    Item { width: 10 }
                    Rectangle {
                        width: 28; height: 28; radius: 8
                        color: closeHover.containsMouse ? "#313244" : "transparent"
                        Text {
                            anchors.centerIn: parent; text: "󰅖"; font.pixelSize: 16
                            color: closeHover.containsMouse ? "#f38ba8" : "#585b70"
                        }
                        MouseArea {
                            id: closeHover; anchors.fill: parent; hoverEnabled: true
                            onClicked: root.isOpen = false
                        }
                    }
                }

                // Grid
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    GridView {
                        id: wallGrid
                        width: parent.width
                        cellWidth: (width - 8) / 2
                        cellHeight: cellWidth * (9.0 / 16.0) + 4
                        model: wallpaperModel
                        clip: true
                        interactive: true

                        delegate: Item {
                            width: wallGrid.cellWidth
                            height: wallGrid.cellHeight
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                color: "#181825"
                                radius: 10
                                clip: true
                                border.color: cardMa.containsMouse ? "#cba6f7" : "#313244"
                                border.width: 2

                                Image {
                                    id: thumb
                                    anchors.fill: parent
                                    source: "file://" + model.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    opacity: status === Image.Ready ? 1.0 : 0.0
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    height: 22; anchors.left: parent.left; anchors.right: parent.right
                                    color: "#000000bb"
                                    Text {
                                        anchors.fill: parent; anchors.margins: 6
                                        verticalAlignment: Text.AlignVCenter
                                        text: model.name.replace(/\.[^.]+$/, "")
                                        color: "#a6adc8"; font.pixelSize: 9; elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: cardMa; anchors.fill: parent; hoverEnabled: true
                                    onClicked: {
                                        confirmPopup.wallPath = model.path
                                        confirmPopup.wallName = model.name
                                        confirmPopup.visible = true
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    id: statusText
                    Layout.fillWidth: true
                    text: "✓ " + wallpaperModel.count + " wallpapers listos"
                    color: "#45475a"; font.pixelSize: 9
                }
            }

            // Popup de Confirmación
            Rectangle {
                id: confirmPopup
                visible: false
                property string wallPath: ""
                property string wallName: ""
                anchors.centerIn: parent
                width: parent.width - 40
                height: confirmCol.implicitHeight + 32
                color: "#1e1e2e"; border.color: "#cba6f7"; border.width: 2; radius: 14; z: 99

                Column {
                    id: confirmCol
                    anchors.centerIn: parent; width: parent.width - 32; spacing: 12
                    Image {
                        width: parent.width; height: Math.round(width * 9.0 / 16.0)
                        source: confirmPopup.visible ? ("file://" + confirmPopup.wallPath) : ""
                        fillMode: Image.PreserveAspectCrop
                    }
                    Text {
                        width: parent.width; text: "¿Aplicar este wallpaper?"; color: "#cdd6f4"
                        font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter
                    }
                    Row {
                        width: parent.width; spacing: 10
                        Rectangle {
                            width: (parent.width - 10) / 2; height: 34; color: "#313244"; radius: 8
                            Text { anchors.centerIn: parent; text: "Cancelar"; color: "#a6adc8" }
                            MouseArea { anchors.fill: parent; onClicked: confirmPopup.visible = false }
                        }
                        Rectangle {
                            width: (parent.width - 10) / 2; height: 34; color: "#cba6f7"; radius: 8
                            Text { anchors.centerIn: parent; text: "✓ Aplicar"; color: "#1e1e2e"; font.bold: true }
                            MouseArea {
                                id: applyMa; anchors.fill: parent
                                onClicked: {
                                    applyWallpaper.wpPath = confirmPopup.wallPath
                                    applyWallpaper.running = true
                                    statusText.text = "⏳ Procesando..."
                                    confirmPopup.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // PROCESO UNIFICADO: Evita Error 1 y guarda Cache
    Process {
        id: applyWallpaper
        property string wpPath: ""
        // Explicación del comando:
        // 1. Intenta preload (si ya existe, el || true evita que falle)
        // 2. Cambia el wallpaper
        // 3. Escribe la ruta en el cache para la próxima sesión
        command: ["bash", "-c", 
            "hyprctl hyprpaper preload '" + wpPath + "' || true; " + 
            "hyprctl hyprpaper wallpaper '," + wpPath + "'; " +
            "echo '" + wpPath + "' > /home/rinooze/.cache/hyprpaper-last"
        ]
        running: false
        onExited: (code) => {
            statusText.text = code === 0
                ? "✓ Aplicado: " + wpPath.split("/").pop()
                : "✗ Fallo en hyprctl (Código " + code + ")"
        }
    }

    ListModel { id: wallpaperModel }

    Process {
        id: loadWalls
        command: ["bash", "-c", "find /home/rinooze/Pictures/Wallpapers -maxdepth 1 -type f | sort | grep -iE '\\.(jpg|jpeg|png|webp|gif)$'"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                const p = line.trim()
                if (p !== "") wallpaperModel.append({ "name": p.split("/").pop(), "path": p })
            }
        }
    }
}