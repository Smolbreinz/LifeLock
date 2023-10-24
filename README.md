# LifeLock
Crypto Inheritance Service

Basic overview

This protocol aims to enable users to protect their ERC20 tokens without giving up control over them.
The two smart contracts in this repository aim to achieve this functionality.


LegacyFactory smart contract:

Enables a user to create a user Safe(Mlegacy) smart contract the he is the owner of.
Also stores the Safes created with its owners, recipients and contract addresses to enable match owners to recipients to contracts if each of those are not aware of the Safe address.


Safe (MLegacy) smart contract:

Allows the user to store ERC20 tokens in an array, which he then has to approve for the MLegacy contract to spend on his behalf.
To restrict a premature withdrawal, the user can set a point in time after which his assets should be withdrawable. This point in time can be updated as often as desired by the owner.

Allows the recipient to withdraw the allowance of the tokens stored in the safe after the protection period expires.
