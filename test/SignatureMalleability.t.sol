// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {BytesLib} from "solidity-bytes-utils/BytesLib.sol";

/**
 * @dev We use the version `4.6`, which is vulnerable to the signature malleability exploit,
 * using compact signatures showcased below:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v4.6.
 */
import {ECDSA} from "openzeppelin/utils/cryptography/ECDSA.sol";

contract Verifier {
    /**
     * @dev Error that occurs when the signature has already been used.
     * @param emitter The contract that emits the error.
     */
    error SignatureUsed(address emitter);

    /**
     * @dev Error that occurs when the signature is invalid.
     * @param emitter The contract that emits the error.
     */
    error InvalidSignature(address emitter);

    mapping(address sender => uint256 counter) public signatureCounter;
    mapping(bytes signature => bool flag) private signatureUsed;

    address private self = address(this);

    function verifySignature(bytes32 hash, bytes memory signature) public {
        if (signatureUsed[signature]) revert SignatureUsed(self);

        address signer = ECDSA.recover(hash, signature);
        if (signer != msg.sender) revert InvalidSignature(self);
        unchecked {
            /// @dev For testing purposes, the counter is simply incremented.
            signatureCounter[msg.sender] += 1;
        }

        /// @dev We use the signature as unique identifier. DO NOT DO THIS!
        signatureUsed[signature] = true;
    }
}

contract SignatureMalleabilityTest is Test {
    using BytesLib for bytes;

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

    /**
     * @dev Error that occurs when the signature has already been used.
     * @param emitter The contract that emits the error.
     */
    error SignatureUsed(address emitter);

    Verifier private verifier;
    address private self = address(this);

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
        verifier = new Verifier();
    }

    function testMalleableSignature() public {
        (address alice, uint256 key) = makeAddrAndKey("alice");
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", "WAGMI"));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        /**
         * @dev Standard signature check.
         */
        vm.startPrank(alice);
        verifier.verifySignature(hash, signature);
        assertEq(verifier.signatureCounter(alice), 1);

        vm.expectRevert(abi.encodeWithSelector(SignatureUsed.selector, address(verifier)));
        /// @dev Must revert since the signature has already been used.
        verifier.verifySignature(hash, signature);

        /**
         * @dev EIP-2098 signature check.
         */
        bytes memory signature2098 = to2098Format(signature);
        verifier.verifySignature(hash, signature2098);
        /// @dev Malleability successfully exploited!
        assertEq(verifier.signatureCounter(alice), 2);

        vm.expectRevert(abi.encodeWithSelector(SignatureUsed.selector, address(verifier)));
        /// @dev Must revert since the signature has already been used.
        verifier.verifySignature(hash, signature2098);
        vm.stopPrank();
    }
}
