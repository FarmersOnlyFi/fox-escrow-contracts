
import random
from scripts.deploy_utils import *

Accs = setup_mainnet_accounts()

locked_token_addresses = [
    "0x72Cb10C6bfA5624dD07Ef608027E366bd690048F",  # JEWEL
    "0xEa589E93Ff18b1a1F1e9BaC7EF3E86Ab62addc79",  # VIPER
    "0xbDa99C8695986B45a0dD3979cC6f3974D9753D30",  # LOOT
    "0x892D81221484F690C0a97d3DD18B9144A3ECDFB7",  # MAGIC
    "0x1e05C8B69e4128949FcEf16811a819eF2f55D33E",  # SONIC
    "0xE7bBE0E193FdFe95d2858F5C46d036065f8F735c",  # BOSS
]

lens = LockedTokenLens.deploy(Accs.from_deployer())
# 0x8C5bbDA7992285628910f12E7fbD09ab4570C58A
# TestNet:


factory = OfferFactory.deploy(Accs.from_deployer())
# 0xFa27cc94CA57f98b565f8fD165002FB98e1BC362
# factory = Contract.from_abi("OfferFactory", "0xFa27cc94CA57f98b565f8fD165002FB98e1BC362", OfferFactory.abi)
# TestNet:

for token in locked_token_addresses:
    resp = factory.addLockedTokenSupport(token, True)


# TestNet
from scripts.deploy_utils import *
Accs = setup_mainnet_accounts()

#lens = Contract.from_abi("LockedTokenLens", "0x0a13b0De3f46aa245125b3F519CC8A1FE96f4126", LockedTokenLens.abi)
factory = OfferFactory[-1]

lens = LockedTokenLens.deploy(Accs.from_deployer())

usdc = Contract.from_abi("USDC", "0xC6A6cD8E4a0134b37E3595DBac6f738970fC01A6", USDC.abi)
usdt = USDT[-1]
busd = Contract.from_abi("BUSD", "0x3F9E6D6328D83690d74a75C016D90D7e26A7188c", BUSD.abi)
ust = Contract.from_abi("UST", "0xE6FCfd410a993572713c47a3638478288d06aB2d", UST.abi)
jewel = Contract.from_abi("JEWEL", "0x25Cb9C2720B88E336c374CF24be68D42bA7243A4", JewelToken.abi)
viper = Contract.from_abi("JEWEL", "0x4d378E5e189f435B3B1879772A2C2A4c76F5eA36", JewelToken.abi)
gold = DfkItems[-1]

# lens = LockedTokenLens[-1]
#


factory = OfferFactory.deploy(Accs.from_deployer())
factory.addLockedTokenSupport(jewel, True)
factory.addLockedTokenSupport(viper, True)

print(f"\nLocked Tokens:")
print(f"JEWEL:\t0x25Cb9C2720B88E336c374CF24be68D42bA7243A4")
print(f"VIPER:\t0x4d378E5e189f435B3B1879772A2C2A4c76F5eA36")
print("\nStableCoins:")
print(f"USDC:\t0xC6A6cD8E4a0134b37E3595DBac6f738970fC01A6")
print(f"BUSD:\t0x3F9E6D6328D83690d74a75C016D90D7e26A7188c")
print(f"UST:\t0xE6FCfd410a993572713c47a3638478288d06aB2d")
print()
print(f"OfferLens:\t0x316B9E75Ec70F3c3EECc45a5a7db48eD61278d76")
print(f"OfferFactory:\t0xe0049F5Ab62078B9Bb84BD71f6E4D735ad4868aA")


def mint_all(acc):
    jewel_amount = int(1000 * (1 + random.random()) * 1e18)
    jewel.mint(acc, jewel_amount, Accs.from_deployer())
    jewel.lock(acc, jewel_amount, Accs.from_deployer())

    viper_amount = int(10000 * (1 + random.random()) * 1e18)
    viper.mint(acc, viper_amount, Accs.from_deployer())
    viper.lock(acc, viper_amount, Accs.from_deployer())

    usdc.mint(acc, 1e22, Accs.from_deployer())
    busd.mint(acc, 1e23, Accs.from_deployer())
    ust.mint(acc, 1e24, Accs.from_deployer())
    usdt.mint(acc, 1e11, Accs.from_dev())

    for dfk_item in DfkItem[:-1]:
        dfk_item_amt = int(5 + 20 * random.random())
        dfk_item.mint(acc, dfk_item_amt, Accs.from_dev())

    dfk_item_amt = int(5 + 20 * random.random())
    DfkItem[-1].mint(acc, dfk_item_amt, Accs.from_deployer())

    Accs.dev.transfer(acc, 2e18)

# crypto_vegan = "0x0C651AEcDf68600a2458Ed1A3f36f2c974D43234"
# psybermonk = "0x2A8d9fEe2ECD79c8d52244260C0A9BE945DB4951"
# sammyboi = "0xe36093669f8d05f555323E9F0Aee6A2BC41097C1"
mint_all(sammyboi)


# Create offer
resp = factory.createOffer(jewel, usdc, 12345e18, Accs.from_dev())
print(resp.events)

resp = factory.createOffer(viper, ust, 123e18, Accs.from_dev())
print(resp.events)
viper.transferAll('', Accs.from_dev())


bloater = DfkItem.deploy(Accs.from_dev())
ragweed = DfkItem.deploy(Accs.from_dev())

item_factory = ItemOfferFactory.deploy(Accs.from_dev())
item_factory.addItemSupport(bloater, True, Accs.from_dev())
item_factory.addItemSupport(ragweed, True, Accs.from_dev())

item_lens = ItemLens.deploy(Accs.from_dev())

# Create offer
resp = item_factory.createOffer(bloater, ust, 1e18, Accs.from_dev())
offer1 = Contract.from_abi("ItemOffer", resp.events["OfferCreated"]['offerAddress'], ItemOffer.abi)
