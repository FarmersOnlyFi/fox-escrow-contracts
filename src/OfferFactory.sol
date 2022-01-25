// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import {Ownable} from "./Ownable.sol";
import {LockedTokenOffer} from "./LockedTokenOffer.sol";

contract OfferFactory is Ownable {
    uint256 public fee = 120; // in bps
    uint256 public MAX_FEE = 400; // 4%

    address public xFoxAddress = 0xb46B7A8160A114091b5E62C2Ee090B0997D99e5a;
    address public devAddress = 0xB989B490F9899a5AD56a4255A3C84457040B59dc;
    address public escrowMultisigFeeAddress; // TODO

    mapping(address => bool) public supportedTokens;
    LockedTokenOffer[] public offers;

    event OfferCreated(address offerAddress, address lockedTokenAddress, address tokenWanted, uint256 amountWanted);
    event LockedTokenSupportUpdate(address lockedTokenAddress, bool supported);

    function setFee(uint256 _fee) public onlyOwner {
        require(_fee < MAX_FEE, 'Fee to high');
        fee = _fee;
    }

    function addLockedTokenSupport(address _lockedToken, bool _supported) public onlyOwner {
        supportedTokens[_lockedToken] = _supported;

        emit LockedTokenSupportUpdate(_lockedToken, _supported);
    }

    function createOffer(address _lockedTokenAddress, address _tokenWanted, uint256 _amountWanted) public returns (LockedTokenOffer) {
        require(supportedTokens[_lockedTokenAddress], 'Locked Token not supported');
        LockedTokenOffer offer = new LockedTokenOffer(msg.sender, _lockedTokenAddress, _tokenWanted, _amountWanted, fee);
        offers.push(offer);
        emit OfferCreated(address(offer), _lockedTokenAddress, _tokenWanted, _amountWanted);
        return offer;
    }

    function getActiveOffersByOwner() public view returns (LockedTokenOffer[] memory, LockedTokenOffer[] memory) {
        LockedTokenOffer[] memory myBids = new LockedTokenOffer[](offers.length);
        LockedTokenOffer[] memory otherBids = new LockedTokenOffer[](offers.length);

        uint256 myBidsCount;
        uint256 otherBidsCount;
        for (uint256 i; i < offers.length; i++) {
            LockedTokenOffer offer = LockedTokenOffer(offers[i]);
            if (offer.hasLockedToken() && !offer.hasEnded()) {
                if (offer.seller() == msg.sender) {
                    myBids[myBidsCount++] = offers[i];
                } else {
                    otherBids[otherBidsCount++] = offers[i];
                }
            }
        }

        return (myBids, otherBids);
    }

    function getActiveOffers() public view returns (LockedTokenOffer[] memory) {
        LockedTokenOffer[] memory activeOffers = new LockedTokenOffer[](offers.length);
        uint256 count;
        for (uint256 i; i < offers.length; i++) {
            LockedTokenOffer offer = LockedTokenOffer(offers[i]);
            if (offer.hasLockedToken() && !offer.hasEnded()) {
                activeOffers[count++] = offer;
            }
        }

        return activeOffers;
    }

    function getActiveOffersByRange(uint256 start, uint256 end) public view returns (LockedTokenOffer[] memory) {
        LockedTokenOffer[] memory activeOffers = new LockedTokenOffer[](end - start);

        uint256 count;
        for (uint256 i = start; i < end; i++) {
            if (offers[i].hasLockedToken() && !offers[i].hasEnded()) {
                activeOffers[count++] = offers[i];
            }
        }

        return activeOffers;
    }
}
