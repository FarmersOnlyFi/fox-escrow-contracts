// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./interfaces/IERC20.sol";
import "./interfaces/IItemOfferFactory.sol";
import "./interfaces/IOwnable.sol";

contract ItemOffer {
    address public immutable factory;
    address public immutable seller;
    address public immutable itemAddress;
    address public immutable tokenWanted;
    uint256 public immutable priceWanted;
    uint256 public immutable fee; // in bps
    bool public hasEnded = false;

    event OfferFilled(address buyer, uint256 itemAmount, address token, uint256 tokenAmount);
    event OfferCanceled(address seller, uint256 itemAmount);

    constructor(
        address _seller,
        address _itemAddress,
        address _tokenWanted,
        uint256 _priceWanted,
        uint256 _fee
    ) {
        factory = msg.sender;
        seller = _seller;
        itemAddress = _itemAddress;
        tokenWanted = _tokenWanted;
        priceWanted = _priceWanted;
        fee = _fee;
    }

    // release trapped funds
    function withdrawTokens(address token) public {
        require(msg.sender == IOwnable(factory).owner());
        require(token != itemAddress, "cannot withdraw item");
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(IOwnable(factory).owner()).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            safeTransfer(token, IOwnable(factory).owner(), balance);
        }
    }

    function fill(uint _itemAmount) public {
        require(!hasEnded, "sell has been previously cancelled");
        require(hasItems(), "No items on contract");
        if (_itemAmount > totalItems()) {
            _itemAmount = totalItems();
        }
        // Compute total amount based on price
        uint256 totalAmount = priceWanted * _itemAmount;
        uint256 txFee = mulDiv(totalAmount, fee, 10_000);

        // cap fee at 25k
        uint256 maxFee = 25_000 * 10**IERC20(tokenWanted).decimals();
        txFee = txFee > maxFee ? maxFee : txFee;

        uint256 amountAfterFee = totalAmount - txFee;
        // collect fee
        _sendFees(txFee);
        // exchange assets
        safeTransferFrom(tokenWanted, msg.sender, seller, amountAfterFee);
        safeTransfer(itemAddress, msg.sender, _itemAmount);
        // Normalize to 18 decimals
        IItemOfferFactory(factory).logTransactionVolume(mulDiv(totalAmount, 1e18, 10**IERC20(tokenWanted).decimals())) ;
        emit OfferFilled(msg.sender, _itemAmount, tokenWanted, totalAmount);
    }

    function cancel() public {
        require(hasItems(), "no items on contract");
        require(msg.sender == seller, "only seller can cancel");
        uint256 balance = totalItems();
        safeTransfer(itemAddress, seller, balance);
        hasEnded = true;
        emit OfferCanceled(seller, balance);
    }

    function hasItems() public view returns (bool) {
        return IERC20(itemAddress).balanceOf(address(this)) > 0;
    }

    function totalItems() public view returns (uint256) {
        return IERC20(itemAddress).balanceOf(address(this));
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return (x * y) / z;
    }

    function _sendFees(uint256 feeAmount) internal {
        uint256 escrowFeeAmount = mulDiv(feeAmount, 1, 3);
        uint256 xFoxFeeAmount = (feeAmount - escrowFeeAmount) / 2;
        uint256 devFeeAmount = feeAmount - escrowFeeAmount - xFoxFeeAmount;

        safeTransferFrom(tokenWanted, msg.sender, IItemOfferFactory(factory).escrowMultisigFeeAddress(), escrowFeeAmount);
        safeTransferFrom(tokenWanted, msg.sender, IItemOfferFactory(factory).xFoxAddress(), xFoxFeeAmount);
        safeTransferFrom(tokenWanted, msg.sender, IItemOfferFactory(factory).devAddress(), devFeeAmount);
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
