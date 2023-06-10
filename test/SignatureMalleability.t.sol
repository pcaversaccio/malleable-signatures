// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

/**
 * @dev Error that occurs when the signature length is invalid.
 * @param emitter The contract that emits the error.
 */
error InvalidSignatureLength(address emitter);

/**
 * @dev Error that occurs when the signature value `s` is invalid.
 * @param emitter The contract that emits the error.
 */
error InvalidSignatureSValue(address emitter);

contract SignatureMalleabilityTest is Test {
    using BytesLib for bytes;

    /**
     * @dev Transforms a standard signature into an EIP-2098
     * compliant signature.
     * @param signature The secp256k1 64/65-bytes signature.
     * @return short The 64-bytes EIP-2098 compliant signature.
     */
    function to2098Format(bytes memory signature) internal view returns (bytes memory) {
        if (signature.length != 65) revert InvalidSignatureLength(self);
        if (uint8(signature[32]) >> 7 == 1) revert InvalidSignatureSValue(self);
        bytes memory short = signature.slice(0, 64);
        uint8 parityBit = uint8(short[32]) | ((uint8(signature[64]) % 27) << 7);
        short[32] = bytes1(parityBit);
        return short;
    }

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }
}
