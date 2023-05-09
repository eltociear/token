//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./utils/ERC20.sol";
import "./interfaces/IRewardEscrow.sol";
import "./interfaces/IKwenta.sol";

contract EscrowIssuer is ERC20 {
    /// @notice kwenta token contract
    IKwenta private immutable kwenta;

    /// @notice rewards escrow contract
    IRewardEscrow public immutable rewardEscrow;

    /// @notice treasury address
    address public treasury;

    /// @notice access control modifier for EscrowIssuer
    modifier onlyTreasury() {
        require(
            msg.sender == address(treasury),
            "Only the Treasury can perform this action"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _kwenta,
        address _rewardEscrowAddr,
        address _treasury
    ) ERC20(_name, _symbol) {
        kwenta = IKwenta(_kwenta);
        rewardEscrow = IRewardEscrow(_rewardEscrowAddr);
        treasury = _treasury;
    }

    /**
     *   Receive Kwenta from user, then mint
     *   redeemable escrowed Kwenta and give
     *   to user.
     */
    function issueRedeemable4YR(uint amount) public payable onlyTreasury {
        require(
            kwenta.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        _mint(msg.sender, amount);
    }

    /**
     *   call the escrow contract to send the KWENTA
     *   in here, to go there and be locked for a year
     */
    function redeemEscrow4YR(uint amount) public payable {
        _burn(msg.sender, amount);

        // Transfers kwenta from here to RewardEscrow.sol
        kwenta.approve(address(rewardEscrow), amount);
        rewardEscrow.createEscrowEntry(msg.sender, amount, 208 weeks);
    }
}
