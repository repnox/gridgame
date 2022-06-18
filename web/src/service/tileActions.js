import web3common from "./web3common";

const ACTION_LOOTBOX_GEN = "2";
const ACTION_MINT_MCGUFFIN = "3";
const ACTION_FETCH_QUEST = "4";

export default {
    async tileActionGenerateLootbox(playerId) {
        let tileActions = await web3common.getTileActions();
        return tileActions.mintLootbox(playerId);
    },
    async tileActionMintMcguffin(playerId) {
        let tileActions = await web3common.getTileActions();
        return tileActions.mintMcguffin(playerId);
    },
    async tileActionCompleteFetchQuest(playerId, itemId) {
        let tileActions = await web3common.getTileActions();
        return tileActions.completeFetchQuest(playerId, itemId);
    },
    async isGenerateLootboxActionAvailable(x, y) {
        const tileActions = await web3common.getTileActions();
        return tileActions.isActionAvailable(x, y, ACTION_LOOTBOX_GEN);
    },
    async isMintMcguffinActionAvailable(x, y) {
        const tileActions = await web3common.getTileActions();
        return tileActions.isActionAvailable(x, y, ACTION_MINT_MCGUFFIN);
    },
    async isCompleteFetchQuestActionAvailable(x, y) {
        const tileActions = await web3common.getTileActions();
        return tileActions.isActionAvailable(x, y, ACTION_FETCH_QUEST);
    },
};