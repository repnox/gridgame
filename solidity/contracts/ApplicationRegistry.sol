// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IsAccessRegisteredInterface.sol";
import "./interface/GetCommonLibInterface.sol";
import "./interface/GetGridInterface.sol";
import "./interface/GetPlayerInterface.sol";
import "./interface/GetRandomGeneratorInterface.sol";
import "./interface/GetPlayerStakingInterface.sol";
import "./interface/GetPlayerEventCallbacksInterface.sol";
import "./MovementController.sol";
import "./Grid.sol";
import "./Player.sol";
import "./Item.sol";
import "./Stats.sol";
import "./CommonLib.sol";
import "./ScopedRandomGenerator.sol";

contract ApplicationRegistry is
        GetCommonLibInterface,
        IsAccessRegisteredInterface,
        GetGridInterface,
        GetPlayerInterface,
        GetScopedRandomGeneratorInterface,
        GetPlayerEventCallbacksInterface,
        GetPlayerStakingInterface,
        Ownable
{

    address constant NULL = address(0);

    mapping(address => bool) appAccessLookup;

    CommonLib public commonLib;
    ScopedRandomGenerator public scopedRandomGenerator;
    Grid public grid;
    MovementController public movementController;
    Player public player;
    Item public item;
    Stats public stats;

    // use address to be more extendable
    address public gameView;
    address public playerActions;
    address public tileActions;
    address public playerEventCallbacks;
    address public playerStaking;

    constructor() {
        _registerAccess(msg.sender);
    }

    function getCommonLib() external override view returns (address) {
        return address(commonLib);
    }

    function getGrid() external override view returns (address) {
        return address(grid);
    }

    function getPlayer() external override view returns (address) {
        return address(player);
    }

    function getScopedRandomGenerator() external override view returns (address) {
        return address(scopedRandomGenerator);
    }

    function getPlayerEventCallbacks() external override view returns (address) {
        return playerEventCallbacks;
    }

    function getPlayerStaking() external override view returns (address) {
        return playerStaking;
    }

    function isAccessRegistered(address app) external override view returns (bool) {
        return appAccessLookup[app];
    }

    function selfDestruct() external onlyOwner {
        commonLib = CommonLib(NULL);
        scopedRandomGenerator = ScopedRandomGenerator(NULL);
        grid = Grid(NULL);
        movementController = MovementController(NULL);
        player = Player(NULL);
        item = Item(NULL);
        stats = Stats(NULL);

        gameView = NULL;
        _deregisterAccess(playerActions);
        _deregisterAccess(tileActions);
        _deregisterAccess(address(player));
        _deregisterAccess(address(item));
        _deregisterAccess(address(grid));
    }

    function registerCommonLib(CommonLib app) external onlyOwner {
        commonLib = app;
    }

    function registerScopedRandomGenerator(ScopedRandomGenerator app) external onlyOwner {
        scopedRandomGenerator = app;
    }

    function registerGrid(Grid app) external onlyOwner {
        grid = app;
        _registerAccess(address(app));
    }

    function registerMovementController(MovementController app) external onlyOwner {
        movementController = app;
    }

    function registerPlayer(Player app) external onlyOwner {
        player = app;
        _registerAccess(address(app));
    }

    function registerItem(Item app) external onlyOwner {
        item = app;
        _registerAccess(address(app));
    }

    function registerStats(Stats app) external onlyOwner {
        stats = app;
    }

    function registerGameView(address app) external onlyOwner {
        gameView = app;
    }

    function registerPlayerActions(address app) external onlyOwner {
        playerActions = app;
        _registerAccess(app);
    }

    function registerTileActions(address app) external onlyOwner {
        tileActions = app;
        _registerAccess(app);
    }

    function registerPlayerEventCallbacks(address app) external onlyOwner {
        playerEventCallbacks = app;
        _registerAccess(app);
    }

    function registerPlayerStaking(address app) external onlyOwner {
        playerStaking = app;
    }

    function registerAccess(address app) external onlyOwner {
        _registerAccess(app);
    }

    function deregisterAccess(address app) external onlyOwner {
        _deregisterAccess(app);
    }

    function _registerAccess(address app) internal {
        appAccessLookup[app] = true;
    }

    function _deregisterAccess(address app) internal {
        appAccessLookup[app] = false;
    }


}
