const fs = require('fs')
const zip = new require('node-zip')();
const deploymentManifest = [];
const abiRef = {};

function addFile(path, metadata={}) {
    try {
        const data = JSON.parse(fs.readFileSync(path, 'utf8'));
        const filename = path.substring(path.lastIndexOf('/')+1);
        deploymentManifest.push({
            filename,
            metadata,
            data
        });
        abiRef[data.contractName] = data.abi;

    } catch (err) {
        console.error(err)
    }
}

// -----------------------
// ----- Game Logic ------
// -----------------------

addFile('./artifacts/contracts/ApplicationRegistry.sol/ApplicationRegistry.json');
addFile('./artifacts/contracts/CommonLib.sol/CommonLib.json', {
    registration: 'registerCommonLib'
});
addFile('./artifacts/contracts/ScopedRandomGenerator.sol/ScopedRandomGenerator.json', {
    registration: 'registerScopedRandomGenerator'
});
addFile('./artifacts/contracts/Grid.sol/Grid.json', {
    registration: 'registerGrid',
    args: [
        {name:'ApplicationRegistry'},
        {name:'minX', value:'0'},
        {name:'minY', value:'0'},
        {name:'maxX', value:'10'},
        {name:'maxY', value:'10'}
    ]
});
addFile('./artifacts/contracts/PlayerEventCallbacks.sol/PlayerEventCallbacks.json', {
    registration: 'registerPlayerEventCallbacks',
    args: [{name: 'ApplicationRegistry'}]
});
addFile('./artifacts/contracts/Player.sol/Player.json', {
    registration: 'registerPlayer',
    args: [{name: 'ApplicationRegistry'}]
});
addFile('./artifacts/contracts/Item.sol/Item.json', {
    registration: 'registerItem',
    args: [{name: 'ApplicationRegistry'}]
});
addFile('./artifacts/contracts/Stats.sol/Stats.json', {
    registration: 'registerStats',
    args: [{name: 'ApplicationRegistry'}]
});
addFile('./artifacts/contracts/MovementController.sol/MovementController.json', {
    registration: 'registerMovementController',
    args: [{name: 'ApplicationRegistry'}]
});

// --------------------
// ----- Actions ------
// --------------------

addFile('./artifacts/contracts/PlayerActions.sol/PlayerActions.json', {
    registration: 'registerPlayerActions',
    args: [{name: 'ApplicationRegistry'}]
});

addFile('./artifacts/contracts/TileActions.sol/TileActions.json', {
    registration: 'registerTileActions',
    args: [{name: 'ApplicationRegistry'}]
});

// ------------------
// ----- Views ------
// ------------------

addFile('./artifacts/contracts/GameView.sol/GameView.json', {
    registration: 'registerGameView',
    args: [{name: 'ApplicationRegistry'}]
});

zip.file('_deploymentManifest', JSON.stringify(deploymentManifest));

const zipFileContent = zip.generate({base64:false,compression:'DEFLATE'});
fs.writeFileSync('./artifacts/deployment.zip', zipFileContent, 'binary');
fs.writeFileSync('./artifacts/abiRef.js', "export default " + JSON.stringify(abiRef));
