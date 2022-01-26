// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import {IERC20, ILockedToken, IOwnable, IOfferFactory} from "./interfaces/Interfaces.sol";

contract LockedTokenOffer {
    address public immutable factory;
    address public immutable seller;
    address public immutable lockedTokenAddress;
    address public immutable tokenWanted;
    uint256 public immutable amountWanted;
    uint256 public immutable fee; // in bps
    bool public hasEnded = false;

    event OfferFilled(address buyer, uint256 lockedTokenAmount, address token, uint256 tokenAmount);
    event OfferCanceled(address seller, uint256 lockedTokenAmount);

    constructor(
        address _seller,
        address _lockedTokenAddress,
        address _tokenWanted,
        uint256 _amountWanted,
        uint256 _fee
    ) {
        factory = msg.sender;
        seller = _seller;
        lockedTokenAddress = _lockedTokenAddress;
        tokenWanted = _tokenWanted;
        amountWanted = _amountWanted;
        fee = _fee;
    }

    // release trapped funds
    function withdrawTokens(address token) public {
        require(msg.sender == IOwnable(factory).owner());
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(IOwnable(factory).owner()).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            safeTransfer(token, IOwnable(factory).owner(), balance);
        }
    }

    function fill() public {
        require(hasLockedToken(), "no Locked Token balance");
        require(!hasEnded, "sell has been previously cancelled");
        uint256 balance = ILockedToken(lockedTokenAddress).totalBalanceOf(address(this));
        uint256 txFee = mulDiv(amountWanted, fee, 10_000);

        // cap fee at 25k
        uint256 maxFee = 25_000 * 10**IERC20(tokenWanted).decimals();
        txFee = txFee > maxFee ? maxFee : txFee;

        uint256 amountAfterFee = amountWanted - txFee;
        // collect fee
        _sendFees(txFee);
        // exchange assets
        safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        ILockedToken(lockedTokenAddress).transferAll(msg.sender);
        hasEnded = true;
        emit OfferFilled(msg.sender, balance, tokenWanted, amountWanted);
    }

    function cancel() public {
        require(hasLockedToken(), "no Locked Token balance");
        require(msg.sender == seller);
        uint256 balance = ILockedToken(lockedTokenAddress).totalBalanceOf(address(this));
        ILockedToken(lockedTokenAddress).transferAll(seller);
        hasEnded = true;
        emit OfferCanceled(seller, balance);
    }

    function hasLockedToken() public view returns (bool) {
        return ILockedToken(lockedTokenAddress).totalBalanceOf(address(this)) > 0;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return (x * y) / z;
    }

    function _sendFees(uint256 feeAmount) internal {
        uint256 escrowFeeAmount = mulDiv(feeAmount, 2, 3);  // 2/3rds of fee to escrow
        uint256 xFoxFeeAmount = (feeAmount - escrowFeeAmount) / 2;
        uint256 devFeeAmount = feeAmount - escrowFeeAmount - xFoxFeeAmount;

        safeTransferFrom(tokenWanted, msg.sender, IOfferFactory(factory).escrowMultisigFeeAddress(), escrowFeeAmount);
        safeTransferFrom(tokenWanted, msg.sender, IOfferFactory(factory).xFoxAddress(), xFoxFeeAmount);
        safeTransferFrom(tokenWanted, msg.sender, IOfferFactory(factory).devAddress(), devFeeAmount);
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransfer: failed");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransferFrom: failed");
    }
}
