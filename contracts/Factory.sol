// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IUniswapV2Router} from "../interfaces/IUniswapV2Router.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IFactory.sol} from "../interfaces/IFactory.sol";

contract Factory is IFactory, Ownable {
    IUniswapV2Router public router;
    IERC20 private token;
    address public usdAddress;
    uint32 public tokenomic; // user will be discount 20% if they pay by token
    AggregatorV3Interface internal priceFeed;

    constructor(
        address _aggregator,
        address router_,
        address token_,
        address usd_
    ) {
        priceFeed = AggregatorV3Interface(_aggregator);
        router = IUniswapV2Router(router_);
        token = IERC20(token_);
        usdAddress = usd_;
    }

    function getToken() public view returns (IERC20) {
        return token;
    }

    function changeToken(address _newToken) public onlyOwner {
        token = IERC20(_newToken);
    }

    // This function will return by wei value
    function usdToNativeToken(uint256 usd) public view returns (uint256) {
        (
            ,
            /*uint80 roundID*/
            int256 price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        uint256 result = (usd * (10 ** 26)) / uint256(price);
        return result;
    }

    // This function will return by wei value
    function usdToHuraToken(uint256 _price) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = usdAddress;
        path[1] = address(token);
        uint256[] memory amountOuts = router.getAmountsOut(_price * 1e18, path); // busd price = hura token amount
        return amountOuts[1];
    }

    function random() external view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        usdToNativeToken(1)
                    )
                )
            );
    }
}
