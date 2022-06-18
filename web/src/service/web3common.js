import {BigNumber, Contract, ethers} from "ethers";
import abiRef from "../ref/abiRef";
import store from "../store"
import eventBus from "./eventBus";

export default {
    getProvider() {
        return new ethers.providers.Web3Provider(window.ethereum);
    },
    async getSigner() {
        try {
            const provider = this.getProvider();
            await provider.send("eth_requestAccounts", []);
            return await provider.getSigner();
        } catch (err) {
            eventBus.$emit("WALLET_ERROR");
            throw err;
        }
    },
    async getCurrentWalletAddress() {
        let signer = await this.getSigner();
        return await signer.getAddress();
    },
    async getContractFromRegistry(contractName) {
        let appReg = await this.getApplicationRegistry();
        let address = await appReg[contractName.substring(0,1).toLowerCase() + contractName.substring(1)]();
        return await this.getContractByName(contractName, address);
    },
    async getApplicationRegistry() {
        return await this.getContractByName("ApplicationRegistry", store.state.applicationRegistryAddress);
    },
    async getPlayerActions() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("PlayerActions", await appReg.playerActions());
    },
    async getTileActions() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("TileActions", await appReg.tileActions());
    },
    async getGameView() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("GameView", await appReg.gameView());
    },
    async getGrid() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("Grid", await appReg.grid());
    },
    async getPlayer() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("Player", await appReg.player());
    },
    async getItem() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("Item", await appReg.item());
    },
    async getMovementController() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("MovementController", await appReg.movementController());
    },
    async getStats() {
        let appReg = await this.getApplicationRegistry();
        return await this.getContractByName("Stats", await appReg.stats());
    },
    async getContractByName(name, address) {
        return await this.getContract(abiRef[name], address);
    },
    async getContract(abi, address) {
        return new Contract(address, abi, await this.getSigner());
    },
    async connectToPolygon() {
        return await this.getProvider().send('wallet_addEthereumChain', [{
            chainId: '0x89',
            chainName: 'Polygon Mainnet',
            nativeCurrency: {
                name: 'Polygon',
                symbol: 'MATIC',
                decimals: 18
            },
            rpcUrls: ['https://polygon-rpc.com/'],
            blockExplorerUrls: ['https://polygonscan.com']
        }]);
    },
    bnToNumber(bn) {
        return BigNumber.from(bn._hex).toNumber();
    },
    bnToHex(bn) {
        return bn._hex;
    }

}