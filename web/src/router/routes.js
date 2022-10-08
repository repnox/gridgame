import Home from "../views/Home";
import DeploySmartContract from "../views/admin/DeploySmartContract";
import InspectApplicationRegistry from "../views/admin/InspectApplicationRegistry";
import MintNFT from "../views/admin/MintNFT";
import GameDesigner from "../views/admin/GameDesigner";
import Error404 from "../views/Error404";

export default [
    {
        path: '/',
        name: 'Home',
        component: Home
    },
    // -------------------------------------
    // Admin Pages:
    {
        path: '/admin/deploy-smart-contract',
        name: 'Deploy Smart Contract',
        component: DeploySmartContract
    },
    {
        path: '/admin/inspect',
        name: 'Inspect Application Registry',
        component: InspectApplicationRegistry
    },
    {
        path: '/admin/mint-nft',
        name: 'Mint NFT',
        component: MintNFT
    },
    {
        path: '/admin/game-designer',
        name: 'Game Designer',
        component: GameDesigner
    },
    // -------------------------------------
    // Error:
    {
        path: '*',
        name: 'Error Not Found',
        component: Error404
    },
];