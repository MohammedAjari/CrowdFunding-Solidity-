// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.9 < 0.9.0;
contract lottery{
    address public Manager;
    // we will create an array to store the address of the participants
    address payable[] public participants;
    constructor(){
        // The user who deploy the contract will be manager
        Manager = msg.sender;
    }

    // the below function is the special type of function
    // there should be only on receive function in the contract and it should be external
    receive() external payable {
        // After transfering the ethers in contract the user will be consider as participants
        // the amount should be atleast as 2 ether 
        require(msg.value==2 ether);
        participants.push(payable(msg.sender));
    } 

    function getBalance() public view returns(uint){
        // This function will only be accessed by the manager only
        require(msg.sender== Manager);
        return address(this).balance;
    }

    function random() public view returns(uint){
        // This function is used to create a random number and 
        //no need to understand it or u can watch the video
        return uint(keccak256(abi.encodePacked(block.difficulty , block.timestamp , participants.length)));
    }
    
    function selectWinner() public {
        address payable winner;
        // The function can only be called by the manager
        require(msg.sender == Manager);
        // There should be atleast 3 participants before activating the lottery
        require(participants.length>=3);
        uint r = random();
        uint index = r % participants.length;
        winner = participants[index];
        // then we have to transfer the price money into winner's account
        winner.transfer(getBalance());
        // At last we clear the participants array
        participants = new address payable[](0);
    } 


}
