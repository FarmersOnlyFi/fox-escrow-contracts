// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    function balanceOf(address _holder) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ILockedToken {
    function totalBalanceOf(address _holder) external view returns (uint256);
    function transferAll(address _to) external;
    function lockOf(address _holder) external view returns (uint256);
}

interface ILockedTokenOffer {
    function lockedTokenAddress() external view returns (address);
    function amountWanted() external view returns (uint256);
    function tokenWanted() external view returns (address);
}

interface IOfferFactory {
    function xFoxAddress() external view returns (address);
    function devAddress() external view returns (address);
    function escrowMultisigFeeAddress() external view returns (address);
    function offers() external view returns (ILockedTokenOffer[] memory);
    function getActiveOffers() external view returns (ILockedTokenOffer[] memory);
}

interface IOwnable {
    function owner() external view returns (address);
}
