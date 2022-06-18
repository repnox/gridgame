const ScopedRandomGenerator = artifacts.require("../contracts/ScopedRandomGenerator.sol");
const ApplicationRegistry = artifacts.require("../contracts/ApplicationRegistry.sol");
const Item = artifacts.require("../contracts/Item.sol");
const Player = artifacts.require("../contracts/Player.sol");
const expectThrow = require('./helpers/expectThrow');
const {Conversion} = require('@truffle/codec');
const { BN, ether, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const {Random} = require("truffle/build/52.bundled");

contract("Grid", (accounts) => {

    const owner = accounts[0];
    const user1 = accounts[1];
    let applicationRegistry;
    let scopedRandomGenerator;
    let item;
    let player;

    beforeEach(async () => {
        applicationRegistry = await ApplicationRegistry.new();
        applicationRegistry.registerAccess(owner);

        scopedRandomGenerator = await ScopedRandomGenerator.new(applicationRegistry.address);
        await applicationRegistry.registerScopedRandomGenerator(scopedRandomGenerator.address);

        item = await Item.new(applicationRegistry.address);
        await applicationRegistry.registerItem(item.address);

        player = await Player.new(applicationRegistry.address);
        await applicationRegistry.registerPlayer(player.address);
    });

    describe('#constructor()', () => {
        it('should work', async () => {

        });
    });

    describe('#mintTo()', () => {
        it('generates a proper ID with encoded item type', async () => {
            let itemTypeExpected = new BN("1");
            let playerMintResult = await player.mintTo(owner);
            let playerId = playerMintResult.logs[0].args.tokenId;
            let mintResult = await item.mintTo(owner, itemTypeExpected, playerId);
            let itemId = mintResult.logs[0].args.tokenId;
            let itemTypeActual = await item.getItemType(itemId);
            assert.ok(itemTypeExpected.eq(itemTypeActual));
            let itemHash = await item.getItemHash(itemId);
            // The item hash is the low part of the item ID.
            assert.ok(itemId.gt(itemHash));
        });
    });

});