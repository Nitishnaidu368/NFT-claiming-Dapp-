// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./PNDC_ERC1155.sol";
import "./TokenERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

interface TokenFactory1155 {
    function collectionToOwner(address) external returns (address);
}

contract NFTclaiming is ERC2771Context, Ownable, ERC1155Holder {
    address public collection;

    enum category {
        NONE,
        STANDARD,
        VIP,
        VVIP
    }

    mapping(address => category) public ticketType;

    constructor(
        address address_collection,
        address address_PNDC,
        address address_factory,
        address address_Forwarder
    ) ERC2771Context(address_Forwarder) {
        require(
            address_collection == address_PNDC ||
                TokenFactory1155(address_factory).collectionToOwner(
                    address_collection
                ) !=
                address(0)
        );
        collection = address_collection;
    }

    function fundcontract(uint256 tokenID, uint256 ammount) public {
        require(ERC1155(collection).balanceOf(msg.sender, tokenID) >= ammount);
        ERC1155(collection).safeTransferFrom(
            msg.sender,
            address(this),
            tokenID,
            ammount,
            ""
        );
    }

    function whitelist(address[] memory addresses, uint256 claimtype)
        external
        onlyOwner
    {
        uint256 m_length = addresses.length;
        require(claimtype >= 0 && claimtype <= 3);
        require(m_length <= 100);
        for (uint256 i = 0; i < m_length; ++i) {
            if (claimtype == 1) {
                ticketType[addresses[i]] = category.STANDARD;
            } else if (claimtype == 2) {
                ticketType[addresses[i]] = category.VIP;
            } else if (claimtype == 3) {
                ticketType[addresses[i]] = category.VVIP;
            } else {
                ticketType[addresses[i]] = category.NONE;
            }
        }
    }

    function claim() external {
        require(ticketType[msg.sender] != category.NONE);
        if (ticketType[msg.sender] == category.STANDARD) {
            ERC1155(collection).safeTransferFrom(
                address(this),
                msg.sender,
                0,
                1,
                ""
            );
        } else if (ticketType[msg.sender] == category.VIP) {
            ERC1155(collection).safeTransferFrom(
                address(this),
                msg.sender,
                1,
                1,
                ""
            );
        } else if (ticketType[msg.sender] == category.VVIP) {
            ERC1155(collection).safeTransferFrom(
                address(this),
                msg.sender,
                2,
                1,
                ""
            );
        }
        ticketType[msg.sender] = category.NONE;
    }

    function _msgSender()
        internal
        view
        override(Context, ERC2771Context)
        returns (address sender)
    {
        sender = ERC2771Context._msgSender();
    }

    function _msgData()
        internal
        view
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }
}
