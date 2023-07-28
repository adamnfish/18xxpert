/**
 * Functions for storing and retrieving persisted game in the browser
 */

const storageKey = "18xxpert-game";
const maxAge = 1000 * 60 * 60 * 24 * 7; // 7 days

export function getGame() {
    try {
        const now = new Date().getTime();
        const game = JSON.parse(localStorage.getItem(storageKey)) || null;
        console.log("saved game:", game);
        if (game && game.modified && game.modified > (now - maxAge)) {
            return game;
        } else {
            // too old, so clear out the persisted data and return empty data
            deleteSavedGame();
            return null;
        }
    } catch(e) {
        console.error("Unable to load saved game", e);
        deleteSavedGame();
        return null;
    }
}

export function saveGame(game) {
    game.modified = new Date().getTime();
    return localStorage.setItem(storageKey, JSON.stringify(game));
}

function deleteSavedGame() {
    return localStorage.removeItem(storageKey);
}
