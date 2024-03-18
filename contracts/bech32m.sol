// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @dev The verification of base32m encoding is based on the work at: https://github.com/bitcoinjs/bech32/blob/master/src/index.ts
/// The code has been written to minimize gas on the EVM.

contract bech32m {

    /// @dev ALPHABET_INDEX is based on the ALPHABET_MAP: Ref: https://github.com/bitcoinjs/bech32/blob/master/src/index.ts#L2-L8
    /// Since lookup on the mapping is expensive, this method is used to save gas cost
    ///
    ///   string constant ALPHABET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
    ///
    ///   const ALPHABET_MAP: { [key: string]: number } = {};
    ///   for (let z = 0; z < ALPHABET.length; z++) {
    ///     const x = ALPHABET.charAt(z);
    ///     ALPHABET_MAP[x] = z;
    ///   }
    ///
    ///   const ALPHABET_INDEX = []
    ///   for (let i=48; i<=122; i++) {
    ///     let char = String.fromCharCode(i);
    ///     let z = ALPHABET_MAP[char];
    ///     if (z === undefined) {
    ///       ALPHABET_INDEX.push(255)
    ///     } else {
    ///       ALPHABET_INDEX.push(z)
    ///     }
    ///   }
    uint8[75] public ALPHABET_INDEX = [
        15, 255,  10,  17,  21,  20,  26,  30,   7,   5, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255,  29, 255,  24,  13,  25,   9,   8,  23, 255,  18,  22,
        31,  27,  19, 255,   1,   0,   3,  16,  11,  28,  12,  14,
            6,   4,   2
    ];

    /// @dev The original function used the neg (-) operator. Ref: https://github.com/bitcoinjs/bech32/blob/master/src/index.ts#L10-L20
    /// Since the neg operator is not available for uint type, the logic is modified as follow
    function polymodStep(uint pre) internal pure returns (uint) {
        uint b = pre >> 25;
        return (
            ((pre & 0x1ffffff) << 5) ^
            (((b >> 0) & 1) == 0 ? 0 : 0x3b6a57b2) ^
            (((b >> 1) & 1) == 0 ? 0 : 0x26508e6d) ^
            (((b >> 2) & 1) == 0 ? 0 : 0x1ea119fa) ^
            (((b >> 3) & 1) == 0 ? 0 : 0x3d4233dd) ^
            (((b >> 4) & 1) == 0 ? 0 : 0x2a1462b3)
        );
    }

    function validateAleoAddr(string memory addr) external view returns ( bool ) {
        require(bytes(addr).length == 63, "Invalid Aleo address length");

        // This value is the output of prefixChk("aleo"). Ref: https://github.com/bitcoinjs/bech32/blob/master/src/index.ts#L22
        uint chk = 393502710;

        // 58 = 63 - len(aleo1)
        // the validation is necessary only starting from the 5th byte of address since the first 5 bytes is encoded in `chk`
        for (uint i = 0; i < 58; i++) {
            uint v = ALPHABET_INDEX[uint8(bytes(addr)[i+5]) - 48]; // 48 is the ASCII of 0 (zero)
            chk = polymodStep(chk) ^ v;
        }
        
        // Aleo uses bech32m encoding which has the given encoding constant
        // Ref: https://github.com/bitcoinjs/bech32/blob/master/src/index.ts#L100
        uint ENCODING_CONST = 0x2bc830a3;

        require(chk == ENCODING_CONST, "Invalid checksum");

        return true;

    }

}