const Grid = artifacts.require("../contracts/Grid.sol");
const ScopedRandomGenerator = artifacts.require("../contracts/ScopedRandomGenerator.sol");
const ApplicationRegistry = artifacts.require("../contracts/ApplicationRegistry.sol");
const CommonLib = artifacts.require("../contracts/CommonLib.sol");
const expectThrow = require('./helpers/expectThrow');
const {Conversion} = require('@truffle/codec');
const { BN, ether, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const {Random} = require("truffle/build/52.bundled");

contract("Grid", (accounts) => {

    const owner = accounts[0];
    const user1 = accounts[1];
    let applicationRegistry;
    let commonLib;
    let scopedRandomGenerator;
    let grid;

    beforeEach(async () => {
        applicationRegistry = await ApplicationRegistry.new();
        applicationRegistry.registerAccess(owner);
        commonLib = await CommonLib.new();
        await applicationRegistry.registerCommonLib(commonLib.address);
        scopedRandomGenerator = await ScopedRandomGenerator.new(applicationRegistry.address);
        await applicationRegistry.registerScopedRandomGenerator(scopedRandomGenerator.address);
        grid = await Grid.new(applicationRegistry.address, -10, -10, 10, 10);
        await applicationRegistry.registerGrid(grid.address);
    });

    describe('#constructor()', () => {
        it('should work', async () => {
            let gridHash = await grid.getGridHash(0,0);
            assert.ok(!gridHash.eq(new BN("0")));
        });
    });

    describe('#reveal()', () => {
        it('generates different values in sequence', async () => {
            let result1 = await grid.reveal(1, 0);
            expectEvent(result1, "GridHashRevealed");
            let result2 = await grid.reveal(0, -1);
            expectEvent(result2, "GridHashRevealed");

            let val1 = result1.logs[0].args.value;
            let val2 = result2.logs[0].args.value;
            assert.ok(!val1.eq(val2));
        });
    });

});