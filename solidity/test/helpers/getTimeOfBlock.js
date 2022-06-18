const {BN} = require("openzeppelin-test-helpers");
module.exports = async (block) => {
    return new BN((await web3.eth.getBlock(block.receipt.blockNumber)).timestamp)
};