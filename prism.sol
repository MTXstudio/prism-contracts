// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract Cyberfrens is ERC1155Supply, Ownable {
  
 using Strings for uint256;

  /**
  @dev global
 */
  uint256 public nextTokenId = 1;
  uint256 public nextCollectionId = 1;
  bytes32 public merkleRoot;
  
  /**
  @dev mappings
 */
  
  mapping (uint256 => uint256) public tokenIdToMaxSupply;
  mapping(uint256 => Collection) public collections;
  mapping(uint256 => uint256) public tokenIdToCollectionId;
  mapping(uint256 => uint256[]) public collectionIdToTokenIds;
  mapping(address => bool) public whitelistClaimed;
  mapping (uint256 => uint256[]) public projectToCollection;

  

  /**
  @dev constructor
 */

  constructor() ERC1155("https://game.example/api/item.json"){}


    /// Structs ///
  
  struct Collection {
    string name;
    uint256 tokenPriceInWei; 
    uint256 invocations;
    uint256 maxInvocations; 
    bool paused;
    bool locked;
  }


  /**
  @dev modifiers
 */

  modifier onlyOpenCollection(uint256 _collectionId) {
    require(!collections[_collectionId].locked, "Only unlocked collections");
    require(collections[_collectionId].invocations + 1 <= collections[_collectionId].maxInvocations, "Must not exceed max invocations");
    require(!collections[_collectionId].paused || msg.sender == owner(), "Purchases must not be paused");
    require(!collections[_collectionId].locked, "Only unlocked collections");
    _;
  }

  modifier onlyTokenPrice(uint256 _collectionId, uint256 _value) {
      require(_value >= collections[_collectionId].tokenPriceInWei,
      "Must send at least current price"
    );
    _;
  }

  modifier onlyAllowedToken(uint256 _tokenId) {
      require(exists(_tokenId), "Token must exist");
      require(tokenIdToMaxSupply[_tokenId] <= totalSupply(_tokenId),"Must not have reached max Supply"); 
    _;
  }


  /**
  @dev setup and mint Functions
 */

  function addTokenToCollection(uint256 _amountOfNewTokenIDs ,uint256 _collectionId, uint256[] memory _maxSupply) 
    public 
    onlyOwner 
    returns(uint256[] memory _tokenIds)
  {
    uint256[] memory newTokenIds;
    for (uint256 i= 0; i < _amountOfNewTokenIDs; i++) {
      uint256 maxSup = _maxSupply[i];
      tokenIdToCollectionId[nextTokenId] = _collectionId;
      collectionIdToTokenIds[_collectionId].push(nextTokenId);
      tokenIdToMaxSupply[nextTokenId] = maxSup;
      newTokenIds[i] = nextTokenId;
      nextTokenId++;
    }
    return newTokenIds;
  }


  function mintTo(address _to, uint256 _tokenId, uint256 _amount, uint256 _collectionId) 
  external
  payable  
  {
    if (msg.sender != owner()){
      _splitFunds(_collectionId);
    }
    _mintTo(_to, _tokenId ,_collectionId,_amount);
  }


 function _mintTo(address _to,  uint256 _tokenId, uint256 _collectionId,  uint256 _amount) 
  internal
  onlyOpenCollection(_collectionId)
  onlyAllowedToken(_tokenId)
  {
    collections[_collectionId].invocations++;
    _mint(_to, _tokenId, _amount,"");
    emit Mint(_to,_tokenId,_collectionId,collections[_collectionId].invocations,collections[_collectionId].tokenPriceInWei);
  }


  function mintBatch(
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) 
    public 
    onlyOwner 
    {
      for (uint256 i=0;i < _ids.length; i++){
        require(exists(_ids[i]), "Token must exist");
      }
      _mintBatch(owner(),_ids, _amounts, _data);
    }


  /**
  @dev helpers 
 */

  function _splitFunds(uint256 _collectionId) 
    internal
    onlyTokenPrice(_collectionId, msg.value)
  {
    if (msg.value > 0) {
      uint256 tokenPriceInWei = collections[_collectionId].tokenPriceInWei;
      uint256 refund = msg.value - tokenPriceInWei;
      if (refund > 0) {
        payable(msg.sender).transfer(refund);
      }
      payable(owner()).transfer(tokenPriceInWei);
    }
  }

  function addBaseURI(string memory _newBaseURI)
    public
    onlyOwner
  {
    _setURI(_newBaseURI);
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    returns (string memory)
  {
    return
      string(
        abi.encodePacked(
          uri(_tokenId),
          "/nfts/", Strings.toString(_tokenId))
        );
  }


  /**
  @dev collection functions
 */

  function viewAllCollectionTokens(uint256 _collectionId) public view
    returns (uint256[] memory)
  {
    return collectionIdToTokenIds[_collectionId];
  }

  function lockCollection(uint256 _collectionId) public onlyOwner {
    collections[_collectionId].locked = true;
  }

  function pauseCollection(uint256 _collectionId) public onlyOwner {
    collections[_collectionId].paused = !collections[_collectionId].paused;
  }

  function addCollectionSize(uint256 _collectionId, uint256 _maxInvocations) public onlyOwner {
    collections[_collectionId].maxInvocations = _maxInvocations;
  }

  function addCollectionPrice(uint256 _collectionId, uint256 _tokenPriceInWei) public onlyOwner {
    collections[_collectionId].tokenPriceInWei = _tokenPriceInWei;
  }


  function addCollection(
    string memory _name,
    uint256 _tokenPriceInWei,
    uint256 _maxInvocations,
    uint256 _projectId
  ) public onlyOwner {
    uint256 collectionId = nextCollectionId;
    collections[collectionId].name = _name;
    collections[collectionId].tokenPriceInWei = _tokenPriceInWei;
    collections[collectionId].maxInvocations = _maxInvocations;
    collections[collectionId].paused = true;
    collections[collectionId].locked = false;
    projectToCollection[_projectId].push(nextCollectionId);
    nextCollectionId++;
  }

  function viewCollectionDetails(uint256 _collectionId)
    public
    view
    returns (
      string memory name,
      uint256 tokenPriceInWei,
      uint256 invocations,
      uint256 maxInvocations,
      bool paused,
      bool locked
    )
  {
    name = collections[_collectionId].name;
    tokenPriceInWei = collections[_collectionId].tokenPriceInWei;
    maxInvocations = collections[_collectionId].maxInvocations;
    invocations = collections[_collectionId].invocations;
    paused = collections[_collectionId].paused;
    locked = collections[_collectionId].locked;
  }

  /**
  @dev project functions
 */

  function viewCollectionsOfProjects(uint256 _projectId) public view returns (uint256[] memory collections){
    return projectToCollection[_projectId];
  }

    /**
  @dev events
 */
  event Mint(
    address indexed _to,
    uint256 indexed _tokenId,
    uint256 indexed _collectionId,
    uint256 _invocations,
    uint256 _value
  );

}
