// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.25;

import { OwnableExecutor } from "../OwnableExecutor/OwnableExecutor.sol";

/**
 * @title OwnableSignatureExecutor
 * @dev Module that allows users to designate an owner that can execute transactions on their behalf using msg.sender, EIP191, EIP712
 * and pays for gas. Signature based transactions have their own internal shared nonce counter
 * @author Leo Vigna
 */
contract OwnableSignatureExecutor is OwnableExecutor {

    /*//////////////////////////////////////////////////////////////////////////
                                     MODULE LOGIC
    //////////////////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////////////////
                                     METADATA
    //////////////////////////////////////////////////////////////////////////*/
    /**
     * Returns the name of the module
     *
     * @return name of the module
     */
    function name() external override pure virtual returns (string memory) {
        return "OwnableSignatureExecutor";
    }
}
