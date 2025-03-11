// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.25;

import { IERC7579Account } from "modulekit/accounts/common/interfaces/IERC7579Account.sol";
import { ECDSA } from "solady/utils/ECDSA.sol";
import { ModeLib } from "modulekit/accounts/common/lib/ModeLib.sol";
import { SentinelListLib } from "sentinellist/SentinelList.sol";
import { OwnableExecutor } from "../OwnableExecutor/OwnableExecutor.sol";

/**
 * @title OwnableSignatureExecutor
 * @dev Module that allows users to designate an owner that can execute transactions on their behalf using msg.sender, EIP191, EIP712
 * and pays for gas. Signature based transactions have their own internal shared nonce counter
 * @author Leo Vigna
 */
contract OwnableSignatureExecutor is OwnableExecutor {
    using SentinelListLib for SentinelListLib.SentinelList;

    error InvalidChainId(uint256 chainId, uint256 expected);

    /*//////////////////////////////////////////////////////////////////////////
                                     MODULE LOGIC
    //////////////////////////////////////////////////////////////////////////*/

    //TODO: Add nonce logic

    /**
     * Executes a transaction on the owned account
     *
     * @param ownedAccount address of the account to execute the transaction on
     * @param callData encoded data containing the transaction to execute
     * @param signature encoded signature of ownedAccount, msg.value, callData
     */
    function executeOnOwnedAccount(
        address ownedAccount,
        uint256 chainId,
        bytes calldata callData,
        bytes calldata signature
    )
        external
        payable
    {
        if (chainId != block.chainid) {
            revert InvalidChainId(chainId, block.chainid);
        }

        bytes32 execHash = ECDSA.toEthSignedMessageHash(abi.encode(ownedAccount, chainId, msg.value, callData));
        address owner = ECDSA.recoverCalldata(execHash, signature);

        // check if the signer is an owner
        if (!accountOwners[ownedAccount].contains(owner)) {
            revert UnauthorizedAccess();
        }

        // execute the transaction on the owned account
        IERC7579Account(ownedAccount).executeFromExecutor{ value: msg.value }(
            ModeLib.encodeSimpleSingle(), callData
        );
    }

    /**
     * Executes a batch of transactions on the owned account
     *
     * @param ownedAccount address of the account to execute the transaction on
     * @param callData encoded data containing the transactions to execute
     * @param signature encoded signature of ownedAccount, msg.value, callData
     */
    function executeBatchOnOwnedAccount(
        address ownedAccount,
        uint256 chainId,
        bytes calldata callData,
        bytes calldata signature
    )
        external
        payable
    {
        if (chainId != block.chainid) {
            revert InvalidChainId(chainId, block.chainid);
        }

        bytes32 execHash = ECDSA.toEthSignedMessageHash(abi.encode(ownedAccount, chainId, msg.value, callData));
        address owner = ECDSA.recoverCalldata(execHash, signature);

        // check if the signer is an owner
        if (!accountOwners[ownedAccount].contains(owner)) {
            revert UnauthorizedAccess();
        }

        // execute the batch of transaction on the owned account
        IERC7579Account(ownedAccount).executeFromExecutor{ value: msg.value }(
            ModeLib.encodeSimpleBatch(), callData
        );
    }

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
