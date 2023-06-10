# Signature Malleability

[![Test smart contracts](https://github.com/pcaversaccio/malleable-signatures/actions/workflows/test.yml/badge.svg)](https://github.com/pcaversaccio/malleable-signatures/actions/workflows/test.yml)
[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-blue.svg)](http://www.wtfpl.net/about)

This repository implements a simplified [PoC](./test/SignatureMalleability.t.sol) that showcases how signature malleability attacks, using compact signatures, can be executed. We the OpenZeppelin version [`4.6`](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v4.6), which is vulnerable to the signature malleability exploit, using compact signatures showcased in this PoC. The vulnerability was patched in version [`4.7.3`](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v4.7.3).
