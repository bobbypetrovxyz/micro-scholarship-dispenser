// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract ScholarshipDispenser is OwnableUpgradeable {
    uint256 public usdStipendAmount; // in cents, e.g. 1000 for $10.00
    AggregatorV3Interface public priceFeed;
    bytes32 public merkleRoot;
    mapping(address => bool) public claimedStipends;

    event StipendClaimed(
        address indexed student,
        uint256 usdAmount,
        uint256 ethAmount
    );
    event DirectorFundedStipendPayouts(
        address indexed director,
        uint256 amount
    );
    event Withdrawn(address indexed director, uint256 amount);

    error InvalidDirectorAddress();
    error InvalidPriceFeedAddress();
    error InvalidMerkleRoot();
    error StipendAlreadyClaimed();
    error InvalidMerkleProof();
    error StipendAmountMustBeGreaterThanZero();
    error InvalidPriceFeedData();
    error InsufficientContractBalance();
    error ETHTransferFailed();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @custom:oz-upgrades-validate-as-initializer
    function initialize(
        address _director,
        uint256 _usdStipendAmount,
        address _priceFeed,
        bytes32 _merkleRoot
    ) public initializer {
        require(_director != address(0), InvalidDirectorAddress());
        require(_usdStipendAmount > 0, StipendAmountMustBeGreaterThanZero());
        require(_priceFeed != address(0), InvalidPriceFeedAddress());
        require(_merkleRoot != bytes32(0), InvalidMerkleRoot());

        __Ownable_init(_director);

        usdStipendAmount = _usdStipendAmount;
        priceFeed = AggregatorV3Interface(_priceFeed);
        merkleRoot = _merkleRoot;
    }

    /**
     * @notice This function allows students to claim their stipend if they are included in the Merkle tree
     * @param merkleProof The Merkle proof that verifies the student's eligibility
     */
    function claimStipend(bytes32[] calldata merkleProof) external {
        address student = msg.sender;
        require(!claimedStipends[student], StipendAlreadyClaimed());

        bytes32 leaf = keccak256(abi.encode(student, usdStipendAmount));
        require(
            MerkleProof.verify(
                merkleProof,
                merkleRoot,
                keccak256(abi.encodePacked(leaf))
            ),
            InvalidMerkleProof()
        );

        uint256 ethAmount = convertUsdToEth(usdStipendAmount);
        require(
            address(this).balance >= ethAmount,
            InsufficientContractBalance()
        );

        // set the stipend as claimed before transferring funds
        // to prevent re-entrancy attacks (Check-Effects-Interactions pattern)
        claimedStipends[student] = true;

        (bool success, ) = student.call{value: ethAmount}("");
        require(success, ETHTransferFailed());

        emit StipendClaimed(student, usdStipendAmount, ethAmount);
    }

    function convertUsdToEth(
        uint256 usdAmountInCents
    ) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, InvalidPriceFeedData());

        // USD amount is in cents, price is in USD with 8 decimals
        return (1 ether * (usdAmountInCents * 10 ** 6)) / uint256(price);
    }

    // director can send ETH to this contract to fund the stipend payouts
    // director is the owner of the contract
    receive() external payable onlyOwner {
        emit DirectorFundedStipendPayouts(msg.sender, msg.value);
    }

    // director can withdraw contract leftover balance
    function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        (bool success, ) = msg.sender.call{value: contractBalance}("");
        require(success, ETHTransferFailed());

        emit Withdrawn(msg.sender, contractBalance);
    }
}
