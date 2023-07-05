// SPDX-License-Identifier:MIT
pragma solidity >= 0.5.9 < 0.9.0;

contract crowdFunding{
    // mapping will store data in array form 
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContributionAmount;
    uint public deadline;
    uint public noOfContributors;
    uint public target;
    uint public raisedAmount;

    constructor(uint _target ,uint _deadline){
        target = _target;
        deadline = _deadline + block.timestamp;
        minimumContributionAmount = 2 ether;
        manager = msg.sender;
    }

    function contribute() public payable{
        require(block.timestamp < deadline, "Deadline has gone :)");
        require(msg.value>=minimumContributionAmount , "Minimum amount is 2 Ether" );
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function getraisedAmount() public view returns(uint){
        require(msg.sender == manager , "Can only be access by manager");
        return raisedAmount;
    }

    function refund() public {
        require(msg.sender != manager);
        // If the target doesn't match at deadline than only user can withdraw fund
        require(block.timestamp > deadline && raisedAmount < target , "You are not eligible to withdraw your fund!");
        // Checking that if the user has contributed or not if he has than only he can withdraw amount
        require(contributors[msg.sender]>0);
        address payable user = payable(msg.sender);
        // The below line will transfer the amount contributed by the contributor
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    struct Request{
        string description;
        address payable recepient;
        uint amount;
        bool completed;
        uint noOfVoters;
        mapping(address => bool ) voters;
    }
    // we created a mapping to keep track of requests
    mapping(uint => Request) public requests;

    // numRequests is used as counter , in mapping it is not possible to increment
    uint public numRequests;

    // it is a modifier which specifies that only manager can do some actions
    modifier onlyManager(){
        require(msg.sender == manager , "You are not allowed for this action");
        _;
    }

    function createRequest(string memory _des , address payable _receipient , uint _amount) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _des;
        newRequest.recepient = _receipient;
        newRequest.amount = _amount;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;  
    }
    function Voting(uint _requestNumber) public{
        require(contributors[msg.sender]>0 , "You are not eligible to do voting ");
        Request storage thisRequest = requests[_requestNumber];
        require(thisRequest.voters[msg.sender]==false , "Voting has been done");
        thisRequest.noOfVoters++;
        thisRequest.voters[msg.sender] = true;
    }
    function makePayment(uint _requestNumber) public onlyManager{
        require(raisedAmount >= target , "Fund is not enough");
        Request storage newRequest = requests[_requestNumber];
        require(newRequest.completed == false , "Amount has already been transfered");
        require(newRequest.noOfVoters > noOfContributors / 2 , "Majority doesn't support");
        newRequest.recepient.transfer(newRequest.amount);
        newRequest.completed = true;
    } 
}
