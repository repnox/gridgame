module.exports = async (promise, reason) => {
    try {
        await promise;
    } catch (error) {
        if (reason) assert.equal(reason, error.reason);
        return;
    }
    assert.fail('Expected throw not received');
};