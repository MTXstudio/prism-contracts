// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Cyberfrens is ERC721Enumerable {
  /**
  @dev events
 */
  event Mint(address indexed _to, uint256 indexed _tokenId);
  event Migration(address indexed _to, uint256 indexed _tokenId);

  /**
  @dev global
 */
  address public admin;
  address public router;
  uint256 public nextTokenId = 1;
  uint256 public maxMint;
  uint256 public tokenPriceInWei;
  string public baseURI;
  bool public isMintPaused = true;
  /**
  @dev minters store
 */
  mapping(uint256 => address) public tokenIdToMinterAddress;

  /**
  @dev constructor
 */

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    address _router,
    uint256 _maxMint,
    uint256 _tokenPriceInWei
  ) ERC721(_tokenName, _tokenSymbol) {
    admin = msg.sender;
    maxMint = _maxMint;
    router = _router;
    tokenPriceInWei = _tokenPriceInWei;
  }

  /**
  @dev modifiers
 */

  modifier onlyValidTokenId(uint256 _tokenId) {
    require(_exists(_tokenId), "Token ID does not exist Yet");
    _;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin");
    _;
  }

  /**
  @dev helpers 
 */
  function _splitFunds() internal {
    if (msg.value > 0) {
      uint256 refund = msg.value - tokenPriceInWei;
      if (refund > 0) {
        payable(msg.sender).transfer(refund);
      }
      payable(admin).transfer(tokenPriceInWei);
    }
  }

  function pauseMint() public onlyAdmin {
    isMintPaused = !isMintPaused;
  }

  function addBaseURI(string memory _newBaseURI) public onlyAdmin {
    baseURI = _newBaseURI;
  }

  function contractURI() public pure returns (string memory) {
    return
      string(
        "https://gateway.pinata.cloud/ipfs/QmPHQECr5EdhTgeWDjKJL7VNcSsFgrTeTVTgFtLpKmNbaA"
      );
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    override
    onlyValidTokenId(_tokenId)
    returns (string memory)
  {
    return string(abi.encodePacked(baseURI, "/nfts/", Strings.toString(_tokenId)));
  }

  /**
  @dev Mint Functions
 */

  function _mintToken(address _to) internal returns (uint256 _tokenId) {
    uint256 tokenIdToBe = nextTokenId;
    nextTokenId += 1;
    _mint(_to, tokenIdToBe);
    tokenIdToMinterAddress[tokenIdToBe] = _to;
    emit Mint(_to, tokenIdToBe);
    return tokenIdToBe;
  }

  function mintFriend() public payable returns (uint256 _tokenId) {
    return mintFriendTo(msg.sender);
  }

  function mintFriendTo(address _to) public payable returns (uint256 _tokenId) {
    require(msg.value >= tokenPriceInWei, "Must send at least current token price");
    require(nextTokenId <= maxMint, "Must not exceed maximum mint");
    require(!isMintPaused || msg.sender == admin, "Purchases must not be paused");
    uint256 tokenId = _mintToken(_to);
    _splitFunds();
    return tokenId;
  }


}
