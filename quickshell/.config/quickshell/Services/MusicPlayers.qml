import QtQuick
import Quickshell.Services.Mpris

// Non-visual helper that tracks available MPRIS players and exposes currentPlayer
Item {
    id: root

    // Public API
    property var currentPlayer: null
    property int selectedPlayerIndex: 0
    property bool hasPlayer: getAvailablePlayers().length > 0

    function getAvailablePlayers() {
        if (!Mpris.players || !Mpris.players.values) return [];
        let all = Mpris.players.values;
        let res = [];
        for (let i = 0; i < all.length; i++) {
            let p = all[i];
            if (p && p.canControl) res.push(p);
        }
        return res;
    }

    function findActivePlayer() {
        let avail = getAvailablePlayers();
        if (avail.length === 0) return null;
        if (selectedPlayerIndex < avail.length) return avail[selectedPlayerIndex];
        selectedPlayerIndex = 0;
        return avail[0];
    }

    function updateCurrentPlayer() {
        let np = findActivePlayer();
        if (np !== currentPlayer) {
            currentPlayer = np;
        }
    }

    Component.onCompleted: updateCurrentPlayer()

    Connections {
        target: Mpris.players
        function onValuesChanged() { root.updateCurrentPlayer(); }
    }
}
