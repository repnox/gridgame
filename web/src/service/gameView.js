import web3common from "./web3common";

export default {
    async getMapBounds() {
        let grid = await web3common.getGrid();
        let bounds = await grid.getBounds();
        return {
            minX: web3common.bnToNumber(bounds[0]),
            minY: web3common.bnToNumber(bounds[1]),
            maxX: web3common.bnToNumber(bounds[2]),
            maxY: web3common.bnToNumber(bounds[3])
        }
    },
    async getGridHash(x, y) {
        let grid = await web3common.getGrid();
        return (await grid.getGridHash(x, y))._hex;
    },
    async getPlayerIdsByOwner(owner) {
        const player = await web3common.getPlayer();
        let playerIds = [];
        let i = 0;
        while(true) {
            try {
                let rawId = await player.tokenOfOwnerByIndex(owner, i++);
                playerIds.push(rawId._hex);
            } catch (e) {
                break;
            }
        }
        return playerIds;
    },
    async getPlayerLocation(id) {
        const movementController = await web3common.getMovementController();
        let rawLocation = await movementController.getLocation(id);
        return {
            x: web3common.bnToNumber(rawLocation.x),
            y: web3common.bnToNumber(rawLocation.y),
        }
    },
    async getPlayerIdsAt(x, y) {
        const movementController = await web3common.getMovementController();
        let tokens = await movementController.getTokensAtCoords(x, y);
        return tokens.map((t) => t._hex);
    },
    async getPlayerStats(id) {
        const stats = await web3common.getStats();
        return {
            travel: web3common.bnToNumber(await stats.getStat(id, 1)),
        };
    },
    async getPlayerData(id, x=null, y=null) {
        let location;
        if (x != null && y != null) {
            location = {x,y};
        } else {
            location = await this.getPlayerLocation(id);
        }
        return {
            id,
            owner: await this.getOwnerOfPlayer(id),
            displayName: id.substr(2, 8),
            location,
            stats: await this.getPlayerStats(id),
        }
    },
    async getPlayersAt(x, y) {
        let playerIds = await this.getPlayerIdsAt(x, y);
        let players = [];
        for (let id of playerIds) {
            players.push(await this.getPlayerData(id));
        }
        return players;
    },
    async getOwnedPlayerData() {
        let playerIds = await this.getPlayerIdsByOwner(await web3common.getCurrentWalletAddress());
        let players = [];
        for (let id of playerIds) {
            players.push(await this.getPlayerData(id));
        }
        return players;
    },
    async getOwnerOfPlayer(id) {
        const player = await web3common.getPlayer();
        let owner = await player.ownerOf(id);
        return owner;
    },
    async getPlayerItemCount(playerId) {
        const item = await web3common.getItem();
        return await item.getPlayerItemCount(playerId);
    },
    async getPlayerItemByIndex(playerId, index) {
        const item = await web3common.getItem();
        return web3common.bnToHex(await item.getTokenOfPlayerByIndex(playerId, index));
    }
};