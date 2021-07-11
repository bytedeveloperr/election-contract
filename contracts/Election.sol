// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ElectionContract {

  string public name = "Voting Smart Contract";
  uint public electionCount = 0;
  uint public candidateCount = 0;
  uint public voteCount = 0;

  mapping(uint => Election) public elections;
  mapping(uint => Candidate) public candidates;
  mapping(uint => mapping(address => Vote)) public votes;

  struct Election {
    uint id;
    string title;
    string description;
    address owner;
    uint startDate;
    uint endDate;
  }
  struct Candidate {
    uint id;
    uint election;
    uint voteCount;
    string name;
    string description;
    address candidate;
  }
  struct Vote {
    uint election;
    uint candidiate;
    address voter;
  }

  event ElectionCreated(uint id, string title, string description, address owner, uint startDate, uint endDate);
  event CandidateCreated(uint id, uint election, uint voteCount, string name, string description, address candidate);

  function createElection(string memory _title, string memory _description, uint _startDate, uint _endDate) validateElection(_title) public {
    electionCount++;
    Election memory _election = Election(electionCount, _title, _description, msg.sender, _startDate, _endDate);
    elections[electionCount] = _election;

    emit ElectionCreated(electionCount, _title, _description, msg.sender, _startDate, _endDate);
  }

  function getElection(uint id) electionExists(id) public view returns(Election memory) {
    return elections[id];
  }

  function updateElection(uint id, string memory _title, string memory _description, uint _startDate, uint _endDate) electionExists(id) isElectionOwner(id) public {
    Election memory _election = elections[id];
    _election.title = _title;
    _election.description = _description;
    _election.startDate = _startDate;
    _election.endDate = _endDate;
    
    elections[id] = _election;
  }

  function removeElection(uint id) electionExists(id) isElectionOwner(id) public {
    electionCount--;
    delete elections[id];
  }


  function addCandidate(uint _election, string memory _name, string memory _description) electionExists(_election) isElectionOwner(_election) validateCandidate(_name) public {
    candidateCount++;
    Candidate memory _candidate = Candidate(electionCount, _election, 0, _name, _description, msg.sender);
    candidates[candidateCount] = _candidate;
    emit CandidateCreated(candidateCount, _election, 0, _name, _description, msg.sender);
  }

  function getCandidate(uint id) candidateExists(id) public view returns(Candidate memory) {
    return candidates[id];
  }

  function getCandidates(uint _election) electionExists(_election) public view returns(Candidate[] memory) {
    Candidate[] memory _candidates = new Candidate[](candidateCount);

    for (uint i = 0; i < candidateCount; i++) {
      if (candidates[i].election == _election) {
       _candidates[i] = candidates[i]; 
      }
    }
    return _candidates;
  }

  function updateCandidate(uint id, uint _election, string memory _name, string memory _description) electionExists(_election) isElectionOwner(_election) candidateExists(id) candidateBelongsToElection(id, _election)  public {
    Candidate memory _candidate = candidates[id];
    _candidate.name = _name;
    _candidate.description = _description;
    
    candidates[id] = _candidate;
  }

  function removeCandidate(uint id, uint _election) electionExists(_election) isElectionOwner(_election) candidateBelongsToElection(id, _election) public {
    candidateCount--;
    delete candidates[id];
  }

  function voteCandidate(uint _election, uint _candidate) electionExists(_election) ensureUniqueVote(_candidate) candidateBelongsToElection(_candidate, _election) public {
    voteCount++;
    candidates[_candidate].voteCount++;
    
    votes[_candidate][msg.sender] = Vote(_election, _candidate, msg.sender);
  }

  modifier validateElection(string memory _title) {
    require(bytes(_title).length > 0, "Election title cannot be empty");
    _;
  }

  modifier isElectionOwner(uint id) {
    require(msg.sender == elections[id].owner, "Caller must be the election owner");
    _;
  }

  modifier electionExists(uint id) {
      require(elections[id].owner != address(0), "Election does not exist");
      require(bytes(elections[id].title).length > 0, "Election does not exist");
    _;
  }

  modifier validateCandidate(string memory _name) {
    require(bytes(_name).length > 0, "Candidate name cannot be empty");
    _;
  }

  modifier candidateExists(uint id) {
      require(candidates[id].candidate != address(0), "Candidate does not exist");
      require(bytes(candidates[id].name).length > 0, "Candidate does not exist");
    _;
  }
  
  modifier ensureUniqueVote(uint _candidate) {
    require(votes[_candidate][msg.sender].election == 0, "Vote must be unique");
    _;
  }

  modifier candidateBelongsToElection(uint _candidate, uint _election) {
    require(candidates[_candidate].election == _election, "Candidate must belong to election");
    _;
  }
  
  modifier canAddCandidate(string memory _name) {
    // TODO: Can caller add candidate?
    _;
  }
}
