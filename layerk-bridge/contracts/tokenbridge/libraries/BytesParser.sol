// SPDX-License-Identifier: Apache-2.0

/*
 * Copyright 2020, Offchain Labs, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.8.0;

import "./BytesLib.sol";

library BytesParser {
    using BytesLib for bytes;

    function toUint8(bytes memory input) internal pure returns (bool success, uint8 res) {
        if (input.length != 32) {
            return (false, 0);
        }
        try abi.decode(input, (uint256)) returns (uint256 inputNum) {
            if (inputNum > type(uint8).max) {
                return (false, 0);
            }
            res = uint8(inputNum);
            success = true;
        } catch {
            return (false, 0);
        }
    }

    function toString(bytes memory input) internal pure returns (bool success, string memory res) {
        if (input.length == 0) {
            success = false;
            // return default value of string
        } else if (input.length == 32) {
            // validate that the bytes32 is null terminated and contains no
            // null bytes in the middle of the string
            if (input[31] != bytes1(0x00)) return (false, res);

            uint256 len = 32;
            while (len > 0 && input[len - 1] == bytes1(0x00)) {
                len--;
            }
            for (uint256 i = 0; i < len; i++) {
                if (input[i] == bytes1(0x00)) return (false, res);
            }
            success = true;
            // here we assume its a null terminated Bytes32 string
            // https://github.com/ethereum/solidity/blob/5852972ec148bc041909400affc778dee66d384d/test/libsolidity/semanticTests/externalContracts/_stringutils/stringutils.sol#L89
            // https://github.com/Arachnid/solidity-stringutils

            bytes memory inputTruncated = new bytes(len);
            for (uint8 i = 0; i < len; i++) {
                inputTruncated[i] = input[i];
            }
            // convert to string without trailing null bytes
            res = string(inputTruncated);
        } else {
            try abi.decode(input, (string)) returns (string memory decoded) {
                success = true;
                res = decoded;
            } catch {
                success = false;
            }
        }
    }
}
