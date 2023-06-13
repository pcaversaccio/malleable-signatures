# Signature Malleability

[![Test smart contracts](https://github.com/pcaversaccio/malleable-signatures/actions/workflows/test.yml/badge.svg)](https://github.com/pcaversaccio/malleable-signatures/actions/workflows/test.yml)
[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-blue.svg)](http://www.wtfpl.net/about)

This repository implements a simplified [PoC](./test/SignatureMalleability.t.sol) that demonstrates how signature malleability attacks using compact signatures can be executed. This showcases two separate issues:

1.  A vulnerability with the [OpenZeppelin `4.6`](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v4.6) ECDSA library which is vulnerable to the signature malleability exploit. The vulnerability was patched in version [`4.7.3`](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v4.7.3).

2.  Signatures must not be used as unique identifiers since the [`ecrecover`](https://www.evm.codes/precompiled#0x01?fork=shanghai) precompile allows for malleable (non-unique) signatures.
