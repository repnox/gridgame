import web3common from "./web3common";

export default {
    async createPlayer() {
        let playerActions = await web3common.getPlayerActions();
        await playerActions.createPlayer();
    },
    async movePlayer(id, x, y) {
        let playerActions = await web3common.getPlayerActions();
        await playerActions.movePlayer(id, x, y);
    },
    async estimateMovePlayer(id, x, y) {
        let playerActions = await web3common.getPlayerActions();
        return playerActions.estimateGas.movePlayer(id, x, y);
    },
};