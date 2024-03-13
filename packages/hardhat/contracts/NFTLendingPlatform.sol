// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract NFTLendingPlatform is ERC721Holder {
    using EnumerableSet for EnumerableSet.UintSet;
    
    struct BorrowRequest {
        address borrower;
        uint256 nftId;
        uint256 duration;
        uint256 startTime;
        bool active;
    }
    
    struct Escrow {
        address borrower;
        uint256 nftId;
        uint256 duration;
        uint256 endTime;
        bool fulfilled;
    }
    
    struct NFTSwap {
        address swapper;
        uint256 nftId1;
        uint256 nftId2;
        uint256 duration;
        uint256 endTime;
        bool active;
    }
    
    struct FractionalOwnership {
        uint256 nftId;
        mapping(address => uint256) ownership;
        mapping(address => bool) hasVoted;
    }
    
    mapping(uint256 => BorrowRequest) public borrowRequests;
    EnumerableSet.UintSet private activeBorrowRequestIds;
    mapping(uint256 => Escrow) public escrows;
    mapping(uint256 => NFTSwap) public nftSwaps;
    EnumerableSet.UintSet private activeSwapIds;
    mapping(uint256 => FractionalOwnership) public fractionalOwnerships;
    
    // New proposal structure
    struct Proposal {
        uint256 proposalId;
        address proposer;
        uint256 nftId;
        string proposalDescription;
        uint256 forVotes;
        uint256 againstVotes;
        mapping(address => bool) voted;
        bool active;
    }
    
    mapping(uint256 => Proposal) public proposals;
    uint256 public totalProposals;
    
    // Function to create a new proposal
    function createProposal(uint256 _nftId, string memory _description) external {
        totalProposals++;
        
        Proposal storage newProposal = proposals[totalProposals];
        newProposal.proposalId = totalProposals;
        newProposal.proposer = msg.sender;
        newProposal.nftId = _nftId;
        newProposal.proposalDescription = _description;
        newProposal.active = true;
    }
    
    // Function for fractional NFT owners to vote on a proposal
    function voteOnProposal(uint256 _proposalId, bool _vote) external {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active == true, "Proposal is not active");
        require(fractionalOwnerships[proposal.nftId].ownership[msg.sender] > 0, "You don't own fractional ownership of this NFT");
        require(!proposal.voted[msg.sender], "You have already voted on this proposal");
        
        if (_vote) {
            proposal.forVotes++;
        } else {
            proposal.againstVotes++;
        }
        
        proposal.voted[msg.sender] = true;
    }
}