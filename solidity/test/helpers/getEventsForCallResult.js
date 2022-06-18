module.exports = async (contract, callResult) => {
    let blockNumber = callResult.receipt.blockNumber;
    let contractEvents = await contract.getPastEvents("allEvents", {fromBlock: blockNumber, toBlock: blockNumber});
    return contractEvents;
};