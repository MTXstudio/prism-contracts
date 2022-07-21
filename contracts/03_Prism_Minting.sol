// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

interface IPrismTokens{
    function mintBatch(uint256[] memory _ids, uint256[] memory _amounts, address _to, bytes memory _data) public; 
}


contract PrismMinting is VRFConsumerBaseV2 {

  /**
  @dev global
  */
  address public prismTokensContract;
   //projectId => bundles
  mapping (uint256 => Bundle[]) projectIdToBundles;
  //requestId => msg.sender
  mapping (uint256 => MintRequest) requestIdMintRequest;
  

  /**
  @dev vrf
  */
  VRFCoordinatorV2Interface COORDINATOR;
  // Your subscription ID.
  uint64 s_subscriptionId;
  // Mumbai settings.
  address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
  bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
  uint32 callbackGasLimit = 100000;
  
  // The default is 3.
  uint16 requestConfirmations = 3;
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords =  1;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;

  /**
  @dev structs
  */
  struct Bundle {
    uint256[] tokenIds;
  }

  struct MintRequest {
    address sender;
    uint256 projectId;
  }


  constructor(address _prismTokensContract, uint64 subscriptionId) PrismMinting(vrfCoordinator) {
    prismTokensContract = _prismTokensContract;
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;
  }

  // Assumes the subscription is funded sufficiently.
  function mintRandomBundle(uint64 projectId) external onlyOwner {
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );

    requestIdMintRequest[s_requestId] = MintRequest(msg.sender, projectId);
  }
  
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    uint32 randomIndex = (randomWords[0] % projectIdToBundles[requestIdMintRequest[s_requestId].projectId].length) + 1;
    
    //generate array of 1 for amounts
    uint32[] amountsArray = new uint32[](projectIdToBundles[requestIdMintRequest[s_requestId].projectId][randomIndex].tokenIds.length);
    for (uint32 i = 0; i < amountsArray.length; i++) {
      amountsArray[i] = 1;
    }
    //call mintBatch of tokens from the Prism tokens contract
    prismTokensContract.mintBatch(
      projectIdToBundles[requestIdMintRequest[s_requestId].projectId][randomIndex].tokenIds,
      amountsArray,
      msg.sender,
      0x0
    );
    //remove the request from the map
    delete requestIdMintRequest[s_requestId];
    //remove the bundle from the map
    delete projectIdToBundles[requestIdMintRequest[s_requestId].projectId][randomIndex];
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
}
