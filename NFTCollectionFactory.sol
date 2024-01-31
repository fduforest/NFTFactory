// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./NFTCollection.sol";

///@title NFT Collection Factory contract.
///@author Duforest François
///@notice Give the ability to deploy a contract to manage ERC-721 tokens for a collection.
///@dev If the contract is already deployed for a _collectionName, it will revert.
contract NFTCollectionFactory {
    /// @notice event for collection creation
    /// @param sender the owner of the collection contract
    /// @param _collectionName Collection name
    /// @param _collectionSymbol Collection Symbol
    /// @param _timestamp Timestamp of the creation
    event NFTCollectionCreated(
        address sender,
        string _collectionName,
        string _collectionSymbol,
        address _collectionAddress,
        uint256 _timestamp
    );

    /// @notice Deploy the ERC-721 Collection contract of the creator caller
    /// @param _collectionName Collection name
    /// @param _collectionSymbol Collection Symbol
    /// @return collectionAddress Address of the collection
    function createNFTCollection(
        string memory _collectionName,
        string memory _collectionSymbol
    ) external returns (address collectionAddress) {
        // Import the bytecode of the contract to deploy
        bytes memory collectionBytecode = type(NFTCollection).creationCode;
        // Make a random salt based on the collection name & symbl
        bytes32 salt = keccak256(abi.encodePacked(_collectionName));
        assembly {
            collectionAddress := create2(
                0,
                add(collectionBytecode, 0x20),
                mload(collectionBytecode),
                salt
            )
            if iszero(extcodesize(collectionAddress)) {
                // revert if something gone wrong (collectionAddress doesn't contain an address)
                revert(0, "collectionAddress error")
            }
        }
        NFTCollection(collectionAddress).initialize(
            _collectionName,
            _collectionSymbol
        ); // Initialize the contrat NFTCollection with settings
        emit NFTCollectionCreated(
            msg.sender,
            _collectionName,
            _collectionSymbol,
            collectionAddress,
            block.timestamp
        );
    }
}
