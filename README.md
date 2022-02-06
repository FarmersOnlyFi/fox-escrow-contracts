# FoxSwap Escrow Contracts

Contracts to allow trustless trading of locked tokens and DFK items.

### Harmony MainNet Contracts

- OfferFactory: `0x8773d7FCaC1A2811BCD29039331E9B0B9e584d00`
- OfferLens: `0x924715d0690e75D94A4c14290Ac3B4Ae5F4A3f6a`
- ItemOfferFactory: `0x65EC385A6ab6f1081e8862c406c73f4edc6C0eEb`
- ItemLens `0xd550e4a7ab33c45C64116b8d47E459DfeEb557d0`


### Business Logic:

User's create an offer by calling `OfferFactory.createOffer(address _lockedTokenAddress, address _tokenWanted, uint256 _amountWanted)`. This defines which locked token they are selling, which token they want as payment (usually a stablecoin), and how much they want as payment. This will create a new contract for the user. The user then sends their locked token to this contract allowing anyone to buy the locked token for the amount of stable coin listed.

The `LockedTokenOffer` has 2 exit conditions.
1. The contract is filled. This should transfer the locked tokens to the buyer and send the stablecoin to the seller (minus the fee)
2. The contract is cancelled. This should give the seller back all of their locked tokens and set `hasEnded = True` on the contract, effectively making this contract void. 
