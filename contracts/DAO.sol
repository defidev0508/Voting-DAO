//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// QUESTION: можно ли импортировать со своей репы гитхаба?
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IDAO.sol";

contract DAO is IDAO {
    using SafeERC20 for IERC20;
    using Strings for *;

    uint256 public minVotingPeriod = 3 days;
    uint256 public minMinimumQuorum = 10;

    address private _chairPerson;
    address private _voteToken;
    uint256 private _minimumQuorum;
    uint256 private _debatingPeriodDuration;
    uint256 private _currentProposalId;
    mapping(address => uint256) public _balances;
    mapping(uint256 => Proposal) public _proposals;
    mapping(uint256 => mapping(address => Vote)) private _votes;
    mapping(address => uint256[]) private _userVotes;

    constructor(
        address chairPerson_,
        address voteToken_,
        uint256 minimumQuorum_,
        uint256 debatingPeriodDuration_
    ) {
        // QUESTION: Есть ли смысл таких проверок?
        require(
            chairPerson_ != address(0),
            "DAO: Chairperson from the zero address."
        );
        require(voteToken_ != address(0), "DAO: Token from the zero address.");
        _chairPerson = chairPerson_;
        _voteToken = voteToken_;
        _changeMinimumQuorum(minimumQuorum_);
        _changePeriodDuration(debatingPeriodDuration_);
    }

    function informationOf(uint8 id)
        external
        view
        override
        returns (Proposal memory proposal)
    {
        return _proposals[id];
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256 balance)
    {
        return _balances[account];
    }

    function createProposal(
        string memory description,
        address recipient,
        bytes memory callData
    ) public override returns (uint256) {
        require(recipient != address(0), "DAO: mint to the zero address.");
        require(callData.length != 0, "DAO: call data should not be empty.");

        uint256 id = _currentProposalId++;
        _proposals[id] = Proposal({
            description: description,
            endTimeOfVoting: block.timestamp + minVotingPeriod,
            recipient: recipient,
            callData: callData,
            author: msg.sender,
            status: ProposalStatus.ACTIVE,
            numberOfVotes: 0,
            votesAgree: 0,
            votesDisagree: 0
        });

        emit NewProposal(id, recipient, msg.sender);

        return id;
    }

    function voteOf(uint256 id, VoteType voteType) public override {
        require(_currentProposalId <= id, "DAO: Incorrect proposal id."); // TODO: Что будет без этой проверки?

        Proposal storage proposal = _proposals[id];

        require(
            proposal.endTimeOfVoting >= block.timestamp,
            "DAO: Voting ended."
        );

        if (
            _votes[id][msg.sender].agree == 0 &&
            _votes[id][msg.sender].disagree == 0
        ) {
            _proposals[id].numberOfVotes += 1;
            _userVotes[msg.sender].push(id);
        }

        if (voteType == VoteType.AGREE) {
            _votes[id][msg.sender].agree += _balances[msg.sender];
            _proposals[id].votesAgree += _balances[msg.sender];
        } else {
            _votes[id][msg.sender].disagree += _balances[msg.sender];
            _proposals[id].votesDisagree += _balances[msg.sender];
        }

        emit Voted(id, msg.sender, _balances[msg.sender], voteType);
    }

    function finish(uint256 id) external override {
        require(
            _proposals[id].status == ProposalStatus.ACTIVE,
            "DAO: Proposal is already completed."
        );
        require(
            _proposals[id].endTimeOfVoting <= block.timestamp,
            "DAO: Voting is active."
        ); // QUESTION: Либо поменять логику на дату начала + текущий minVotingPeriod?
        require(
            (IERC20(_voteToken).totalSupply() /
                (_proposals[id].votesAgree + _proposals[id].votesDisagree)) *
                100 >=
                _minimumQuorum,
            "DAO: Voting is active."
        );
        if (_proposals[id].votesAgree > _proposals[id].votesDisagree) {
            _proposals[id].status = ProposalStatus.SUCCESSFUL;
            (bool callDataStatus, ) = _proposals[id].recipient.call(
                _proposals[id].callData
            );
            emit VotingFinished(id, _proposals[id].status, callDataStatus);
        } else {
            _proposals[id].status = ProposalStatus.UNSUCCESSFUL;
            emit VotingFinished(id, _proposals[id].status, false);
        }
    }

    function changeVotingRules(
        uint256 minimumQuorum,
        uint256 debatingPeriodDuration
    ) external override onlyChairPerson {
        _changeMinimumQuorum(minimumQuorum);
        _changePeriodDuration(debatingPeriodDuration);
    }

    function _changeMinimumQuorum(uint256 minimumQuorum) internal {
        require(
            minimumQuorum >= minMinimumQuorum && minimumQuorum <= 100,
            string(
                abi.encodePacked(
                    "DAO: MinimumQuorum should be more: ",
                    minMinimumQuorum.toString()
                )
            )
        );
        _minimumQuorum = minimumQuorum;
    }

    function _changePeriodDuration(uint256 debatingPeriodDuration) internal {
        require(
            debatingPeriodDuration >= minVotingPeriod,
            string(
                abi.encodePacked(
                    "DAO: Period duration should be more: ",
                    minVotingPeriod.toString()
                )
            )
        );
        _debatingPeriodDuration = debatingPeriodDuration;
    }

    function deposit(uint256 amount) external override {
        IERC20(_voteToken).safeTransferFrom(msg.sender, address(this), amount);
        _balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external override {
        require(
            _balances[msg.sender] >= amount,
            "DAO: transfer amount exceeds vote balance."
        );

        for (uint256 i = 0; i < _userVotes[msg.sender].length; i++) {
            uint256 proposalId = _userVotes[msg.sender][i];
            if (_proposals[proposalId].status == ProposalStatus.ACTIVE) {
                delete _userVotes[msg.sender][i];
            }
            i--;
        }

        require(
            _userVotes[msg.sender].length == 0,
            "DAO: There are active voting."
        );

        IERC20(_voteToken).safeTransferFrom(address(this), msg.sender, amount);
        unchecked {
            _balances[msg.sender] -= amount;
        }
        emit Withdraw(msg.sender, amount);
    }

    modifier onlyChairPerson() {
        require(
            msg.sender == _chairPerson,
            "DAO: caller is not the chairperson"
        );
        _;
    }
}
