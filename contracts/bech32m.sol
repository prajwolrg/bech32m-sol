// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract bech32m {

    string constant ALPHABET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

    uint8[75] public ALPHABET_INDEX = [
        15, 255,  10,  17,  21,  20,  26,  30,   7,   5, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255,  29, 255,  24,  13,  25,   9,   8,  23, 255,  18,  22,
        31,  27,  19, 255,   1,   0,   3,  16,  11,  28,  12,  14,
            6,   4,   2
    ];

    function arrGetAlphabetIndex(bytes1 character) public view returns (uint8) {
        uint8 idx = uint8(character) - 48;
        return ALPHABET_INDEX[idx];
    }

    function getAlphabetIndex(bytes1 character) public pure returns (uint8) {
        for (uint8 i = 0; i < bytes(ALPHABET).length; i++) {
            if (bytes(ALPHABET)[i] == bytes1(character)[0]) {
                return i;
            }
        }
        revert("Character not found in alphabet");
    }


    function polymodStep(uint pre) public pure returns (uint) {
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

    function prefixChk(string memory prefix) public pure returns (uint256) {
        uint chk = 1;
        
        for (uint i = 0; i < bytes(prefix).length; ++i) {
            uint c = uint8(bytes(prefix)[i]);
            require(c >= 33 && c <= 126, "Invalid prefix");
            chk = polymodStep(chk) ^ (c >> 5);
        }
          chk = polymodStep(chk);

        for (uint i = 0; i < bytes(prefix).length; ++i) {
            uint v = uint8(bytes(prefix)[i]);
            chk = polymodStep(chk) ^ (v & 0x1f);
        }
        return chk;
    }

    function validateAleoAddr(string memory addr) public view returns ( bool ) {
        require(bytes(addr).length == 63, "Invalid Aleo address length");

        bytes1[] memory addrBytes = new bytes1[](58);

        uint chk = 393502710;

        for (uint i = 0; i < addrBytes.length; i++) {
            // uint v = getAlphabetIndex(bytes(addr)[i+5]);
            uint v = arrGetAlphabetIndex(bytes(addr)[i+5]);
            chk = polymodStep(chk) ^ v;
            if (i+6 >= addrBytes.length) continue;
        }
        uint ENCODING_CONST = 0x2bc830a3;
        require(chk == ENCODING_CONST, "Invalid checksum");

        return true;

    }


}