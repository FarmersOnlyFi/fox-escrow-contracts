
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


factory = OfferFactory.deploy(Accs.from_deployer())
# 0x0562e87B1c808Ec5177570b13644C58f41a54075
# factory = Contract.from_abi("OfferFactory", "0x0562e87B1c808Ec5177570b13644C58f41a54075", OfferFactory.abi)

for token in locked_token_addresses:
    resp = factory.addLockedTokenSupport(token, True)

