
from scripts.deploy_utils import *
from scripts.dfk_items import DfkItems

Accs = setup_mainnet_accounts()

locked_token_addresses = [
    "0x72Cb10C6bfA5624dD07Ef608027E366bd690048F",  # JEWEL
    "0xEa589E93Ff18b1a1F1e9BaC7EF3E86Ab62addc79",  # VIPER
    "0xbDa99C8695986B45a0dD3979cC6f3974D9753D30",  # LOOT
    "0x892D81221484F690C0a97d3DD18B9144A3ECDFB7",  # MAGIC
    "0x1e05C8B69e4128949FcEf16811a819eF2f55D33E",  # SONIC
    "0xE7bBE0E193FdFe95d2858F5C46d036065f8F735c",  # BOSS
]

# Locked Tokens
factory = OfferFactory.deploy(Accs.from_deployer())
lens = LockedTokenLens.deploy(Accs.from_deployer())

for token in locked_token_addresses:
    if not factory.supportedItems(token):
        resp = factory.addLockedTokenSupport(token, True)

# DfkItems
item_factory = ItemOfferFactory.deploy(Accs.from_deployer())
item_lens = ItemLens.deploy(Accs.from_deployer())

for k, addr in DfkItems.items():
    if item_factory.supportedItems(addr):
        print(f"Already have {k}: {addr}")
    else:
        print(f"Adding {k}: {addr}")
        item_factory.addItemSupport(addr, True, Accs.from_deployer())


print(f"""Addresses:
LockedTokenFactory:\t{factory.address}
LockedTokenLens:\t{lens.address}
ItemTokenFactory:\t{item_factory.address}
ItemLens:\t{item_lens.address}
""")
