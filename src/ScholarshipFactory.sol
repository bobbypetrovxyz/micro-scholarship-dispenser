// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ScholarshipDispenser} from "./ScholarshipDispenser.sol";

contract ScholarshipFactory is Ownable {
    using Clones for address;

    address public immutable dispenserImplementation;
    address[] public dispensers;
    address public director;

    event DispenserCreated(
        address indexed dispenserAddress,
        uint256 usdStipendAmount
    );

    error InvalidImplementationAddress();
    error InvalidAdminAddress();
    error InvalidPriceFeedAddress();
    error InvalidMerkleRoot();
    error StipendAmountMustBeGreaterThanZero();
    error InvalidDirectorAddress();
    error OnlyDirectorCanCreateDispenser();

    constructor(
        address _dispenserImplementation,
        address _admin,
        address _director
    ) Ownable(_admin) {
        require(
            _dispenserImplementation != address(0),
            InvalidImplementationAddress()
        );
        require(_admin != address(0), InvalidAdminAddress());
        require(_director != address(0), InvalidDirectorAddress());

        dispenserImplementation = _dispenserImplementation;
        director = _director;
    }

    /**
     * @notice Director creates a new ScholarshipDispenser clone with the specified parameters
     * @param _merkleRoot The Merkle root for stipend eligibility verification
     * @param _usdStipendAmount The stipend amount in USD cents (e.g., 1000 for $10.00)
     * @param _priceFeed The address of the Chainlink price feed contract for USD to ETH conversion
     * @return The address of the newly created Payroll clone
     *
     * @dev The Merkle root is used to verify if a student is eligible for the stipend
     * @dev The Merkle root must be a valid bytes32 value
     * @dev The stipend amount must be greater than zero
     * @dev The price feed is used to convert the stipend amount from USD to ETH
     * @dev Emits a DispenserCreated event upon successful creation of the dispenser
     */
    function createDispenser(
        bytes32 _merkleRoot,
        uint256 _usdStipendAmount,
        address _priceFeed
    ) external returns (address) {
        require(msg.sender == director, OnlyDirectorCanCreateDispenser());
        require(_usdStipendAmount > 0, StipendAmountMustBeGreaterThanZero());
        require(_priceFeed != address(0), InvalidPriceFeedAddress());
        require(_merkleRoot != bytes32(0), InvalidMerkleRoot());

        address dispenserClone = dispenserImplementation.clone();
        ScholarshipDispenser(payable(dispenserClone)).initialize(
            director,
            _usdStipendAmount,
            _priceFeed,
            _merkleRoot
        );

        dispensers.push(dispenserClone);

        emit DispenserCreated(dispenserClone, _usdStipendAmount);

        return dispenserClone;
    }

    /**
     * @notice Only the admin can update the director address
     * @param newDirector The new director address to be set
     */
    function updateDirector(address newDirector) external onlyOwner {
        require(newDirector != address(0), InvalidDirectorAddress());
        director = newDirector;
    }
}
