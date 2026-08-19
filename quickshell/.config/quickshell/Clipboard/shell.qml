import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: window
    width: 650
    height: 500
    color: "transparent"

    // لجعل النافذة تظهر في المنتصف بالنسبة لشاشات Wayland
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // إشارة لإغلاق النافذة عند الضغط على Escape
    Shortcut {
        sequence: "Escape"
        onActivated: Qt.quit()
    }

    Rectangle {
        anchors.centerIn: parent
        width: 620
        height: 460
        color: "#1e1e2e"
        radius: 16
        border.color: "#89b4fa"
        border.width: 1

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            clip: true

            model: clipModel

            delegate: Rectangle {
                required property var modelData
                width: listView.width
                height: 64
                color: mouseArea.containsMouse ? "#45475a" : "#313244"
                radius: 10

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 14

                    Image {
                        width: 44
                        height: 44
                        anchors.verticalCenter: parent.verticalCenter
                        source: "file:///tmp/cliphist/" + modelData.id + ".png"
                        fillMode: Image.PreserveAspectFit
                        visible: status === Image.Ready
                    }

                    Text {
                        text: modelData.text
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        width: parent.width - (modelData.isImage ? 60 : 10)
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        copyProcess.command = ["sh", "-c", "cliphist decode " + modelData.id + " | wl-copy"]
                        copyProcess.running = true
                    }
                }
            }
        }
    }

    // Process لتسجيل القائمة من cliphist
    Process {
        id: cliphistProcess
        command: ["sh", "-c", "cliphist list"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const lines = data.trim().split("\n");
                const items = [];
                for (let line of lines) {
                    if (!line) continue;
                    const parts = line.split("\t");
                    const id = parts[0];
                    const text = parts.slice(1).join("\t");
                    const isImage = text.includes("[[ binary data");
                    items.push({ id: id, text: text, isImage: isImage });
                }
                clipModel.append(items);
            }
        }
    }

    ListModel {
        id: clipModel
    }

    Process {
        id: copyProcess
        onExited: Qt.quit()
    }
}
