const Grid = artifacts.require("../contracts/Grid.sol");
const ScopedRandomGenerator = artifacts.require("../contracts/ScopedRandomGenerator.sol");
const ApplicationRegistry = artifacts.require("../contracts/ApplicationRegistry.sol");
const CommonLib = artifacts.require("../contracts/CommonLib.sol");
const MovementController = artifacts.require("../contracts/MovementController.sol");
const Player = artifacts.require("../contracts/Player.sol");
const Stats = artifacts.require("../contracts/Stats.sol");
const GameView = artifacts.require("../contracts/GameView.sol");
const PlayerActions = artifacts.require("../contracts/PlayerActions.sol");
const expectThrow = require('../helpers/expectThrow');
const getEventsForCallResult = require('../helpers/getEventsForCallResult');
const {Conversion} = require('@truffle/codec');
const { BN, ether, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const {Random} = require("truffle/build/52.bundled");

contract("Player Movement", (accounts) => {

    const owner = accounts[0];
    const user1 = accounts[1];
    let applicationRegistry;
    let commonLib;
    let scopedRandomGenerator;
    let grid;
    let movementController;
    let player;
    let stats;
    let playerActions;
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

        grid = await Grid.new(applicationRegistry.address, 0, 0, 10, 10);
        await applicationRegistry.registerGrid(grid.address);

        player = await Player.new(applicationRegistry.address);
        await applicationRegistry.registerPlayer(player.address);

        stats = await Stats.new(applicationRegistry.address);
        await applicationRegistry.registerStats(stats.address);

        playerActions = await PlayerActions.new(applicationRegistry.address);
        await applicationRegistry.registerPlayerActions(playerActions.address);

        gameView = await GameView.new(applicationRegistry.address);
        await applicationRegistry.registerGameView(gameView.address);


    }

    beforeEach(async () => {
        await initializeEverything();
    });

    describe('Integration', () => {
        it('should work', async () => {
            const zero = new BN("0");

            // Create player
            let playerResult = await playerActions.createPlayer();
            let playerId = playerResult.logs[0].args.id;

            // Check player is at the origin
            let tokensAtOrigin = await movementController.getTokensAtCoords(0,0);
            assert.ok(playerId.eq(tokensAtOrigin[0]));

            // Check player is visible on the map
            let playerLocations = await gameView.getAllPlayerLocations();
            assert.ok(playerId.eq(new BN(playerLocations[0].id)));
            assert.ok(zero.eq(new BN(playerLocations[0].x)));
            assert.ok(zero.eq(new BN(playerLocations[0].y)));
            assert.ok(true === playerLocations[0].staked);

            // Player should be able to move
            await playerActions.movePlayer(playerId, 0, 1);

            // Check player is at new location
            let tokensAtNewLocation = await movementController.getTokensAtCoords(0,1);
            assert.ok(playerId.eq(tokensAtNewLocation[0]));

            // And not at its previous location
            tokensAtOrigin = await movementController.getTokensAtCoords(0,0);
            assert.ok(0 === tokensAtOrigin.length);

            // Check player is visible on the map at new location
            playerLocations = await gameView.getAllPlayerLocations();
            assert.ok(playerId.eq(new BN(playerLocations[0].id)));
            assert.ok(zero.eq(new BN(playerLocations[0].x)));
            assert.ok(new BN(1).eq(new BN(playerLocations[0].y)));
            assert.ok(true === playerLocations[0].staked);

            // Player cannot move out of range
            await expectThrow(playerActions.movePlayer(playerId, 99, 99), "Grid: Coord not in range");
            await expectThrow(playerActions.movePlayer(playerId, -1, 0), "Grid: Coord not in range");

            // Player cannot move too far
            await expectThrow(playerActions.movePlayer(playerId, 5, 5), "Too far");

            // You should be able to move diagonally with initial stat.
            await playerActions.movePlayer(playerId, 0, 0);
            await playerActions.movePlayer(playerId, 1, 1);

            // You should not be able to move 2 squares with initial stat
            await playerActions.movePlayer(playerId, 0, 0);
            await expectThrow(playerActions.movePlayer(playerId, 0, 2), "Too far");
            await expectThrow(playerActions.movePlayer(playerId, 1, 2), "Too far");
            await expectThrow(playerActions.movePlayer(playerId, 2, 2), "Too far");

            // Increase travel stat
            await stats.setStat(playerId, await stats.STAT_TRAVEL(), "10");
            await playerActions.movePlayer(playerId, 0, 10);
            tokensAtOrigin = await movementController.getTokensAtCoords(0,10);
            assert.ok(playerId.eq(tokensAtOrigin[0]));

            // Player cannot move out of range
            await expectThrow(playerActions.movePlayer(playerId, 0, 11), "Grid: Coord not in range");

            // Grid reveal should occur on undiscovered grid tile
            // Move event should be emitted
            let movePlayerResult = await playerActions.movePlayer(playerId, 4, 7);
            let gridEvents = await getEventsForCallResult(grid, movePlayerResult);
            assert.ok(1 === gridEvents.length);
            let gridEvent = gridEvents[0];
            assert.ok(gridEvent.event === "GridHashRevealed");
            let eventArgs = gridEvent.args;
            assert.ok(new BN("4").eq(eventArgs.x));
            assert.ok(new BN("7").eq(eventArgs.y));
            let gridHash = eventArgs.value;
            assert.ok(!zero.eq(gridHash));

            // Grid does not reveal discovered tile
            let movePlayerResult2 = await playerActions.movePlayer(playerId, 0, 0);
            let gridEvents2 = await getEventsForCallResult(grid, movePlayerResult2);
            assert.ok(0 === gridEvents2.length);

        });
    });

});