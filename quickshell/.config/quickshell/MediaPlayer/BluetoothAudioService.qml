import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var sinks: []
    property int currentSinkId: -1
    property bool loading: false
    property string errorMessage: ""
    property bool autoSwitchToBluetooth: true
    property var knownBluetoothIds: []

    signal bluetoothDeviceConnected(int sinkId)
    signal sinkFallback(int fromSinkId, int toSinkId)
    signal sinkChanged(int sinkId, string sinkName)

    // --- PUBLIC API ---
    function refreshSinks() {
        loading = true
        errorMessage = ""
        wpctlStatusProc.running = true
    }

    function setDefaultSink(sinkId) {
        if (sinkId === currentSinkId) return
        // Find sink name before switching
        var sinkName = ""
        for (var i = 0; i < sinks.length; i++) {
            if (sinks[i].id === sinkId) {
                sinkName = sinks[i].name
                break
            }
        }
        setDefaultProc.command = ["wpctl", "set-default", sinkId.toString()]
        setDefaultProc.sinkName = sinkName
        setDefaultProc.running = true
    }

    function setAutoSwitchToBluetooth(enabled) {
        autoSwitchToBluetooth = enabled
    }

    // --- INTERNAL: wpctl status parser ---
    Process {
        id: wpctlStatusProc
        command: ["wpctl", "status"]
        running: false

        stdout: StdioCollector {
            id: statusCollector
            onStreamFinished: {
                parseWpctlStatus(statusCollector.text)
            }
        }
    }

    Process {
        id: setDefaultProc
        command: ["wpctl", "set-default", "0"]
        running: false
        property string sinkName: ""

        stdout: StdioCollector {
            onStreamFinished: {
                if (setDefaultProc.exitCode === 0) {
                    currentSinkId = parseInt(setDefaultProc.command[2])
                    if (setDefaultProc.sinkName) {
                        sinkChanged(currentSinkId, setDefaultProc.sinkName)
                    }
                    refreshSinks() // Refresh to update UI with new default marker
                } else {
                    errorMessage = "Failed to set default sink"
                }
            }
        }
    }

    // Notification process for fallback alerts
    Process { id: notifyProc }

    function sendNotification(title, body) {
        notifyProc.command = [
            "notify-send", 
            "-h", "string:x-canonical-private-synchronous:media-player", 
            "-t", "3000", 
            "-u", "normal",
            title, 
            body
        ];
        notifyProc.running = true;
    }

    function parseWpctlStatus(output) {
        var lines = output.split("\n")
        var newSinks = []
        var inSinksSection = false
        var currentSinkId = -1
        var newBluetoothIds = []

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()

            // Detect section headers
            if (line.indexOf("Sinks:") !== -1 || line.indexOf("├─ Sinks:") !== -1 || line.indexOf("└─ Sinks:") !== -1) {
                inSinksSection = true
                continue
            }
            if (inSinksSection && (line.indexOf("Sources:") !== -1 || line.indexOf("├─ Sources:") !== -1 || line.indexOf("└─ Sources:") !== -1 ||
                                   line.indexOf("Filters:") !== -1 || line.indexOf("├─ Filters:") !== -1 || line.indexOf("└─ Filters:") !== -1 ||
                                   line.indexOf("Streams:") !== -1 || line.indexOf("├─ Streams:") !== -1 || line.indexOf("└─ Streams:") !== -1)) {
                inSinksSection = false
                continue
            }

            if (!inSinksSection) continue

            // Parse sink lines like: "│  *   55. Built-in Audio Analog Stereo        [vol: 1.00]"
            // or: "│      56. Bluetooth Headset                   [vol: 0.80]"
            // or with -n flag: "│  *   55. alsa_output.pci-0000_00_1b.0.analog-stereo [vol: 1.00]"
            var match = line.match(/[│└├]\s*(\*?)\s*(\d+)\.\s+(.+?)\s+\[vol:/)
            if (match) {
                var isDefault = match[1] === "*"
                var sinkId = parseInt(match[2])
                var sinkName = match[3].trim()
                var isBluetooth = sinkName.indexOf("bluez_output.") === 0

                // Clean up node names (alsa_output.pci-...) to be more readable
                if (sinkName.indexOf("alsa_output.") === 0 || sinkName.indexOf("bluez_output.") === 0) {
                    // Try to extract a readable name from the node name
                    var parts = sinkName.split(".")
                    if (parts.length > 2) {
                        // For alsa_output.pci-0000_00_1b.0.analog-stereo -> "Analog Stereo"
                        // For bluez_output.XX_XX_XX_XX_XX_XX.1 -> "Bluetooth Device"
                        if (sinkName.indexOf("bluez_output.") === 0) {
                            sinkName = "Bluetooth Device"
                        } else if (sinkName.indexOf("analog-stereo") !== -1) {
                            sinkName = "Built-in Audio Analog Stereo"
                        } else if (sinkName.indexOf("hdmi-stereo") !== -1) {
                            sinkName = "HDMI Audio"
                        }
                    }
                }

                newSinks.push({
                    id: sinkId,
                    name: sinkName,
                    isDefault: isDefault,
                    isBluetooth: isBluetooth
                })

                if (isDefault) {
                    currentSinkId = sinkId
                }

                if (isBluetooth) {
                    newBluetoothIds.push(sinkId)
                }
            }
        }

        // Check for newly connected Bluetooth devices
        var newlyConnected = []
        for (var j = 0; j < newBluetoothIds.length; j++) {
            var btId = newBluetoothIds[j]
            var known = false
            for (var k = 0; k < knownBluetoothIds.length; k++) {
                if (knownBluetoothIds[k] === btId) {
                    known = true
                    break
                }
            }
            if (!known) {
                newlyConnected.push(btId)
            }
        }

        // Check if current sink disappeared (e.g., Bluetooth disconnected)
        // Use local currentSinkId (parsed from * marker) instead of root.currentSinkId (may be -1 on first run)
        var effectiveCurrentSinkId = (root.currentSinkId !== -1) ? root.currentSinkId : currentSinkId
        var currentSinkStillExists = false
        for (var m = 0; m < newSinks.length; m++) {
            if (newSinks[m].id === effectiveCurrentSinkId) {
                currentSinkStillExists = true
                break
            }
        }

        // Update known Bluetooth IDs
        knownBluetoothIds = newBluetoothIds

        // If current sink disappeared, fall back to first available sink
        if (!currentSinkStillExists && newSinks.length > 0) {
            var fallbackSink = newSinks[0]
            // Prefer non-Bluetooth sink as fallback
            for (var f = 0; f < newSinks.length; f++) {
                if (!newSinks[f].isBluetooth) {
                    fallbackSink = newSinks[f]
                    break
                }
            }
            var oldSinkId = root.currentSinkId
            setDefaultSink(fallbackSink.id)
            sendNotification("Audio Output Changed", "Bluetooth disconnected — switched to " + fallbackSink.name)
            sinkFallback(oldSinkId, fallbackSink.id)
            return
        }

        // Auto-switch to newly connected Bluetooth device if enabled
        if (autoSwitchToBluetooth && newlyConnected.length > 0) {
            // Switch to the first newly connected Bluetooth device
            var btSink = null
            for (var b = 0; b < newSinks.length; b++) {
                if (newSinks[b].id === newlyConnected[0]) {
                    btSink = newSinks[b]
                    break
                }
            }
            setDefaultSink(newlyConnected[0])
            if (btSink) {
                sendNotification("Audio Output Changed", "Switched to " + btSink.name)
            }
            // Note: setDefaultSink will trigger refreshSinks again via onCompleted
            // So we return early here to avoid double refresh
            return
        }

        sinks = newSinks
        root.currentSinkId = currentSinkId
        loading = false
        
        // Emit signal for each newly connected Bluetooth device
        for (var n = 0; n < newlyConnected.length; n++) {
            bluetoothDeviceConnected(newlyConnected[n])
        }
    }

    // Auto-refresh on startup
    Component.onCompleted: {
        refreshSinks()
    }

    // Auto-refresh every 5 seconds to catch new Bluetooth devices
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!loading) refreshSinks()
        }
    }
}