// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import { IERC20 } from "./interfaces/IERC20.sol";
import { IERC721 } from "./interfaces/IERC721.sol";







/// @title Unicorn Auction Implmentartion Contract 
/// @notice a proxy of this contract would be deployed anytime an auction is placed.
/// @author team unicorn
contract AuctionImplementation {

    /**
     * ===================================================
     * ----------------- EVENTS --------------------------
     * ===================================================
     */

    event Start(IERC721 indexed nft, uint id, uint startingBid);
    event End(address indexed highestBidder, uint highestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);


    /**
     * ===================================================
     * ----------------- STATE VARIBLE -------------------
     * ===================================================
     */

    IERC20 public protocol_token; // this is the address of the protocol's token all finance stuff would be done using this token
    address public seller;
    bool public started;
    bool public ended;
    IERC721 public nft;
    uint public nftId;
    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;
    bool initailized;

    /**
     * ===================================================
     * ----------------- ERROR ---------------------------
     * ===================================================
     */

    error AlreadyStarted();
    error NotSeller();
    error NotStarted();
    error HasEnded();
    error YouAreTheHighestBidder();
    error BidLowerThanHighestBid();
    error WithdrawError();
    error CannotWithdraw();
    error BidHasNotStarted();
    error BidHasEnded();
    error NotInitialized();
    error AlreadyIntialized();



    /**
     * ===================================================
     * ----------------- MODIFIERS -----------------------
     * ===================================================
     */

    modifier isInitialized() {
        if(!initailized) {
            revert NotInitialized();
        }
        _;
    }

    /**
     * ===================================================
     * ----------------- INITIALIZER --------------------
     * ===================================================
     */

    function initialize(address _seller, IERC20 _protocol_token) public {
        if(initailized) {
            revert AlreadyIntialized();
        }
        seller = _seller;
        protocol_token = _protocol_token;
        initailized = true;
    }






    /// @dev this function start the biding process (NOTE: this bid would run unitl the end function is called)
    /// @param _nft: this is the nft contract address
    /// @param _nftId: this is the nftId
    /// @param startingBid: this is how much blockchain native token the seller is willing to start the bid at
    /// @notice this user must have approved the contract to spend the nft the want to auction before the auction with begin
    function start(IERC721 _nft, uint256 _nftId, uint256 startingBid) 
        external 
        isInitialized
    {
        if(started) {
            revert AlreadyStarted();
        }

        if(msg.sender != seller) {
            revert NotSeller();
        }
        
        highestBid = startingBid;

        nft = _nft;
        nftId = _nftId;


        // @dev transfering the ownership of the nft to the contract (so the bid can holder), fisrt from the frontend, the user must give the contract the authorization to spend NFTs from he/her wallet (NOTE: if this is not successful, it would be reverted)
        nft.transferFrom(msg.sender, address(this), nftId);

        started = true;

        emit Start(_nft, _nftId, startingBid);
    }


    /// @notice uisng this function, other users can make their bid for this NFT
    /// @dev this function shuold update the highest bidder if the bid is higher that the highest bidder 
    /// @param _amount: this is the amount the user wishes to bid for the product the NOTE: this bid must be higher that the current highest bid
    function bid(uint256 _amount) external payable {
        if(!started) {
            revert NotStarted();
        }
        if(ended) {
            revert BidHasEnded();
        }

        if(msg.sender == highestBidder) {
            revert YouAreTheHighestBidder();
        }

        uint256 currentUserBid = bids[msg.sender] + _amount;

        if(currentUserBid < highestBid) {
            revert BidLowerThanHighestBid();
        }

        bool sent = IERC20(protocol_token).transferFrom(msg.sender, address(this), _amount);
        bids[msg.sender] += _amount;

        highestBid = bids[msg.sender];
        highestBidder = msg.sender;

        emit Bid(highestBidder, highestBid);
    }


    /// @dev a user can only withdraw is the user is not the highest bidder
    function withdraw() external payable {
        if(msg.sender == highestBidder) {
            revert CannotWithdraw();
        }

        bids[msg.sender] = 0;
        bool sent = IERC20(protocol_token).transfer(msg.sender, bids[msg.sender]);

        if(!sent) {
            revert WithdrawError();
        }

        emit Withdraw(msg.sender, bids[msg.sender]);
    }


    /// @dev This function would transfer the nft to the higher bider if the auction is successful and also trasnsfer the funds to the seller of just transfer the nft to the seller if the bid was not successful
    function end() external {
        if(!started) {
            revert BidHasNotStarted();
        }
        if(ended) {
            revert BidHasEnded();
        }


        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            bool sent = IERC20(protocol_token).transfer(seller, highestBid);
            require(sent, "Could not pay seller!");
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }

        ended = true;
        emit End(highestBidder, highestBid);
    }


}







