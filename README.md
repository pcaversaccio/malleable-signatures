# Signature Malleability

[![Test smart contracts](https://github.com/pcaversaccio/malleable-signatures/actions/workflows/test.yml/badge.svg)](https://github.com/pcaversaccio/malleable-signatures/actions/workflows/test.yml)
[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-blue.svg)](http://www.wtfpl.net/about)

This repository implements a simplified [PoC](./test/SignatureMalleability.t.sol) that demonstrates how signature malleability attacks using [compact signatures](https://eips.ethereum.org/EIPS/eip-2098) can be executed. The PoC showcases two interconnected issues:

1. A vulnerability with the [OpenZeppelin `4.6` ECDSA library](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.6/contracts/utils/cryptography/ECDSA.sol) which is vulnerable to the signature malleability exploit. The vulnerability was patched in version [`4.7.3`](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v4.7.3). Also, see [here](https://github.com/OpenZeppelin/openzeppelin-contracts/security/advisories/GHSA-4h98-2769-gh6h) for the published security advisory.

2. Signatures MUST NOT be used as unique identifiers, since the [`ecrecover`](https://www.evm.codes/precompiled#0x01?fork=shanghai) precompile generally allows for malleable (non-unique) signatures (see [EIP-2](https://eips.ethereum.org/EIPS/eip-2)). The underlying issue stems from the fact that there are two `y`-coordinates for every `x`-coordinate on the elliptic curve. The OpenZeppelin ECDSA library prevents this particular malleability attack vector by reverting if the secp256k1 32-byte signature parameter `s` is too high.
