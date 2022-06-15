// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @dev DAO interface.
 */
interface IDAO {
    // QUESTION: Будет ли дешевле переделать на bool?
    enum ProposalStatus {
        SUCCESSFUL,
        UNSUCCESSFUL,
        ACTIVE
    }

    enum VoteType {
        AGREE,
        DISAGREE
    }

    struct Vote {
        uint256 agree;
        uint256 disagree;
    }

    struct Proposal {
        string description;
        uint256 endTimeOfVoting;
        address recipient;
        bytes callData;
        address author;
        ProposalStatus status;
        uint256 numberOfVotes;
        uint256 votesAgree;
        uint256 votesDisagree;
    }

    /** @notice Change voting rules.
     * @param minimumQuorum Minimum quantity of users to vote.
     * @param debatingPeriodDuration Debating period duration to vote.
     */
    function changeVotingRules(
        uint256 minimumQuorum,
        uint256 debatingPeriodDuration
    ) external;

    /** @notice Deposits `amount` of tokens to contract.
     * @param amount The amount of tokens to deposit.
     */
    function deposit(uint256 amount) external;

    /** @notice Withdraws `amount` of tokens back to user.
     * @param amount The amount of tokens to withdraw.
     */
    function withdraw(uint256 amount) external;

    /** @notice Create new proposal.
     * @param description Proposal description.
     * @param recipient The address to use calldata on.
     * @param callData Calldata to execute if proposal will pass.
     * @return id New proposal ID.
     */
    function createProposal(
        string memory description,
        address recipient,
        bytes memory callData
    ) external returns (uint256 id);

    /** @notice Find information of proposal.
     * @param id Proposal identifier.
     * @return proposal Proposal data.
     */
    function informationOf(uint8 id)
        external
        view
        returns (Proposal memory proposal);

    /** @notice Find user balance.
     * @param account User address.
     * @return balance User balance.
     */
    function balanceOf(address account) external view returns (uint256 balance);

    /** @notice Casting a vote for a proposal.
     * @param id Proposal ID.
     * @param voteType Vote type.
     */
    function voteOf(uint256 id, VoteType voteType) external;

    /** @notice Finishing voting for proposal.
     * @param id Proposal ID.
     */
    function finish(uint256 id) external;

    event NewProposal(
        uint256 indexed index,
        address indexed recipient,
        address indexed author
    );
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Voted(
        uint256 indexed id,
        address indexed voter,
        uint256 amount,
        VoteType voteType
    );
    event VotingFinished(
        uint256 indexed id,
        ProposalStatus proposalStatus,
        bool callDataStatus
    );
}
