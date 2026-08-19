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

    implicitWidth: miniMode ? 420 : 1000
    implicitHeight: miniMode ? 180 : 650
    color: "transparent"

    anchors { top: true }

    // --- PROPERTIES & STATES ---
    property bool isOpen: true
    property bool showWindow: true
    visible: showWindow

    property bool miniMode: false
    property bool isShuffle: false
    property int currentIndex: -1
    property int selectedIndex: -1
    property string searchQuery: ""
    property bool showOnlyFavorites: false
    property bool showQueuePanel: false
    property bool showPlaylistPanel: false

    property int loopMode: 0
    property int customLoopTarget: 0
    property int currentTrackLoopCount: 0

    // Animation properties
    property real panelOpacity: 0
    property real contentScale: 0.95

    // Cava Data & Visualizer Properties
    property bool cavaActive: false
    property var cavaBars: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
    property var favoritesList: []
    property string currentTrackName: currentIndex >= 0 ? mediaModel.get(currentIndex, "fileName") : ""

    // Playlists & Queue
    property var playlists: ({})
    property var playQueue: []
    property string currentPlaylist: ""

    // Theme System
    property var themes: {
        "catppuccin-mocha": {
            name: "Catppuccin Mocha",
            bg: "#1e1e2e", bg2: "#181825", bg3: "#11111b",
            fg: "#cdd6f4", fg2: "#a6adc8",
            accent: "#cba6f7", green: "#a6e3a1", red: "#f38ba8",
            yellow: "#f9e2af", blue: "#89b4fa",
            border: "#313244", hover: "#45475a",
            shadow: "#80000000"
        },
        "tokyonight": {
            name: "Tokyo Night",
            bg: "#1a1b26", bg2: "#16161e", bg3: "#0f0f14",
            fg: "#c0caf5", fg2: "#a9b1d6",
            accent: "#7aa2f7", green: "#9ece6a", red: "#f7768e",
            yellow: "#e0af68", blue: "#7dcfff",
            border: "#3b4261", hover: "#414868",
            shadow: "#80000000"
        },
        "dark": {
            name: "Dark",
            bg: "#2d2d2d", bg2: "#252525", bg3: "#1a1a1a",
            fg: "#e0e0e0", fg2: "#b0b0b0",
            accent: "#bb86fc", green: "#03dac6", red: "#cf6679",
            yellow: "#ffd700", blue: "#4fc3f7",
            border: "#404040", hover: "#505050",
            shadow: "#80000000"
        },
        "light": {
            name: "Light",
            bg: "#f5f5f5", bg2: "#e8e8e8", bg3: "#dcdcdc",
            fg: "#333333", fg2: "#666666",
            accent: "#6200ee", green: "#00c853", red: "#d32f2f",
            yellow: "#ff9800", blue: "#0288d1",
            border: "#cccccc", hover: "#dddddd",
            shadow: "#40000000"
        },
        "dracula": {
            name: "Dracula",
            bg: "#282a36", bg2: "#21222c", bg3: "#191a21",
            fg: "#f8f8f2", fg2: "#bfbfbf",
            accent: "#bd93f9", green: "#50fa7b", red: "#ff5555",
            yellow: "#f1fa8c", blue: "#8be9fd",
            border: "#44475a", hover: "#555770",
            shadow: "#80000000"
        },
        "nord": {
            name: "Nord",
            bg: "#2e3440", bg2: "#292e39", bg3: "#242933",
            fg: "#d8dee9", fg2: "#a3a9b8",
            accent: "#88c0d0", green: "#a3be8c", red: "#bf616a",
            yellow: "#ebcb8b", blue: "#81a1c1",
            border: "#4c566a", hover: "#5e6a82",
            shadow: "#80000000"
        },
        "gruvbox": {
            name: "Gruvbox",
            bg: "#282828", bg2: "#1d2021", bg3: "#141617",
            fg: "#ebdbb2", fg2: "#bdae93",
            accent: "#d3869b", green: "#b8bb26", red: "#fb4934",
            yellow: "#fabd2f", blue: "#83a598",
            border: "#3c3836", hover: "#504945",
            shadow: "#80000000"
        },
        "solarized": {
            name: "Solarized Dark",
            bg: "#002b36", bg2: "#073642", bg3: "#001e26",
            fg: "#839496", fg2: "#657b83",
            accent: "#6c71c4", green: "#859900", red: "#dc322f",
            yellow: "#b58900", blue: "#268bd2",
            border: "#586e75", hover: "#657b83",
            shadow: "#80000000"
        }
    }
    property string currentTheme: "catppuccin-mocha"

    // --- PERSISTENCE (STATE FILE) ---
    FileView {
        id: stateFile
        path: "Music/player-config.json"
        
        onLoaded: {
            try {
                var data = JSON.parse(text());
                if (data.theme) root.currentTheme = data.theme;
                if (data.volume) audioOut.volume = data.volume;
                if (data.shuffle !== undefined) root.isShuffle = data.shuffle;
                if (data.loopMode !== undefined) root.loopMode = data.loopMode;
                if (data.playlists) root.playlists = data.playlists;
                if (data.playQueue) root.playQueue = data.playQueue;
                if (data.currentPlaylist) root.currentPlaylist = data.currentPlaylist;
            } catch(e) {}
        }
    }

    function saveState() {
        var state = {
            theme: root.currentTheme,
            volume: audioOut.volume,
            shuffle: root.isShuffle,
            loopMode: root.loopMode,
            playlists: root.playlists,
            playQueue: root.playQueue,
            currentPlaylist: root.currentPlaylist
        };
        stateFile.setText(JSON.stringify(state, null, 2));
    }

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

    // --- THEME FUNCTIONS ---
    function cycleTheme() {
        var themeKeys = Object.keys(themes);
        var currentIdx = themeKeys.indexOf(currentTheme);
        currentTheme = themeKeys[(currentIdx + 1) % themeKeys.length];
        saveState();
        sendNotification("Theme", "Switched to " + themes[currentTheme].name);
    }

    function setTheme(themeName) {
        if (themes[themeName]) {
            currentTheme = themeName;
            saveState();
            sendNotification("Theme", "Switched to " + themes[themeName].name);
        }
    }

    // --- PLAYLIST FUNCTIONS ---
    function createPlaylist(name) {
        if (name && !playlists[name]) {
            playlists[name] = [];
            saveState();
            sendNotification("Playlist", "Created: " + name);
        }
    }

    function addToPlaylist(playlistName, trackIndex) {
        if (playlists[playlistName] && trackIndex >= 0 && trackIndex < mediaModel.count) {
            var fileName = mediaModel.get(trackIndex, "fileName");
            if (!playlists[playlistName].includes(fileName)) {
                playlists[playlistName].push(fileName);
                saveState();
                sendNotification("Playlist", "Added to " + playlistName);
            }
        }
    }

    function loadPlaylist(name) {
        if (playlists[name]) {
            currentPlaylist = name;
            saveState();
            sendNotification("Playlist", "Loaded: " + name + " (" + playlists[name].length + " tracks)");
        }
    }

    function deletePlaylist(name) {
        if (playlists[name]) {
            delete playlists[name];
            if (currentPlaylist === name) currentPlaylist = "";
            saveState();
            sendNotification("Playlist", "Deleted: " + name);
        }
    }

    // --- QUEUE FUNCTIONS ---
    function addToQueue(index) {
        if (index >= 0 && index < mediaModel.count) {
            playQueue.push(index);
            saveState();
            var fileName = mediaModel.get(index, "fileName");
            sendNotification("Queue", "Added: " + fileName);
        }
    }

    function playNextInQueue() {
        if (playQueue.length > 0) {
            var nextIndex = playQueue.shift();
            saveState();
            playTrack(nextIndex);
        }
    }

    function clearQueue() {
        playQueue = [];
        saveState();
        sendNotification("Queue", "Queue cleared");
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
        if (isOpen) {
            showWindow = true
            panelOpacity = 0
            contentScale = 0.95
            panelOpacity = 1
            contentScale = 1
        }
    }

    property real currentTopMargin: isOpen ? 40 : -900
    margins { top: root.currentTopMargin }

    Behavior on currentTopMargin {
        NumberAnimation {
            id: slideAnim
            duration: 500
            easing.type: Easing.OutBack
            onRunningChanged: {
                if (!running && !root.isOpen) showWindow = false
            }
        }
    }

    Behavior on panelOpacity {
        NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
    }

    Behavior on contentScale {
        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
    }

    // --- Navigation Functions ---
    function getVisibleIndices() {
        var visible = [];
        for (var i = 0; i < mediaModel.count; i++) {
            var fileName = mediaModel.get(i, "fileName");
            var isFav = isFavorite(fileName);
            var matches = (searchQuery === "" || fuzzyMatch(searchQuery, fileName)) && (!showOnlyFavorites || isFav);
            if (matches) visible.push(i);
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
            if (currentPos === -1) selectedIndex = visibleIndices[0];
            else if (currentPos < visibleIndices.length - 1) selectedIndex = visibleIndices[currentPos + 1];
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
            if (currentPos === -1) selectedIndex = visibleIndices[visibleIndices.length - 1];
            else if (currentPos > 0) selectedIndex = visibleIndices[currentPos - 1];
        }
        playlistView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function playSelected() {
        if (selectedIndex >= 0 && selectedIndex < mediaModel.count) playTrack(selectedIndex);
    }

    function toggleFavoriteSelected() {
        if (selectedIndex >= 0 && selectedIndex < mediaModel.count) {
            var fileName = mediaModel.get(selectedIndex, "fileName");
            toggleFavorite(fileName);
        }
    }

    function addSelectedToQueue() {
        if (selectedIndex >= 0 && selectedIndex < mediaModel.count) addToQueue(selectedIndex);
    }

    // --- AUDIO VISUALIZER ---
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

    // --- NOTIFICATIONS ---
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

    Shortcut { sequence: "Up"; onActivated: moveSelectionUp() }
    Shortcut { sequence: "Down"; onActivated: moveSelectionDown() }
    Shortcut { sequence: "Enter"; onActivated: playSelected() }
    Shortcut { sequence: "Return"; onActivated: playSelected() }
    Shortcut { sequence: "F"; onActivated: toggleFavoriteSelected() }
    
    Shortcut { sequence: "Q"; onActivated: addSelectedToQueue() }
    Shortcut { sequence: "Ctrl+Q"; onActivated: playNextInQueue() }
    Shortcut { sequence: "Ctrl+Shift+Q"; onActivated: clearQueue() }
    Shortcut { sequence: "Ctrl+T"; onActivated: cycleTheme() }
    Shortcut { sequence: "V"; onActivated: miniMode = !miniMode }

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
        function cycleTheme(): void { root.cycleTheme() }
        function setTheme(themeName: string): void { root.setTheme(themeName) }
        function addToQueue(index: int): void { root.addToQueue(index) }
        function playNextInQueue(): void { root.playNextInQueue() }
        function clearQueue(): void { root.clearQueue() }
        function createPlaylist(name: string): void { root.createPlaylist(name) }
        function loadPlaylist(name: string): void { root.loadPlaylist(name) }
        function deletePlaylist(name: string): void { root.deletePlaylist(name) }
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
        if (player.playbackState === MediaPlayer.PlayingState) player.pause();
        else player.play();
    }

    function playTrack(index) {
        if (index >= 0 && index < mediaModel.count) {
            if (currentIndex !== index) currentTrackLoopCount = 0
            currentIndex = index
            selectedIndex = index
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
        
        if (playQueue.length > 0) {
            playNextInQueue();
            return;
        }

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

        if (root.loopMode === 2) playTrack(0);
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

        if (root.loopMode === 2) playTrack(mediaModel.count - 1);
    }

    function handleMediaEnd() {
        if (root.loopMode === 1) {
            currentTrackLoopCount++
            if (customLoopTarget === 0 || currentTrackLoopCount < customLoopTarget) player.play()
            else {
                currentTrackLoopCount = 0
                nextTrack()
            }
        } else nextTrack()
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

    // === UI COMPONENTS ===
    
    // Modern Button Component
    component ModernButton: Rectangle {
        id: btn
        property string text: ""
        property string icon: ""
        property color bgColor: themes[currentTheme].bg2
        property color textColor: themes[currentTheme].fg
        property color hoverColor: themes[currentTheme].hover
        property int fontSize: 11
        property bool active: false
        
        implicitWidth: 32
        implicitHeight: 32
        radius: 10
        color: active ? themes[currentTheme].accent : bgColor
        border.color: active ? themes[currentTheme].accent : themes[currentTheme].border
        border.width: 1
        
        scale: mouseArea.pressed ? 0.9 : 1
        opacity: mouseArea.containsMouse ? 0.9 : 1
        
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        
        Text {
            anchors.centerIn: parent
            text: btn.icon || btn.text
            color: active ? themes[currentTheme].bg3 : textColor
            font.pixelSize: fontSize
            font.bold: true
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
        
        signal clicked()
    }

    // === MAIN CONTAINER ===
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
            anchors.margins: miniMode ? 5 : 15
            radius: miniMode ? 20 : 28
            opacity: panelOpacity
            scale: contentScale
            transformOrigin: Item.Top
            
            gradient: Gradient {
                GradientStop { position: 0.0; color: themes[currentTheme].bg }
                GradientStop { position: 0.3; color: themes[currentTheme].bg2 }
                GradientStop { position: 1.0; color: themes[currentTheme].bg3 }
            }
            border.color: themes[currentTheme].border
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: miniMode ? 12 : 24
                spacing: miniMode ? 8 : 20

                // === HEADER ===
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: miniMode ? 30 : 40
                    spacing: 12

                    // Status indicator
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: player.playbackState === MediaPlayer.PlayingState ? themes[currentTheme].green : themes[currentTheme].red
                        
                        Rectangle {
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: "white"
                            opacity: 0.5
                        }
                    }

                    // Title
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: miniMode ? "Player" : currentTrackName || "Media Player"
                            color: themes[currentTheme].fg
                            font.bold: true
                            font.pixelSize: miniMode ? 12 : 16
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            visible: !miniMode
                            text: mediaModel.count + " tracks" + (showOnlyFavorites ? " • Favorites" : "")
                            color: themes[currentTheme].fg2
                            font.pixelSize: 10
                        }
                    }

                    // Quick actions
                    RowLayout {
                        spacing: 8
                        
                        ModernButton {
                            icon: "⊞"
                            fontSize: 14
                            bgColor: themes[currentTheme].bg2
                            onClicked: showQueuePanel = !showQueuePanel
                        }
                        
                        ModernButton {
                            icon: "≡"
                            fontSize: 14
                            bgColor: themes[currentTheme].bg2
                            onClicked: showPlaylistPanel = !showPlaylistPanel
                        }
                        
                        ModernButton {
                            icon: "🎨"
                            fontSize: 12
                            bgColor: themes[currentTheme].bg2
                            onClicked: cycleTheme()
                        }
                        
                        ModernButton {
                            icon: miniMode ? "⤢" : "─"
                            fontSize: 14
                            bgColor: themes[currentTheme].bg2
                            onClicked: miniMode = !miniMode
                        }
                        
                        ModernButton {
                            icon: "✕"
                            fontSize: 12
                            bgColor: themes[currentTheme].red
                            textColor: themes[currentTheme].bg3
                            onClicked: root.isOpen = false
                        }
                    }
                }

                // === MAIN CONTENT ===
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20
                    visible: !miniMode

                    // Left panel - Visualizer/Video
                    Rectangle {
                        Layout.preferredWidth: 280
                        Layout.fillHeight: true
                        radius: 20
                        color: themes[currentTheme].bg3
                        border.color: themes[currentTheme].border
                        border.width: 1
                        clip: true

                        VideoOutput {
                            id: videoOut
                            anchors.fill: parent
                            visible: player.hasVideo
                        }

                        // Visualizer
                        RowLayout {
                            anchors.centerIn: parent
                            visible: !player.hasVideo
                            spacing: 6

                            Repeater {
                                model: 14
                                Rectangle {
                                    width: 8
                                    height: Math.max(8, root.cavaBars[index] || 10)
                                    radius: 4
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: themes[currentTheme].accent }
                                        GradientStop { position: 1.0; color: themes[currentTheme].blue }
                                    }

                                    Behavior on height {
                                        NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                                    }
                                }
                            }
                        }

                        // Now playing info overlay
                        ColumnLayout {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 15
                            spacing: 5
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: themes[currentTheme].border
                            }
                            
                            Text {
                                text: currentTrackName || "Nothing playing"
                                color: themes[currentTheme].fg
                                font.bold: true
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: formatTime(player.position) + " / " + formatTime(player.duration)
                                color: themes[currentTheme].fg2
                                font.pixelSize: 10
                            }
                        }
                    }

                    // Right panel - Playlist
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 15

                        // Search bar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 12
                            color: themes[currentTheme].bg3
                            border.color: searchInput.activeFocus ? themes[currentTheme].accent : themes[currentTheme].border
                            border.width: 1.5

                            TextField {
                                id: searchInput
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15
                                placeholderText: "🔍  Search tracks..."
                                placeholderTextColor: themes[currentTheme].fg2
                                color: themes[currentTheme].fg
                                font.pixelSize: 13
                                background: null
                                onTextChanged: searchQuery = text
                            }
                        }

                        // Playlist view
                        ListView {
                            id: playlistView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: mediaModel
                            spacing: 4
                            focus: true

                            delegate: Rectangle {
                                property bool isFav: isFavorite(fileName)
                                property bool matchesSearch: (searchQuery === "" || fuzzyMatch(searchQuery, fileName)) && (!showOnlyFavorites || isFav)
                                property bool isSelected: index === root.selectedIndex
                                
                                visible: matchesSearch
                                width: playlistView.width
                                implicitHeight: matchesSearch ? 44 : 0
                                radius: 12
                                
                                color: isSelected ? themes[currentTheme].hover : 
                                       (index === currentIndex ? themes[currentTheme].bg2 : "transparent")
                                
                                border.color: isSelected ? themes[currentTheme].blue : 
                                              (index === currentIndex ? themes[currentTheme].accent : "transparent")
                                border.width: isSelected ? 2 : (index === currentIndex ? 1 : 0)

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 10
                                    visible: parent.matchesSearch

                                    // Track number
                                    Text {
                                        text: (index + 1 < 10 ? "0" : "") + (index + 1)
                                        color: isSelected ? themes[currentTheme].blue : 
                                               (index === currentIndex ? themes[currentTheme].accent : themes[currentTheme].fg2)
                                        font.pixelSize: 11
                                        font.bold: true
                                        Layout.preferredWidth: 25
                                    }

                                    // Track name
                                    Text {
                                        text: fileName
                                        color: isSelected ? themes[currentTheme].blue : 
                                               (index === currentIndex ? themes[currentTheme].yellow : themes[currentTheme].fg)
                                        font.pixelSize: 13
                                        font.bold: index === currentIndex
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    // Favorite star
                                    Text {
                                        text: isFav ? "★" : "☆"
                                        color: isFav ? themes[currentTheme].yellow : themes[currentTheme].fg2
                                        font.pixelSize: 16
                                        Layout.preferredWidth: 20
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: toggleFavorite(fileName)
                                        }
                                    }

                                    // Click to play
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            root.selectedIndex = index
                                            playTrack(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // === MINI MODE CONTENT ===
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 15
                    visible: miniMode

                    // Mini visualizer
                    RowLayout {
                        Layout.preferredWidth: 80
                        Layout.fillHeight: true
                        spacing: 3

                        Repeater {
                            model: 6
                            Rectangle {
                                width: 5
                                height: Math.max(8, root.cavaBars[index] || 10)
                                radius: 3
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: themes[currentTheme].accent }
                                    GradientStop { position: 1.0; color: themes[currentTheme].blue }
                                }

                                Behavior on height {
                                    NumberAnimation { duration: 80 }
                                }
                            }
                        }
                    }

                    // Track info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: currentTrackName || "Nothing playing"
                            color: themes[currentTheme].fg
                            font.bold: true
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Progress bar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4
                            radius: 2
                            color: themes[currentTheme].border

                            Rectangle {
                                width: parent.width * (player.duration > 0 ? player.position / player.duration : 0)
                                height: parent.height
                                radius: 2
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: themes[currentTheme].accent }
                                    GradientStop { position: 1.0; color: themes[currentTheme].yellow }
                                }
                            }
                        }
                    }

                    // Mini controls
                    RowLayout {
                        spacing: 8

                        ModernButton {
                            icon: "◀◀"
                            fontSize: 10
                            onClicked: previousTrack()
                        }
                        
                        ModernButton {
                            icon: player.playbackState === MediaPlayer.PlayingState ? "❚❚" : "▶"
                            fontSize: 12
                            bgColor: themes[currentTheme].accent
                            textColor: themes[currentTheme].bg3
                            onClicked: togglePlayPause()
                        }
                        
                        ModernButton {
                            icon: "▶▶"
                            fontSize: 10
                            onClicked: nextTrack()
                        }
                    }
                }

                // === CONTROLS (FULL MODE) ===
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: !miniMode
                    spacing: 15

                    // Progress bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text { 
                            text: formatTime(player.position)
                            color: themes[currentTheme].fg2
                            font.pixelSize: 10
                            font.bold: true
                            Layout.preferredWidth: 40
                        }

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
                                height: 6
                                radius: 3
                                color: themes[currentTheme].border

                                Rectangle {
                                    width: progress.visualPosition * parent.width
                                    height: parent.height
                                    radius: 3
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: themes[currentTheme].accent }
                                        GradientStop { position: 1.0; color: themes[currentTheme].yellow }
                                    }
                                }
                            }

                            handle: Rectangle {
                                x: progress.leftPadding + progress.visualPosition * (progress.availableWidth - width)
                                y: progress.topPadding + progress.availableHeight / 2 - height / 2
                                width: 14
                                height: 14
                                radius: 7
                                color: themes[currentTheme].yellow
                                border.color: themes[currentTheme].accent
                                border.width: 2
                            }
                        }

                        Text { 
                            text: formatTime(player.duration)
                            color: themes[currentTheme].fg2
                            font.pixelSize: 10
                            font.bold: true
                            Layout.preferredWidth: 40
                        }
                    }

                    // Controls row
                    RowLayout {
                        Layout.fillWidth: true

                        // Speed controls
                        RowLayout {
                            spacing: 6

                            Repeater {
                                model: [0.5, 1.0, 1.5, 2.0]
                                ModernButton {
                                    text: modelData + "x"
                                    fontSize: 10
                                    active: player.playbackRate === modelData
                                    onClicked: player.playbackRate = modelData
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Main controls
                        RowLayout {
                            spacing: 10

                            ModernButton {
                                icon: "⨯"
                                fontSize: 14
                                active: root.isShuffle
                                onClicked: root.isShuffle = !root.isShuffle
                            }
                            
                            ModernButton {
                                icon: "◀◀"
                                fontSize: 12
                                onClicked: previousTrack()
                            }
                            
                            ModernButton {
                                icon: player.playbackState === MediaPlayer.PlayingState ? "❚❚" : "▶"
                                fontSize: 14
                                bgColor: themes[currentTheme].accent
                                textColor: themes[currentTheme].bg3
                                onClicked: togglePlayPause()
                            }
                            
                            ModernButton {
                                icon: "▶▶"
                                fontSize: 12
                                onClicked: nextTrack()
                            }
                            
                            ModernButton {
                                icon: root.loopMode === 1 ? "⟳" : "↻"
                                fontSize: 14
                                active: root.loopMode !== 0
                                onClicked: cycleLoopMode()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Volume control
                        RowLayout {
                            spacing: 8

                            ModernButton {
                                icon: audioOut.muted ? "🔇" : "🔊"
                                fontSize: 12
                                active: audioOut.muted
                                onClicked: audioOut.muted = !audioOut.muted
                            }

                            Slider {
                                id: volumeSlider
                                Layout.preferredWidth: 100
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
                                    color: themes[currentTheme].border

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        radius: 2
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: themes[currentTheme].green }
                                            GradientStop { position: 1.0; color: themes[currentTheme].blue }
                                        }
                                    }
                                }

                                handle: Rectangle {
                                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: audioOut.muted ? themes[currentTheme].red : themes[currentTheme].green
                                    border.color: audioOut.muted ? themes[currentTheme].red : themes[currentTheme].blue
                                    border.width: 2
                                }
                            }

                            Text {
                                text: Math.round(audioOut.volume * 100) + "%"
                                color: audioOut.muted ? themes[currentTheme].red : themes[currentTheme].green
                                font.bold: true
                                font.pixelSize: 10
                                Layout.preferredWidth: 35
                            }
                        }
                    }
                }
            }
        }
    }
}
