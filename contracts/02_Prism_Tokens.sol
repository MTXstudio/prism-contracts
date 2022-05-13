// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be payed in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

interface IPrismProject{

  enum AssetType {MASTER, TRAIT, OTHER}

  struct Collection {
    string name;
    uint256 id;
    uint256 projectId;
    uint256 royalties;
    address manager;
    uint256 invocations;
    uint256 maxInvocations;
    AssetType assetType;
    bool paused; 
  }

  function viewProjectChef(uint256 _id) external view returns (address _chef);

  function checkTraitType(uint256 _id, string memory _traitType) external returns(bool);

  function addInvocation(uint256 _collectionId, uint _amount) external;  

  function viewProjectId(uint256 _id) external view returns(uint256 projectId);
  function viewMaxInvocations(uint256 _id) external view returns(uint256 maxInvocations);
  function viewInvocations(uint256 _id) external view returns(uint256 invocations);
  function viewManager(uint256 _id) external view returns(address manager);
  function viewRoyalties(uint256 _id) external view returns(uint256 royalties);
  function viewPausedStatus (uint256 _id) external view returns(bool paused);
  
}

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

  /**
    * @dev See {IERC165-supportsInterface} for ERC2981.
    */
  function supportsInterface(bytes4 interfaceId) 
  public 
  view 
  virtual 
  override
  returns (bool) {
    return
      interfaceId == type(IERC165).interfaceId ||
      interfaceId == type(IERC2981).interfaceId ||
      interfaceId == type(IERC1155).interfaceId ||
      interfaceId == type(IERC1155MetadataURI).interfaceId;
  }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }


    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
      require(_msgSender() != operator, "ERC1155: setting approval status for self");
      _operatorApprovals[_msgSender()][operator] = approved;
      emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

contract PrismToken is ERC1155, Ownable, IERC2981 {
  
 using Strings for uint256;

  /**
  @dev global
 */
  address public prismProjectContract;
  uint256 public nextTokenId = 1;
  uint256 public defaultRoyalty = 500;
  uint256 private feeDenominator = 1000;

  string public collectionBaseURI;
  enum AssetType {MASTER, TRAIT, OTHER}
  
  /**
  @dev mappings
 */
  
  //Collection mappings
  mapping (uint256 => uint256[]) private collectionIdToTokenId;
  
  
  //Token mappings
  mapping (uint256 => Token) public tokens;
  mapping (address => uint256[]) private addressToTokenIds;
  mapping (uint256 => uint256[]) private masterToTraits;
  mapping (address => mapping (uint256 => uint256)) public addressToTokenIdToUsed;
  mapping(uint256 => uint256) private _totalSupply;

  /**
  @dev constructor
 */

  constructor(
    address _prismProjectContract
  ) ERC1155("https://game.example/api/item.json"){
    prismProjectContract = _prismProjectContract;
  }

  /**
  @dev structs
 */

  struct Token {
    uint256 id;
    string name;
    address creator;
    uint256 maxSupply;
    uint256 priceInWei;
    uint256 projectId;
    uint256 collectionId;
    string traitType;
    AssetType assetType;
    bool paused;
    bool locked;
  }


  /**
  @dev modifiers
 */

  modifier onlyOpenCollection(uint256 _id, uint256 _amount) {
    uint256 _invocations = IPrismProject(prismProjectContract).viewInvocations(_id);
    uint256 _maxInvocations = IPrismProject(prismProjectContract).viewMaxInvocations(_id);
    bool _paused = IPrismProject(prismProjectContract).viewPausedStatus(_id);
    address _manager = IPrismProject(prismProjectContract).viewManager(_id);
    require(_invocations + _amount <= _maxInvocations, "Must not exceed max invocations");
    require(!_paused || _msgSender() == _manager || _msgSender() == owner() , "Purchases must not paused");
    _;
  }

  modifier onlyTokenPrice(uint256 _id, uint256 _value) {
      require(_value >= tokens[_id].priceInWei,
      "Must send >= current price"
    );
    _;
  }

  modifier onlyAllowedToken(uint256 _id, uint256 _amount) {
      require(exists(_id), "Token must exist");
      require(tokens[_id].maxSupply >= totalSupply(_id) + _amount ,"Must not reached max supply"); 
    _;
  }

  modifier onlyTokenOwner(uint256 _id) {
      require(balanceOf(_msgSender(), _id) > 0 , "Must own token");
    _;
  }

  modifier onlyChef(uint256 _projectId) {
      address _chef = IPrismProject(prismProjectContract).viewProjectChef(_projectId);
      require(_chef == _msgSender() || _msgSender() == owner() , "Must be project owner");
    _;
  }

  modifier onlyManager(uint256 _collectionId) {
    address _manager = IPrismProject(prismProjectContract).viewManager(_collectionId);
      require(_manager == _msgSender() || _msgSender() == owner() , "Must manage collection");
    _;
  }


  /**
  @dev setup and mint Functions
 */

  function mintTo(address _to, uint256 _tokenId, uint256 _amount, uint256 _collectionId) 
    external
    payable  
  {
    if (_msgSender() != owner()){
      _splitFunds(_collectionId);
    }
    _mintTo(_to, _tokenId ,_collectionId,_amount);
  }

 function _mintTo(address _to,  uint256 _tokenId, uint256 _collectionId,  uint256 _amount) 
  internal
  onlyOpenCollection(_collectionId, _amount)
  onlyAllowedToken(_tokenId, _amount)
  {
    IPrismProject(prismProjectContract).addInvocation(_collectionId, _amount);
    _mint(_to, _tokenId, _amount,"");
  }


  function mintBatch(
        uint256[] memory _ids,
        uint256[] memory _amounts,
        address _to,
        bytes memory _data
    ) 
    public 
    {
      for (uint256 i=0;i < _ids.length; i++){
        checkBatchMint(_ids[i],_amounts[i]);
      }
      _mintBatch(_to,_ids, _amounts, _data);
    }

  function checkBatchMint(
      uint256 _id,
      uint256 _amount
  ) 
  internal 
  onlyOpenCollection(tokens[_id].collectionId, _amount)
  onlyAllowedToken(_id, _amount)
  onlyManager(tokens[_id].collectionId)
  {
    uint256 _collectionId = tokens[_id].collectionId;
    IPrismProject(prismProjectContract).addInvocation(_collectionId, _amount);
  }

  /**
  @dev helpers 
 */

  function _splitFunds(uint256 _id) 
    internal
    onlyTokenPrice(_id, msg.value)
  {
    if (msg.value > 0) {
      uint256 tokenPriceInWei = tokens[_id].priceInWei;
      uint256 refund = msg.value - tokenPriceInWei;
      if (refund > 0) {
        payable(_msgSender()).transfer(refund);
      }
      payable(owner()).transfer(tokenPriceInWei);
    }
  }

  function addBaseURIs(string memory _tokenURI)
    public
    onlyOwner
  {
    _setURI(_tokenURI);
  }

  /**
  @dev token functions
 */

  function editMaster(
    uint256 _mNftId,
    uint256[] memory _traitIds)
    public
    onlyTokenOwner(_mNftId)
  returns (uint256[] memory)
  {
    require(tokens[_mNftId].assetType == AssetType.MASTER ,"_mNFTId needs to be Master");
    
    for (uint256 i=0;i < masterToTraits[_mNftId].length; i++){
      addressToTokenIdToUsed[_msgSender()][masterToTraits[_mNftId][i]]--;
    }

    for (uint256 k=0;k < _traitIds.length; k++){
      require(balanceOf(_msgSender(), _traitIds[k]) > addressToTokenIdToUsed[_msgSender()][_traitIds[k]], "Must own and not use trait");
      
      addressToTokenIdToUsed[_msgSender()][_traitIds[k]]++;

      }
      masterToTraits[_mNftId] = _traitIds;
      MasterEdit(_mNftId, masterToTraits[_mNftId]);
      return masterToTraits[_mNftId];   
  } 


  function createBatchTokens(
    string[] memory _name, 
    uint256[] memory _price, 
    uint256[] memory _collectionId,
    uint256[] memory _maxSupply, 
    string[] memory _traitType,
    AssetType[] memory _assetType) 
    public 
  {
    for (uint256 i= 0; i < _name.length; i++) {
      createToken(_name[i], _price[i], _collectionId[i], _maxSupply[i], _traitType[i], _assetType[i]);
    }
  }

  function createToken(
    string memory _name, 
    uint256 _price, 
    uint256 _collectionId,
    uint256 _maxSupply, 
    string memory _traitType,
    AssetType _assetType) 
    public
    onlyManager(_collectionId)
  {
    uint256 _projectId = IPrismProject(prismProjectContract).viewProjectId(_collectionId);
    require(IPrismProject(prismProjectContract).checkTraitType(_projectId, _traitType), "TraitType must be in project" );
    Token memory token;
    token.id = nextTokenId;
    token.name = _name;
    token.creator = _msgSender();
    token.projectId = _projectId;
    token.collectionId = _collectionId;
    token.priceInWei = _price;
    token.maxSupply = _maxSupply; 
    token.traitType = _traitType;
    token.assetType = _assetType;
    token.paused = true;
    token.locked = false;
    tokens[nextTokenId] = token;

    collectionIdToTokenId[_collectionId].push(nextTokenId);
    emit TokenCreated(token.name, nextTokenId, token.projectId, token.collectionId, token.priceInWei, token.maxSupply, token.traitType, token.assetType, true);
    nextTokenId++; 
  }

  function exists(uint256 _id) public view returns (bool) {
      return tokens[_id].maxSupply != 0;
    }

  function lockToken(uint256 _id) public onlyManager(tokens[_id].collectionId){
    tokens[_id].locked = true;
  }

  function pauseToken(uint256 _id) public onlyManager(tokens[_id].collectionId) {
    tokens[_id].paused = !tokens[_id].paused;
  }

  function editTokens(
    uint256 _id,
    string memory _name,
    uint256 _price, 
    uint256 _collectionId,
    uint256 _maxSupply, 
    string memory _traitType,
    AssetType _tokenType,
    bool _paused) 
    public 
  {
    uint256 _projectId = IPrismProject(prismProjectContract).viewProjectId(_collectionId);
    require(IPrismProject(prismProjectContract).checkTraitType(_projectId, _traitType), "TraitType must be in project" );
      
      tokens[_id].name = _name;
      tokens[_id].projectId = _projectId;
      tokens[_id].collectionId = _collectionId;
      tokens[_id].priceInWei = _price;
      tokens[_id].maxSupply = _maxSupply; 
      tokens[_id].traitType = _traitType;
      tokens[_id].assetType = _tokenType;
      tokens[_id].paused = _paused;   
  }

  // Token View functions

  function tokenURI(uint256 _id)
  public
  view
  returns (string memory)
  { 
  return string(abi.encodePacked(
    uri(_id), _id));
  }

  function tokensOfCollection(uint256 _id)
  public
  view
  returns (uint256[] memory)
  { 
  return collectionIdToTokenId[_id];
  }

  function tokensOfAddress(address _address)
  public
  view
  returns (uint256[] memory)
  { 
  return addressToTokenIds[_address];
  }

  function traitsOfMaster(uint256 _id)
  public
  view
  returns (uint256[] memory)
  {
  return masterToTraits[_id];
  }
 
  /**
    * @dev Total amount of tokens in with a given id.
    */
  function totalSupply(uint256 id) public view virtual returns (uint256) {
      return _totalSupply[id];
  }

  /**
  @dev adjusting transfer function for token to remove trait if
  note Check that transfer is not a mint event with if statement
  note loop through tokenIds which should be transfered
  note check that the amount to be transfered is unequipped from master 
  note Loop through amount of tokens to be transfered and adjust token holdings
  */

  function _beforeTokenTransfer(
      address operator,
      address from,
      address to,
      uint256[] memory ids,
      uint256[] memory amounts,
      bytes memory data
  ) internal 
  virtual 
  override 
  {
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    
    if (from == address(0)) {
        for (uint256 i = 0; i < ids.length; ++i) {
            _totalSupply[ids[i]] += amounts[i];
        }
    }

    if (to == address(0)) {
        for (uint256 i = 0; i < ids.length; ++i) {
            _totalSupply[ids[i]] -= amounts[i];
        }
    }    
    for (uint256 i=0;i < ids.length; i++){
      if (balanceOf(to, ids[i]) == 0){
        if (from == address(0)){
          addressToTokenIds[to].push(ids[i]);
        } else {
          require(balanceOf(from, ids[i]) - addressToTokenIdToUsed[from][i] >= amounts[i], "Must un-equip Token");
          _adjustTokenHolding(from,to,ids[i]);
        } 
      }
    }
  }

  /**
  @dev adjusting TokenHoldings of users
  note Loop through users token Ids
  note if the Id exists remove from _from account token list and add to _to account list, then break
  */

  function _adjustTokenHolding(
    address _from,
    address _to,
    uint256 _id
  ) internal {

    for (uint256 i=0;i < addressToTokenIds[_from].length; i++){
      if(_id == addressToTokenIds[_from][i] && balanceOf(_from, _id) == 1){
        addressToTokenIds[_to].push(addressToTokenIds[_from][i]);
        delete addressToTokenIds[_from][i];
        break;
      } else if (_id == addressToTokenIds[_from][i] && balanceOf(_from, _id) > 1){
        addressToTokenIds[_to].push(addressToTokenIds[_from][i]);
        break;
      }
    }
  }

  /**
    * @inheritdoc IERC2981
    */
  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view override returns (address, uint256) {
    address receiver = IPrismProject(prismProjectContract).viewManager(tokens[_tokenId].collectionId);
    uint256 royalty = IPrismProject(prismProjectContract).viewRoyalties(_tokenId);
    if( royalty == 0) {
      royalty = defaultRoyalty;
    }
    if( receiver != address(0)) {
        royalty = 0;
    }

    uint256 royaltyAmount = (_salePrice * royalty) / feeDenominator;
    return(receiver, royaltyAmount);
  }


  function setPrismProjectContract(address _prismProjectContract) public onlyOwner(){
    prismProjectContract = _prismProjectContract;
  }


    /**
  @dev events
 */

  event TokenCreated(
    string _name,
    uint256 indexed _id,
    uint256 indexed _projectId,
    uint256 indexed _collectionId,
    uint256 _priceinWei,
    uint256 _maxSupply,
    string _traitType,
    AssetType assetType,
    bool _paused
  );

  event MasterEdit(
    uint256 indexed _mNFT,
    uint256[] indexed _traits
  );

}