// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Context.sol";


/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
    * @dev Returns true if `account` is a contract.
    *
    * [IMPORTANT]
    * ====
    * It is unsafe to assume that an address for which this function returns
    * false is an externally-owned account (EOA) and not a contract.
    *
    * Among others, `isContract` will return false for the following
    * types of addresses:
    *
    *  - an externally-owned account
    *  - a contract in construction
    *  - an address where a contract will be created
    *  - an address where a contract lived, but was destroyed
    * ====
    *
    * [IMPORTANT]
    * ====
    * You shouldn't rely on `isContract` to protect against flash loan attacks!
    *
    * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
    * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
    * constructor.
    * ====
    */
  function isContract(address account) public view returns (bool) {
      // This method relies on extcodesize/address.code.length, which returns 0
      // for contracts in construction, since the code is only stored at the end
      // of the constructor execution.

      return account.code.length > 0;
  }

  /**
    * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
    * `recipient`, forwarding all available gas and reverting on errors.
    *
    * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
    * of certain opcodes, possibly making contracts go over the 2300 gas limit
    * imposed by `transfer`, making them unable to receive funds via
    * `transfer`. {sendValue} removes this limitation.
    *
    * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
    *
    * IMPORTANT: because control is transferred to `recipient`, care must be
    * taken to not create reentrancy vulnerabilities. Consider using
    * {ReentrancyGuard} or the
    * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
    */
  function sendValue(address payable recipient, uint256 amount) public {
      require(address(this).balance >= amount, "Address: insufficient balance");

      (bool success, ) = recipient.call{value: amount}("");
      require(success, "Address: unable to send value, recipient may have reverted");
  }

  /**
    * @dev Performs a Solidity function call using a low level `call`. A
    * plain `call` is an unsafe replacement for a function call: use this
    * function instead.
    *
    * If `target` reverts with a revert reason, it is bubbled up by this
    * function (like regular Solidity function calls).
    *
    * Returns the raw returned data. To convert to the expected return value,
    * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
    *
    * Requirements:
    *
    * - `target` must be a contract.
    * - calling `target` with `data` must not revert.
    *
    * _Available since v3.1._
    */
  function functionCall(address target, bytes memory data) public returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
  }

  /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
    * `errorMessage` as a fallback revert reason when `target` reverts.
    *
    * _Available since v3.1._
    */
  function functionCall(
      address target,
      bytes memory data,
      string memory errorMessage
    ) public returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


  /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    * but also transferring `value` wei to `target`.
    *
    * Requirements:
    *
    * - the calling contract must have an ETH balance of at least `value`.
    * - the called Solidity function must be `payable`.
    *
    * _Available since v3.1._
    */
  function functionCallWithValue(
      address target,
      bytes memory data,
      uint256 value
    ) public returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

  /**
    * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
    * with `errorMessage` as a fallback revert reason when `target` reverts.
    *
    * _Available since v3.1._
    */
  function functionCallWithValue(
      address target,
      bytes memory data,
      uint256 value,
      string memory errorMessage
  ) public returns (bytes memory) {
      require(address(this).balance >= value, "Address: insufficient balance for call");
      require(isContract(target), "Address: call to non-contract");

      (bool success, bytes memory returndata) = target.call{value: value}(data);
      return verifyCallResult(success, returndata, errorMessage);
  }

  /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    * but performing a static call.
    *
    * _Available since v3.3._
    */
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
      return functionStaticCall(target, data, "Address: low-level static call failed");
  }

  /**
    * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
    * but performing a static call.
    *
    * _Available since v3.3._
    */
  function functionStaticCall(
      address target,
      bytes memory data,
      string memory errorMessage
    ) public view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

  /**
    * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    * but performing a delegate call.
    *
    * _Available since v3.4._
    */
  function functionDelegateCall(address target, bytes memory data) public returns (bytes memory) {
      return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }

  /**
    * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
    * but performing a delegate call.
    *
    * _Available since v3.4._
    */
  function functionDelegateCall(
      address target,
      bytes memory data,
      string memory errorMessage
      ) public returns (bytes memory) {
          require(isContract(target), "Address: delegate call to non-contract");

          (bool success, bytes memory returndata) = target.delegatecall(data);
          return verifyCallResult(success, returndata, errorMessage);
      }


  /**
    * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
    * revert reason using the provided one.
    *
    * _Available since v4.3._
    */
  function verifyCallResult(
      bool success,
      bytes memory returndata,
      string memory errorMessage
    ) public pure returns (bytes memory) {
      if (success) {
          return returndata;
      } else {
          // Look for revert reason and bubble it up if present
          if (returndata.length > 0) {
              // The easiest way to bubble the revert reason is using memory via assembly

              assembly {
                  let returndata_size := mload(returndata)
                  revert(add(32, returndata), returndata_size)
              }
          } else {
              revert(errorMessage);
          }
      }
  }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) public pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

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
        _setApprovalForAll(_msgSender(), operator, approved);
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
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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

contract Prism1155 is ERC1155, Ownable, IERC2981 {
  
 using Strings for uint256;

  /**
  @dev global
 */
  address public implementation;
  uint256 public nextTokenId = 1;
  uint256 public nextCollectionId = 1;
  uint256 public nextProjectId = 1;
  uint256 public defaultRoyalty = 500;

  string public collectionBaseURI;
  string public projectBaseURI;
  enum AssetType { STANDARD , TRAIT , MASTER }
  
  /**
  @dev mappings
 */
  
  //Project mappings
  mapping (uint256 => Project) public projects;
  mapping (address => Project[]) private addressToProjects;
  mapping (uint256 => Collection[]) private projectIdToCollection;
  
  
  //Collection mappings
  mapping(uint256 => Collection) public collections;
  mapping(address => Collection[]) private addressToCollections;
  mapping (uint256 => Token[]) private collectionIdToToken;
  
  
  //Token mappings
  mapping (uint256 => Token) public tokens;
  mapping (address => Token[]) private addressToToken;
  mapping (uint256 => uint256[]) private masterToTraits;
  mapping (address => mapping (uint256 => uint256)) public addressToTokenIdToUsed;
  mapping(uint256 => uint256) private _totalSupply;

  /**
  @dev constructor
 */

  constructor(
    address _implementation 
  ) ERC1155("https://game.example/api/item.json"){
    implementation = _implementation;
  }

  /**
  @dev structs
 */
  
  struct Project {
    uint256 id; // --> add this to creation  function
    string name;
    address chef;
    string[] traitTypes;
  }

  struct Collection {
    string name;
    uint256 id; // --> add this to creation  function
    uint256 projectId;
    uint256 royalties; // in 1000th e.g. 1000 for 10%
    address manager; // gets royalties 
    uint256 invocations;
    uint256 maxInvocations;
    AssetType assetType;
    bool paused;
    bool locked;
  }

  struct Token {
    uint256 id;
    string name;
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

  modifier onlyOpenCollection(uint256 _collectionId, uint256 _amount) {
    require(!collections[_collectionId].locked, "Only unlocked collections");
    require(collections[_collectionId].invocations + _amount <= collections[_collectionId].maxInvocations, "Must not exceed max invocations");
    require(!collections[_collectionId].paused || _msgSender() == collections[_collectionId].manager || _msgSender() == owner() , "Purchases must not paused");
    _;
  }

  modifier onlyTokenPrice(uint256 _tokenId, uint256 _value) {
      require(_value >= tokens[_tokenId].priceInWei,
      "Must send >= current price"
    );
    _;
  }

  modifier onlyAllowedToken(uint256 _tokenId, uint256 _amount) {
      require(exists(_tokenId), "Token must exist");
      require(tokens[_tokenId].maxSupply > totalSupply(_tokenId) + _amount ,"Must not reached max supply"); 
    _;
  }

  modifier onlyTokenOwner(uint256 _tokenId) {
      require(balanceOf(_msgSender(), _tokenId) > 0 , "Must own token");
    _;
  }

  modifier onlyChef(uint256 _projectId) {
      require(projects[_projectId].chef == _msgSender() || _msgSender() == owner() , "Must own token");
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
    collections[_collectionId].invocations += _amount;
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
  {
    require(collections[tokens[_id].collectionId].manager == _msgSender() || _msgSender() == owner() , "Must own token");
    collections[tokens[_id].collectionId].invocations += _amount;
  }

  /**
  @dev helpers 
 */

  function _splitFunds(uint256 _tokenId) 
    internal
    onlyTokenPrice(_tokenId, msg.value)
  {
    if (msg.value > 0) {
      uint256 tokenPriceInWei = tokens[_tokenId].priceInWei;
      uint256 refund = msg.value - tokenPriceInWei;
      if (refund > 0) {
        payable(_msgSender()).transfer(refund);
      }
      payable(owner()).transfer(tokenPriceInWei);
    }
  }

  function addBaseURIs(string memory _projectURI, string memory _collectionURI, string memory _tokenURI)
    public
    onlyOwner
  {
    projectBaseURI = _projectURI;
    collectionBaseURI = _collectionURI;
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
      delete masterToTraits[_mNftId][i];}

    for (uint256 k=0;k < _traitIds.length; k++){
      require(balanceOf(_msgSender(), _traitIds[k]) > addressToTokenIdToUsed[_msgSender()][_traitIds[k]], "Trait must not be used");
      
      addressToTokenIdToUsed[_msgSender()][_traitIds[k]]++;
      masterToTraits[_mNftId].push(_traitIds[k]);
      }
      MasterEdit(_mNftId, masterToTraits[_mNftId]);
      return masterToTraits[_mNftId];  
  }  


  function createTokens(
    string[] memory _name, 
    uint256[] memory _price, 
    uint256[] memory _collectionId,
    uint256[] memory _maxSupply, 
    string[] memory _traitType,
    AssetType[] memory _assetType) 
    public 
  {
    for (uint256 i= 0; i < _name.length; i++) {
      require(collections[_collectionId[i]].manager == _msgSender() || _msgSender() == owner() , "Must own token");
      require(checkTraitType(collections[_collectionId[i]].projectId,_traitType[i]), "TraitType must be in project" );
      
      Token memory token;
      token.id = nextTokenId;
      token.name = _name[i];
      token.projectId = collections[_collectionId[i]].projectId;
      token.collectionId = _collectionId[i];
      token.priceInWei = _price[i];
      token.maxSupply = _maxSupply[i]; 
      token.traitType = _traitType[i];
      token.assetType = _assetType[i];
      token.paused = true;
      token.locked = false;
      tokens[nextTokenId] = token;

      collectionIdToToken[_collectionId[i]].push(token);
      emit TokenCreated(token.name, nextTokenId, token.projectId, token.collectionId, token.priceInWei, token.maxSupply, token.traitType, token.assetType, true);
      nextTokenId++;   
    }
  }


  // if traitType is empty it is master or standard assetType and therefore needs to turn true
  // if traitType is not empty it needs to be part of the string specified in projects

  function checkTraitType(uint256 _projectId, string memory _traitType)
  internal
  view
  returns(bool)
  {
    bytes32 traitType_ = keccak256(abi.encodePacked(_traitType));
    bytes memory _typeString = bytes(_traitType);
    bool traitExists = false;
    string[] memory allTypes = projects[_projectId].traitTypes;

    if (_typeString.length == 0){
      traitExists = true;} 
    else {
      for (uint256 i= 0; i < allTypes.length; i++) {
        if(keccak256(abi.encodePacked(allTypes[i])) == traitType_){
          traitExists = true;
        }
    }
    }
    return traitExists;
  }

  function exists(uint256 id) public view returns (bool) {
      return tokens[id].maxSupply != 0;
    }

  function lockToken(uint256 _tokenId) public onlyOwner {
    tokens[_tokenId].locked = true;
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
      require(collections[_collectionId].manager == _msgSender() || _msgSender() == owner() , "Must own token");
      require(checkTraitType(collections[_collectionId].projectId,_traitType), "TraitType must be in project" );
      
      tokens[_id].name = _name;
      tokens[_id].projectId = collections[_collectionId].projectId;
      tokens[_id].collectionId = _collectionId;
      tokens[_id].priceInWei = _price;
      tokens[_id].maxSupply = _maxSupply; 
      tokens[_id].traitType = _traitType;
      tokens[_id].assetType = _tokenType;
      tokens[_id].paused = _paused;   
  }

  // Token View functions

  function tokenURI(uint256 _tokenId)
  public
  view
  returns (string memory)
  { 
  return string(abi.encodePacked(
    uri(_tokenId), Strings.toString(_tokenId)));
  }

  function tokensOfCollection(uint256 _collectionId)
  public
  view
  returns (Token[] memory)
  { 
  return collectionIdToToken[_collectionId];
  }

  function tokensOfAddress(address _address)
  public
  view
  returns (Token[] memory)
  { 
  return addressToToken[_address];
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
  @dev collection functions
 */

  function createCollection(
    string memory _name,
    uint256 _maxInvocations,
    uint256 _projectId,
    address _manager,
    AssetType _assetType,
    uint256 _royaltiesInBasePoints // needs to be in 1000: 5% = 500

  ) 
  public 
  onlyChef(_projectId)
  {
  
    Collection memory collection;
    collection.name = _name;
    collection.maxInvocations = _maxInvocations;
    collection.manager = _manager;
    collection.assetType = _assetType;
    collection.royalties = _royaltiesInBasePoints;
    collection.paused = true;
    collection.locked = false;
    collections[nextCollectionId] = collection;
    projectIdToCollection[_projectId].push(collection); 
    addressToCollections[_manager].push(collection);
    
    emit CollectionCreated(_name, nextCollectionId, _projectId, _royaltiesInBasePoints, _manager, _maxInvocations, _assetType, true);
    nextCollectionId++;
  }

  function editCollection(
    uint256 _id,
    string memory _name,
    uint256 _maxInvocations,
    address _manager,
    uint256 _royaltiesInBasePoints,
    AssetType _assetType,
    bool _paused
  
    )
    public
    onlyChef(collections[_id].projectId)
    {
    collections[_id].name = _name;
    collections[_id].maxInvocations = _maxInvocations;
    collections[_id].manager = _manager;
    collections[_id].royalties = _royaltiesInBasePoints;
    collections[_id].assetType = _assetType;
    collections[_id].paused = _paused;

  }

  function lockCollection(uint256 _id) 
  public 
  {
    require(collections[_id].manager == _msgSender() || _msgSender() == projects[collections[_id].projectId].chef || _msgSender() == owner() , "Must be chef or manager");
    collections[_id].locked = true;
  }

  function collectionURI(uint256 _id) 
  public 
  view
  returns (string memory)
  {
  return string(abi.encodePacked(
    collectionBaseURI, Strings.toString(_id)));
  }

  function collectionsOfProject(uint256 _projectId)
  public
  view
  returns (Collection[] memory)
  { 
  return projectIdToCollection[_projectId];
  }

  function collectionsOfManager(address _manager)
  public
  view
  returns (Collection[] memory)
  { 
  return addressToCollections[_manager];
  }


  /**
  @dev project functions
 */

  function createProject(
      string memory _name,
      address _chef,
      string[] memory _traitTypes
    ) public 
    {
      Project memory project;
      project.id = nextProjectId;
      project.name = _name;
      project.chef = _chef;
      project.traitTypes = _traitTypes;
      projects[nextProjectId] = project;
      emit ProjectCreated(nextProjectId, _name, _chef, _traitTypes);
      addressToProjects[_msgSender()].push(project);
      nextProjectId++;  
    }

  function editProject( uint256 _id, string memory _name, address _chef, string[] memory _traitTypes) 
  public
  onlyChef(_id)
  {
    require(address(0) != projects[_id].chef, "Project must exist");
    projects[_id].name = _name;
    projects[_id].chef = _chef;
    projects[_id].traitTypes = _traitTypes;

  }

  function projectURI(uint256 _projectId)
  public
  view
  returns (string memory)
  {
    return string(abi.encodePacked(
      projectBaseURI, Strings.toString(_projectId)));
  }

  function chefToProjects(address _chef)
  public
  view
  returns (Project[] memory)
  { 
  return addressToProjects[_chef];
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
      for (uint256 k=0;k < amounts[i]; k++){
        if (from == address(0)){
          addressToToken[to].push(tokens[ids[i]]);
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

    for (uint256 i=0;i < addressToToken[_from].length; i++){
      if(_id == addressToToken[_from][i].id){
        addressToToken[_to].push(addressToToken[_from][i]);
        delete addressToToken[_from][i];
        break;
      }
    }
  }


  /**
    * @inheritdoc IERC2981
    */
  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view override returns (address, uint256) {
    address receiver = collections[tokens[_tokenId].collectionId].manager;
    uint256 royalty = collections[tokens[_tokenId].collectionId].royalties;
    if( royalty == 0) {
      royalty = defaultRoyalty;
    }
    
    if( receiver != address(0)) {
        royalty = 0;
    }

    uint256 royaltyAmount = (_salePrice * royalty) / _feeDenominator();
    return(receiver, royaltyAmount);
  }


  /**
    * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
    * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
    * override.
    */
  function _feeDenominator() internal pure returns (uint96) {
      return 10000;
  }


  function setImplementation(address _implementation) public onlyOwner(){
    implementation = _implementation;
  }


    /**
  @dev events
 */

  event ProjectCreated(
    uint256 indexed _id,
    string _name,
    address _chef,
    string[] traitTypes
  );

  event CollectionCreated(
    string _name,
    uint256 indexed _id,
    uint256 indexed _projectId,
    uint256 royalties,
     address manager,
    uint256 _maxInvocation,
    AssetType assetType,
    bool paused
  );

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