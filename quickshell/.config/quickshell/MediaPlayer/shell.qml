import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtMultimedia
import Qt.labs.folderlistmodel

PanelWindow {
    id: root

    // --- WAYLAND CONFIGURATION ---
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore

    implicitWidth: miniMode ? 380 : 940
    implicitHeight: miniMode ? 160 : 600
    color: "transparent"

    anchors { top: true }

    // --- PROPERTIES & STATES ---
    property bool isOpen: true
    property bool showWindow: true
    visible: showWindow

    property bool miniMode: false
    property bool isShuffle: false
    property int currentIndex: -1
    property int selectedIndex: -1  // NEW: للملف المحدد بالإطار
    property string searchQuery: ""
    property bool showOnlyFavorites: false

    property int loopMode: 0
    property int customLoopTarget: 0
    property int currentTrackLoopCount: 0

    // Cava Data & Visualizer Properties
    property bool cavaActive: false
    property var cavaBars: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
    property var favoritesList: []
    property string currentTrackName: currentIndex >= 0 ? mediaModel.get(currentIndex, "fileName") : ""

    // --- PERSISTENCE (FAVORITES FILE) ---
    FileView {
        id: favoritesFile
        path: "Music/favorites.json"
        
        onLoaded: {
            try {
                var data = JSON.parse(text());
                if (Array.isArray(data)) {
                    root.favoritesList = data;
                }
            } catch(e) {
                root.favoritesList = [];
            }
        }
    }

    function saveFavorites() {
        favoritesFile.setText(JSON.stringify(root.favoritesList, null, 2));
    }

    // --- FUZZY SEARCH ALGORITHM ---
    function fuzzyMatch(pattern, str) {
        pattern = pattern.toLowerCase();
        str = str.toLowerCase();
        var patternIdx = 0;
        var strIdx = 0;
        while (patternIdx < pattern.length && strIdx < str.length) {
            if (pattern[patternIdx] === str[strIdx]) {
                patternIdx++;
            }
            strIdx++;
        }
        return patternIdx === pattern.length;
    }

    onIsOpenChanged: {
        if (isOpen) showWindow = true
    }

    property real currentTopMargin: isOpen ? 60 : -850
    margins { top: root.currentTopMargin }

    Behavior on currentTopMargin {
        NumberAnimation {
            id: slideAnim
            duration: 350
            easing.type: Easing.OutQuint
            onRunningChanged: {
                if (!running && !root.isOpen) root.showWindow = false
            }
        }
    }

    // --- NEW: Navigation Functions ---
    function getVisibleIndices() {
        var visible = [];
        for (var i = 0; i < mediaModel.count; i++) {
            var fileName = mediaModel.get(i, "fileName");
            var isFav = isFavorite(fileName);
            var matches = (searchQuery === "" || fuzzyMatch(searchQuery, fileName)) && (!showOnlyFavorites || isFav);
            if (matches) {
                visible.push(i);
            }
        }
        return visible;
    }

    function moveSelectionDown() {
        var visibleIndices = getVisibleIndices();
        if (visibleIndices.length === 0) return;
        
        if (selectedIndex === -1) {
            selectedIndex = visibleIndices[0];
        } else {
            var currentPos = visibleIndices.indexOf(selectedIndex);
            if (currentPos === -1) {
                selectedIndex = visibleIndices[0];
            } else if (currentPos < visibleIndices.length - 1) {
                selectedIndex = visibleIndices[currentPos + 1];
            }
        }
        playlistView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function moveSelectionUp() {
        var visibleIndices = getVisibleIndices();
        if (visibleIndices.length === 0) return;
        
        if (selectedIndex === -1) {
            selectedIndex = visibleIndices[visibleIndices.length - 1];
        } else {
            var currentPos = visibleIndices.indexOf(selectedIndex);
            if (currentPos === -1) {
                selectedIndex = visibleIndices[visibleIndices.length - 1];
            } else if (currentPos > 0) {
                selectedIndex = visibleIndices[currentPos - 1];
            }
        }
        playlistView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function playSelected() {
        if (selectedIndex >= 0 && selectedIndex < mediaModel.count) {
            playTrack(selectedIndex);
        }
    }

    function toggleFavoriteSelected() {
        if (selectedIndex >= 0 && selectedIndex < mediaModel.count) {
            var fileName = mediaModel.get(selectedIndex, "fileName");
            toggleFavorite(fileName);
        }
    }

    // --- AUDIO VISUALIZER (CAVA + DYNAMIC FALLBACK) ---
    Process {
        id: cavaProc
        command: ["bash", "-c", "cava -p /dev/stdin << EOF\n[general]\nbars = 14\n[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 50\nbar_delimiter = 59\nEOF"]
        running: player.playbackState === MediaPlayer.PlayingState

        stdout: SplitParser {
            onRead: data => {
                var values = data.trim().split(";");
                var parsed = [];
                for (var i = 0; i < Math.min(values.length, 14); i++) {
                    var val = parseInt(values[i]);
                    if (!isNaN(val)) parsed.push(Math.max(6, val));
                }
                if (parsed.length > 0) {
                    root.cavaBars = parsed;
                    root.cavaActive = true;
                }
            }
        }
    }

    Timer {
        id: fallbackTimer
        interval: 70
        running: player.playbackState === MediaPlayer.PlayingState && !root.cavaActive
        repeat: true
        onTriggered: {
            var dummy = [];
            for (var i = 0; i < 14; i++) {
                var base = Math.sin((player.position / 150) + i) * 20 + 25;
                dummy.push(Math.max(6, Math.floor(base + Math.random() * 15)));
            }
            root.cavaBars = dummy;
        }
    }

    // --- MINIMAL & NON-INTRUSIVE NOTIFICATIONS ---
    Process { id: notifyProc }
    function sendNotification(title, body) {
        notifyProc.command = [
            "notify-send", 
            "-h", "string:x-canonical-private-synchronous:media-player", 
            "-t", "1800", 
            "-u", "low",
            title, 
            body
        ];
        notifyProc.running = true;
    }

    // --- HYPRLAND FOCUS GRAB ---
    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen && root.showWindow
        onCleared: { if (root.isOpen) root.isOpen = false }
    }

    // --- KEYBOARD SHORTCUTS ---
    Shortcut { sequence: "Escape"; onActivated: if (root.isOpen) root.isOpen = false }
    Shortcut { sequence: "Space"; onActivated: root.togglePlayPause() }
    Shortcut { sequence: "Right"; onActivated: player.position = Math.min(player.duration, player.position + 5000) }
    Shortcut { sequence: "Left"; onActivated: player.position = Math.max(0, player.position - 5000) }
    
    Shortcut { sequence: "Ctrl+Right"; onActivated: nextTrack() }
    Shortcut { sequence: "Ctrl+Left"; onActivated: previousTrack() }
    Shortcut { sequence: "N"; onActivated: nextTrack() }
    Shortcut { sequence: "P"; onActivated: previousTrack() }

    Shortcut { sequence: "S"; onActivated: root.isShuffle = !root.isShuffle }
    Shortcut { sequence: "R"; onActivated: player.position = 0 }
    Shortcut { sequence: "L"; onActivated: cycleLoopMode() }
    Shortcut { sequence: "M"; onActivated: audioOut.muted = !audioOut.muted }
    Shortcut { sequence: "/"; onActivated: searchInput.forceActiveFocus() }

    // NEW: Navigation shortcuts
    Shortcut { sequence: "Up"; onActivated: moveSelectionUp() }
    Shortcut { sequence: "Down"; onActivated: moveSelectionDown() }
    Shortcut { sequence: "Enter"; onActivated: playSelected() }
    Shortcut { sequence: "Return"; onActivated: playSelected() }
    Shortcut { sequence: "F"; onActivated: toggleFavoriteSelected() }

    // --- IPC HANDLER ---
    IpcHandler {
        target: "media-player"
        function toggle(): void { root.isOpen = !root.isOpen }
        function open(): void { root.isOpen = true }
        function close(): void { root.isOpen = false }
        function isOpen(): bool { return root.isOpen }

        function next(): void { root.nextTrack() }
        function previous(): void { root.previousTrack() }
        function togglePlayPause(): void { root.togglePlayPause() }
    }

    // --- MEDIA PLAYER BACKEND ---
    MediaPlayer {
        id: player
        videoOutput: videoOut
        audioOutput: AudioOutput { id: audioOut; volume: 0.8 }

        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.EndOfMedia) handleMediaEnd()
        }
    }

    FolderListModel {
        id: mediaModel
        folder: "file://" + (Quickshell.env("HOME") || "/home/" + Quickshell.env("USER")) + "/Music"
        nameFilters: ["*.mp3", "*.flac", "*.ogg", "*.m4a", "*.wav", "*.mp4", "*.mkv", "*.webm"]
        showDirs: false
    }

    // --- CONTROL FUNCTIONS ---
    function togglePlayPause() {
        if (player.playbackState === MediaPlayer.PlayingState) {
            player.pause();
        } else {
            player.play();
        }
    }

    function playTrack(index) {
        if (index >= 0 && index < mediaModel.count) {
            if (currentIndex !== index) currentTrackLoopCount = 0
            currentIndex = index
            selectedIndex = index  // NEW: Update selection
            var path = mediaModel.get(index, "filePath")
            var fileName = mediaModel.get(index, "fileName")
            if (path) {
                player.source = "file://" + path
                player.play()
                sendNotification("Playing", fileName)
                playlistView.positionViewAtIndex(index, ListView.Beginning)
            }
        }
    }

    function nextTrack() {
        if (mediaModel.count === 0) return;

        if (root.isShuffle) {
            playTrack(Math.floor(Math.random() * mediaModel.count));
            return;
        }

        var nextIndex = currentIndex + 1;
        while (nextIndex < mediaModel.count) {
            var fileName = mediaModel.get(nextIndex, "fileName");
            var isFav = isFavorite(fileName);
            var matches = (searchQuery === "" || fuzzyMatch(searchQuery, fileName)) && (!showOnlyFavorites || isFav);
            
            if (matches) {
                playTrack(nextIndex);
                return;
            }
            nextIndex++;
        }

        if (root.loopMode === 2) {
            playTrack(0);
        }
    }

    function previousTrack() {
        if (mediaModel.count === 0) return;

        if (root.isShuffle) {
            playTrack(Math.floor(Math.random() * mediaModel.count));
            return;
        }

        var prevIndex = currentIndex - 1;
        while (prevIndex >= 0) {
            var fileName = mediaModel.get(prevIndex, "fileName");
            var isFav = isFavorite(fileName);
            var matches = (searchQuery === "" || fuzzyMatch(searchQuery, fileName)) && (!showOnlyFavorites || isFav);
            
            if (matches) {
                playTrack(prevIndex);
                return;
            }
            prevIndex--;
        }

        if (root.loopMode === 2) {
            playTrack(mediaModel.count - 1);
        }
    }

    function handleMediaEnd() {
        if (root.loopMode === 1) {
            currentTrackLoopCount++
            if (customLoopTarget === 0 || currentTrackLoopCount < customLoopTarget) {
                player.play()
            } else {
                currentTrackLoopCount = 0
                nextTrack()
            }
        } else {
            nextTrack()
        }
    }

    function cycleLoopMode() { root.loopMode = (root.loopMode + 1) % 3 }
    function formatTime(ms) {
        var seconds = Math.floor(ms / 1000)
        var minutes = Math.floor(seconds / 60)
        seconds = seconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    function isFavorite(fileName) {
        return favoritesList.indexOf(fileName) !== -1
    }

    function toggleFavorite(fileName) {
        var idx = favoritesList.indexOf(fileName)
        var list = favoritesList.slice()
        if (idx === -1) {
            list.push(fileName)
            sendNotification("Saved", "Added to Favorites")
        } else {
            list.splice(idx, 1)
            sendNotification("Removed", "Removed from Favorites")
        }
        favoritesList = list
        saveFavorites()
    }

    // --- MAIN CONTAINER WITH DRAG & DROP SUPPORT ---
    DropArea {
        anchors.fill: parent
        onEntered: (drag) => drag.accept()
        onDropped: (drop) => {
            if (drop.hasUrls && drop.urls.length > 0) {
                player.source = drop.urls[0]
                player.play()
                sendNotification("Playing File", drop.urls[0].toString().split('/').pop())
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            radius: 24
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1e1e2e" }
                GradientStop { position: 1.0; color: "#11111b" }
            }
            border.color: "#313244"
            border.width: 1

            MouseArea {
                anchors.fill: parent

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    // Header Bar
                    RowLayout {
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: 8
                            Rectangle {
                                width: 10; height: 10; radius: 5
                                color: player.playbackState === MediaPlayer.PlayingState ? "#a6e3a1" : "#f38ba8"
                            }
                            Text {
                                text: miniMode ? "Mini Player" : "Media Queue (" + mediaModel.count + ")"
                                color: "#cdd6f4"
                                font.bold: true
                                font.pixelSize: 15
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Filter Favorites Toggle Button
                        Rectangle {
                            implicitWidth: 80; implicitHeight: 28; radius: 8
                            color: showOnlyFavorites ? "#f5e0dc" : "#2a2b3d"
                            border.color: "#45475a"; border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: showOnlyFavorites ? "★ Favs" : "☆ All"
                                color: showOnlyFavorites ? "#11111b" : "#cdd6f4"
                                font.pixelSize: 11
                                font.bold: true
                            }
                            
                            MouseArea {
                                id: favToggleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: showOnlyFavorites = !showOnlyFavorites
                                
                                onContainsMouseChanged: {
                                    parent.color = containsMouse ? 
                                        (showOnlyFavorites ? "#f2d5c8" : "#3a3b4f") : 
                                        (showOnlyFavorites ? "#f5e0dc" : "#2a2b3d")
                                }
                            }
                            
                            ToolTip {
                                parent: parent
                                visible: favToggleArea.containsMouse
                                text: showOnlyFavorites ? "Show all tracks" : "Show only favorites"
                                delay: 400
                                background: Rectangle {
                                    color: "#1e1e2e"
                                    border.color: "#313244"
                                    border.width: 1
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: showOnlyFavorites ? "Show all tracks" : "Show only favorites"
                                    color: "#cdd6f4"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        // Mini/Expand Button
                        Rectangle {
                            implicitWidth: 72; implicitHeight: 28; radius: 8
                            color: "#2a2b3d"
                            border.color: "#45475a"; border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: miniMode ? "Expand" : "Mini"
                                color: "#cba6f7"
                                font.pixelSize: 11
                                font.bold: true
                            }
                            
                            MouseArea {
                                id: miniToggleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: miniMode = !miniMode
                                
                                onContainsMouseChanged: {
                                    parent.color = containsMouse ? "#3a3b4f" : "#2a2b3d"
                                }
                            }
                            
                            ToolTip {
                                parent: parent
                                visible: miniToggleArea.containsMouse
                                text: miniMode ? "Expand player" : "Switch to mini mode"
                                delay: 400
                                background: Rectangle {
                                    color: "#1e1e2e"
                                    border.color: "#313244"
                                    border.width: 1
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: miniMode ? "Expand player" : "Switch to mini mode"
                                    color: "#cdd6f4"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        // Close Button
                        Rectangle {
                            implicitWidth: 28; implicitHeight: 28; radius: 8
                            color: "#f38ba8"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: "#11111b"
                                font.bold: true
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                id: closeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.isOpen = false
                                
                                onContainsMouseChanged: {
                                    parent.color = containsMouse ? "#e07b94" : "#f38ba8"
                                }
                            }
                            
                            ToolTip {
                                parent: parent
                                visible: closeArea.containsMouse
                                text: "Close player (Esc)"
                                delay: 400
                                background: Rectangle {
                                    color: "#1e1e2e"
                                    border.color: "#313244"
                                    border.width: 1
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: "Close player (Esc)"
                                    color: "#cdd6f4"
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }

                    // Body Section
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16

                        Rectangle {
                            Layout.preferredWidth: miniMode ? 100 : 320
                            Layout.fillHeight: true
                            radius: 18
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#181825" }
                                GradientStop { position: 1.0; color: "#1e1e2e" }
                            }
                            border.color: "#313244"
                            border.width: 1
                            clip: true

                            VideoOutput {
                                id: videoOut
                                anchors.fill: parent
                                visible: player.hasVideo && !miniMode
                            }

                            // VISUALIZER BARS
                            RowLayout {
                                anchors.centerIn: parent
                                visible: !player.hasVideo || miniMode
                                spacing: 5

                                Repeater {
                                    model: miniMode ? 6 : 14
                                    Rectangle {
                                        width: 6
                                        height: root.cavaBars[index] !== undefined ? root.cavaBars[index] : 10
                                        radius: 3
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#cba6f7" }
                                            GradientStop { position: 1.0; color: "#89b4fa" }
                                        }

                                        Behavior on height {
                                            NumberAnimation { duration: 60 }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            Text {
                                text: currentIndex >= 0 ? mediaModel.get(currentIndex, "fileName") : "Select or Drop a Track"
                                color: "#f5e0dc"
                                font.bold: true
                                font.pixelSize: 15
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                visible: !miniMode
                                Layout.fillWidth: true
                                implicitHeight: 36
                                radius: 10
                                color: "#11111b"
                                border.color: searchInput.activeFocus ? "#cba6f7" : "#313244"
                                border.width: 1

                                TextField {
                                    id: searchInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    placeholderText: "Search track... (Press / to focus)"
                                    placeholderTextColor: "#6c7086"
                                    color: "#cdd6f4"
                                    font.pixelSize: 12
                                    background: null
                                    onTextChanged: searchQuery = text
                                }
                            }

                            ListView {
                                id: playlistView
                                visible: !miniMode
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                model: mediaModel
                                spacing: 6
                                focus: true  // NEW: للتنقل بالكيبورد

                                delegate: Rectangle {
                                    property bool isFav: isFavorite(fileName)
                                    property bool matchesSearch: (searchQuery === "" || fuzzyMatch(searchQuery, fileName)) && (!showOnlyFavorites || isFav)
                                    property bool isSelected: index === root.selectedIndex  // NEW
                                    
                                    visible: matchesSearch
                                    width: playlistView.width
                                    implicitHeight: matchesSearch ? 40 : 0
                                    radius: 10
                                    
                                    // NEW: Colors based on selection
                                    color: isSelected ? "#45475a" : (index === currentIndex ? "#313244" : "#181825")
                                    border.color: isSelected ? "#89b4fa" : (index === currentIndex ? "#cba6f7" : "transparent")
                                    border.width: isSelected ? 2 : (index === currentIndex ? 1 : 0)

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        spacing: 10
                                        visible: parent.matchesSearch

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Text {
                                                text: (index + 1 < 10 ? "0" : "") + (index + 1)
                                                color: isSelected ? "#89b4fa" : (index === currentIndex ? "#cba6f7" : "#6c7086")
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            Text {
                                                text: fileName
                                                color: isSelected ? "#89b4fa" : (index === currentIndex ? "#f5e0dc" : "#cdd6f4")
                                                font.pixelSize: 12
                                                font.bold: index === currentIndex || isSelected
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    root.selectedIndex = index  // NEW
                                                    playTrack(index)
                                                }
                                            }
                                        }

                                        Rectangle {
                                            implicitWidth: 28
                                            implicitHeight: 28
                                            color: "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: isFav ? "★" : "☆"
                                                color: isFav ? "#f9e2af" : "#6c7086"
                                                font.pixelSize: 16
                                            }

                                            MouseArea {
                                                id: favArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: toggleFavorite(fileName)
                                            }
                                            
                                            ToolTip {
                                                parent: parent
                                                visible: favArea.containsMouse
                                                text: isFav ? "Remove from favorites" : "Add to favorites"
                                                delay: 400
                                                background: Rectangle {
                                                    color: "#1e1e2e"
                                                    border.color: "#313244"
                                                    border.width: 1
                                                    radius: 6
                                                }
                                                contentItem: Text {
                                                    text: isFav ? "Remove from favorites" : "Add to favorites"
                                                    color: "#cdd6f4"
                                                    font.pixelSize: 11
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Controls Section
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: miniMode ? 45 : 110
                        radius: 16
                        color: "#181825"
                        border.color: "#313244"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text { text: formatTime(player.position); color: "#a6adc8"; font.pixelSize: 10; font.bold: true }

                                Slider {
                                    id: progress
                                    Layout.fillWidth: true
                                    from: 0
                                    to: player.duration > 0 ? player.duration : 1
                                    value: player.position
                                    onMoved: player.position = progress.value

                                    background: Rectangle {
                                        x: progress.leftPadding
                                        y: progress.topPadding + progress.availableHeight / 2 - height / 2
                                        width: progress.availableWidth
                                        height: 5
                                        radius: 3
                                        color: "#313244"

                                        Rectangle {
                                            width: progress.visualPosition * parent.width
                                            height: parent.height
                                            radius: 3
                                            gradient: Gradient {
                                                GradientStop { position: 0.0; color: "#cba6f7" }
                                                GradientStop { position: 1.0; color: "#f5e0dc" }
                                            }
                                        }
                                    }

                                    handle: Rectangle {
                                        x: progress.leftPadding + progress.visualPosition * (progress.availableWidth - width)
                                        y: progress.topPadding + progress.availableHeight / 2 - height / 2
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: "#f5e0dc"
                                        border.color: "#cba6f7"
                                        border.width: 2
                                    }
                                }

                                Text { text: formatTime(player.duration); color: "#a6adc8"; font.pixelSize: 10; font.bold: true }
                            }

                            // Volume Control Row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                visible: !miniMode

                                Text {
                                    text: audioOut.muted ? "🔇" : "🔊"
                                    color: audioOut.muted ? "#f38ba8" : "#cdd6f4"
                                    font.pixelSize: 14
                                }

                                Slider {
                                    id: volumeSlider
                                    Layout.fillWidth: true
                                    from: 0
                                    to: 1.0
                                    value: audioOut.volume
                                    onMoved: audioOut.volume = volumeSlider.value

                                    background: Rectangle {
                                        x: volumeSlider.leftPadding
                                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                        width: volumeSlider.availableWidth
                                        height: 4
                                        radius: 2
                                        color: "#313244"

                                        Rectangle {
                                            width: volumeSlider.visualPosition * parent.width
                                            height: parent.height
                                            radius: 2
                                            gradient: Gradient {
                                                GradientStop { position: 0.0; color: "#a6e3a1" }
                                                GradientStop { position: 1.0; color: "#89b4fa" }
                                            }
                                        }
                                    }

                                    handle: Rectangle {
                                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: audioOut.muted ? "#f38ba8" : "#a6e3a1"
                                        border.color: audioOut.muted ? "#f38ba8" : "#89b4fa"
                                        border.width: 2
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                }

                                Text {
                                    text: Math.round(audioOut.volume * 100) + "%"
                                    color: audioOut.muted ? "#f38ba8" : "#a6e3a1"
                                    font.bold: true
                                    font.pixelSize: 11
                                    Layout.preferredWidth: 40
                                }

                                // Mute Button
                                Rectangle {
                                    implicitWidth: 28
                                    implicitHeight: 28
                                    radius: 8
                                    color: audioOut.muted ? "#f38ba8" : "#2a2b3d"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: audioOut.muted ? "🔇" : "🔊"
                                        color: audioOut.muted ? "#11111b" : "#cdd6f4"
                                        font.pixelSize: 13
                                    }
                                    
                                    MouseArea {
                                        id: muteArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: audioOut.muted = !audioOut.muted
                                        
                                        onContainsMouseChanged: {
                                            if (!audioOut.muted) {
                                                parent.color = containsMouse ? "#3a3b4f" : "#2a2b3d"
                                            }
                                        }
                                    }
                                    
                                    ToolTip {
                                        parent: parent
                                        visible: muteArea.containsMouse
                                        text: audioOut.muted ? "Unmute (M)" : "Mute (M)"
                                        delay: 400
                                        background: Rectangle {
                                            color: "#1e1e2e"
                                            border.color: "#313244"
                                            border.width: 1
                                            radius: 6
                                        }
                                        contentItem: Text {
                                            text: audioOut.muted ? "Unmute (M)" : "Mute (M)"
                                            color: "#cdd6f4"
                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                RowLayout {
                                    visible: !miniMode
                                    spacing: 4

                                    Repeater {
                                        model: [0.5, 1.0, 1.5, 2.0]
                                        Rectangle {
                                            id: speedRect
                                            implicitWidth: 32
                                            implicitHeight: 22
                                            radius: 6
                                            color: player.playbackRate === modelData ? "#cba6f7" : "#2a2b3d"
                                            border.color: player.playbackRate === modelData ? "#f5e0dc" : "transparent"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData + "x"
                                                color: player.playbackRate === modelData ? "#11111b" : "#cdd6f4"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: speedArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: player.playbackRate = modelData
                                                
                                                onContainsMouseChanged: {
                                                    if (player.playbackRate !== modelData) {
                                                        speedRect.color = containsMouse ? "#3a3b4f" : "#2a2b3d"
                                                    }
                                                }
                                            }
                                            
                                            ToolTip {
                                                parent: parent
                                                visible: speedArea.containsMouse
                                                text: "Playback speed: " + modelData + "x"
                                                delay: 400
                                                background: Rectangle {
                                                    color: "#1e1e2e"
                                                    border.color: "#313244"
                                                    border.width: 1
                                                    radius: 6
                                                }
                                                contentItem: Text {
                                                    text: "Playback speed: " + modelData + "x"
                                                    color: "#cdd6f4"
                                                    font.pixelSize: 11
                                                }
                                            }
                                        }
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // Player Controls
                                RowLayout {
                                    spacing: 12

                                    // Shuffle Button
                                    Rectangle {
                                        id: shuffleRect
                                        implicitWidth: 28
                                        implicitHeight: 28
                                        radius: 8
                                        color: root.isShuffle ? "#cba6f7" : "#2a2b3d"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "⨯"
                                            color: root.isShuffle ? "#11111b" : "#cdd6f4"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            id: shuffleArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.isShuffle = !root.isShuffle
                                            
                                            onContainsMouseChanged: {
                                                if (!root.isShuffle) {
                                                    shuffleRect.color = containsMouse ? "#3a3b4f" : "#2a2b3d"
                                                }
                                            }
                                        }
                                        
                                        ToolTip {
                                            parent: parent
                                            visible: shuffleArea.containsMouse
                                            text: root.isShuffle ? "Disable shuffle (S)" : "Enable shuffle (S)"
                                            delay: 400
                                            background: Rectangle {
                                                color: "#1e1e2e"
                                                border.color: "#313244"
                                                border.width: 1
                                                radius: 6
                                            }
                                            contentItem: Text {
                                                text: root.isShuffle ? "Disable shuffle (S)" : "Enable shuffle (S)"
                                                color: "#cdd6f4"
                                                font.pixelSize: 11
                                            }
                                        }
                                    }

                                    // Previous Button
                                    Rectangle {
                                        id: prevRect
                                        implicitWidth: 32
                                        implicitHeight: 32
                                        radius: 10
                                        color: "#2a2b3d"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "◀◀"
                                            color: "#cdd6f4"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            id: prevArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: previousTrack()
                                            
                                            onContainsMouseChanged: {
                                                prevRect.color = containsMouse ? "#3a3b4f" : "#2a2b3d"
                                            }
                                        }
                                        
                                        ToolTip {
                                            parent: parent
                                            visible: prevArea.containsMouse
                                            text: "Previous track (P / Ctrl+Left)"
                                            delay: 400
                                            background: Rectangle {
                                                color: "#1e1e2e"
                                                border.color: "#313244"
                                                border.width: 1
                                                radius: 6
                                            }
                                            contentItem: Text {
                                                text: "Previous track (P / Ctrl+Left)"
                                                color: "#cdd6f4"
                                                font.pixelSize: 11
                                            }
                                        }
                                    }

                                    // Play/Pause Button
                                    Rectangle {
                                        id: playRect
                                        implicitWidth: 40
                                        implicitHeight: 40
                                        radius: 20
                                        color: "#cba6f7"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: player.playbackState === MediaPlayer.PlayingState ? "❚❚" : "▶"
                                            color: "#11111b"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            id: playArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: togglePlayPause()
                                            
                                            onContainsMouseChanged: {
                                                playRect.color = containsMouse ? "#b89ae0" : "#cba6f7"
                                            }
                                        }
                                        
                                        ToolTip {
                                            parent: parent
                                            visible: playArea.containsMouse
                                            text: player.playbackState === MediaPlayer.PlayingState ? "Pause (Space)" : "Play (Space)"
                                            delay: 400
                                            background: Rectangle {
                                                color: "#1e1e2e"
                                                border.color: "#313244"
                                                border.width: 1
                                                radius: 6
                                            }
                                            contentItem: Text {
                                                text: player.playbackState === MediaPlayer.PlayingState ? "Pause (Space)" : "Play (Space)"
                                                color: "#cdd6f4"
                                                font.pixelSize: 11
                                            }
                                        }
                                    }

                                    // Next Button
                                    Rectangle {
                                        id: nextRect
                                        implicitWidth: 32
                                        implicitHeight: 32
                                        radius: 10
                                        color: "#2a2b3d"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "▶▶"
                                            color: "#cdd6f4"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            id: nextArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: nextTrack()
                                            
                                            onContainsMouseChanged: {
                                                nextRect.color = containsMouse ? "#3a3b4f" : "#2a2b3d"
                                            }
                                        }
                                        
                                        ToolTip {
                                            parent: parent
                                            visible: nextArea.containsMouse
                                            text: "Next track (N / Ctrl+Right)"
                                            delay: 400
                                            background: Rectangle {
                                                color: "#1e1e2e"
                                                border.color: "#313244"
                                                border.width: 1
                                                radius: 6
                                            }
                                            contentItem: Text {
                                                text: "Next track (N / Ctrl+Right)"
                                                color: "#cdd6f4"
                                                font.pixelSize: 11
                                            }
                                        }
                                    }

                                    // Loop Mode Button
                                    Rectangle {
                                        id: loopRect
                                        implicitWidth: 28
                                        implicitHeight: 28
                                        radius: 8
                                        color: root.loopMode !== 0 ? "#cba6f7" : "#2a2b3d"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: root.loopMode === 1 ? "⟳" : "↻"
                                            color: root.loopMode !== 0 ? "#11111b" : "#cdd6f4"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            id: loopArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: cycleLoopMode()
                                            
                                            onContainsMouseChanged: {
                                                if (root.loopMode === 0) {
                                                    loopRect.color = containsMouse ? "#3a3b4f" : "#2a2b3d"
                                                }
                                            }
                                        }
                                        
                                        ToolTip {
                                            parent: parent
                                            visible: loopArea.containsMouse
                                            text: {
                                                if (root.loopMode === 0) return "Loop: Off (L)";
                                                if (root.loopMode === 1) return "Loop: Track (L)";
                                                return "Loop: Playlist (L)";
                                            }
                                            delay: 400
                                            background: Rectangle {
                                                color: "#1e1e2e"
                                                border.color: "#313244"
                                                border.width: 1
                                                radius: 6
                                            }
                                            contentItem: Text {
                                                text: {
                                                    if (root.loopMode === 0) return "Loop: Off (L)";
                                                    if (root.loopMode === 1) return "Loop: Track (L)";
                                                    return "Loop: Playlist (L)";
                                                }
                                                color: "#cdd6f4"
                                                font.pixelSize: 11
                                            }
                                        }
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }
        }
    }
}
