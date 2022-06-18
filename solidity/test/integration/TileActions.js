const Grid = artifacts.require("../contracts/Grid.sol");
const ApplicationRegistry = artifacts.require("../contracts/ApplicationRegistry.sol");
const CommonLib = artifacts.require("../contracts/CommonLib.sol");
const MovementController = artifacts.require("../contracts/MovementController.sol");
const Player = artifacts.require("../contracts/Player.sol");
const Item = artifacts.require("../contracts/Item.sol");
const Stats = artifacts.require("../contracts/Stats.sol");
const GameView = artifacts.require("../contracts/GameView.sol");
const PlayerActions = artifacts.require("../contracts/PlayerActions.sol");
const TileActions = artifacts.require("../contracts/TileActions.sol");
const ScopedRandomGenerator = artifacts.require("../contracts/ScopedRandomGenerator.sol");
const expectThrow = require('../helpers/expectThrow');
const {Conversion} = require('@truffle/codec');
const { BN, ether, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const web3 = require('web3');
const {Random} = require("truffle/build/52.bundled");
const getEventsForCallResult = require("../helpers/getEventsForCallResult");

contract("Tile Actions", (accounts) => {

    const owner = accounts[0];
    const user1 = accounts[1];
    let applicationRegistry;
    let commonLib;
    let scopedRandomGenerator;
    let grid;
    let movementController;
    let player;
    let item;
    let stats;
    let playerActions;
    let tileActions;
    let gameView;

    async function initializeEverything() {
        applicationRegistry = await ApplicationRegistry.new();
        await applicationRegistry.registerAccess(owner);

        commonLib = await CommonLib.new();
        await applicationRegistry.registerCommonLib(commonLib.address);

        scopedRandomGenerator = await ScopedRandomGenerator.new(applicationRegistry.address);
        await applicationRegistry.registerScopedRandomGenerator(scopedRandomGenerator.address);

        movementController = await MovementController.new(applicationRegistry.address);
        await applicationRegistry.registerMovementController(movementController.address);

        grid = await Grid.new(applicationRegistry.address, 0, 0, 1000, 10);
        await applicationRegistry.registerGrid(grid.address);

        player = await Player.new(applicationRegistry.address);
        await applicationRegistry.registerPlayer(player.address);

        item = await Item.new(applicationRegistry.address);
        await applicationRegistry.registerItem(item.address);

        stats = await Stats.new(applicationRegistry.address);
        await applicationRegistry.registerStats(stats.address);

        playerActions = await PlayerActions.new(applicationRegistry.address);
        await applicationRegistry.registerPlayerActions(playerActions.address);

        tileActions = await TileActions.new(applicationRegistry.address);
        await applicationRegistry.registerTileActions(tileActions.address);

        gameView = await GameView.new(applicationRegistry.address);
        await applicationRegistry.registerGameView(gameView.address);


    }

    beforeEach(async () => {
        await initializeEverything();
    });

    describe('Integration', () => {
        it('should mint lootboxes', async () => {

            // Create player
            let playerResult = await playerActions.createPlayer();
            let playerId = playerResult.logs[0].args.id;

            // Guarantee the hash ends in 2 for lootbox gen
            await grid.setHash(0, 0, 2);

            // Ensure the action is available
            assert.ok(await tileActions.isActionAvailable(0,0, 2));

            // Mint the lootbox.
            let mintResult = await tileActions.mintLootbox(playerId);
            let eventArgs = mintResult.logs[0].args;
            assert.ok(new BN(playerId).eq(eventArgs.playerId));
            assert.ok(new BN(0).eq(eventArgs.lootboxType));
            let itemId = eventArgs.itemId;

            // Verify the item ID hex (skipping the 0x prefix)
            let itemIdHex = web3.utils.toHex(itemId).substring(2);
            // All the bits on the left are zero because item type is 0 and theres no extra data.
            // So, the hex should be 32 characters or less (1 in 16 chance the first random hex is also zero)
            assert.ok(itemIdHex.length <= 32);

            // Verify the player owner.
            let itemOwner = await item.getPlayerOwner(itemId);
            assert.ok(playerId.eq(itemOwner));

            // Guarantee the hash DOES NOT end in 2 for lootbox gen
            await grid.setHash(0, 0, 7);

            // Verify generating lootbox isn't available
            await expectThrow(tileActions.mintLootbox(playerId), "Action not available");
        });
    });

});