// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
import "@openzeppelin/contracts/utils/Context.sol";


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

contract PrismProjects is Ownable {
  
 using Strings for uint256;

  /**
  @dev global
 */
  uint256 public nextProjectId = 1;
  string public projectBaseURI;
  enum AssetType { STANDARD , TRAIT , MASTER }
  
  /**
  @dev mappings
 */
  
  //Project mappings
  mapping (uint256 => Project) public projects;
  mapping (address => Project[]) private addressToProjects;
  

  /**
  @dev constructor
 */

  constructor(
  ){
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

  /**
  @dev modifiers
 */

  modifier onlyChef(uint256 _projectId) {
      require(projects[_projectId].chef == _msgSender() || _msgSender() == owner() , "Must own token");
    _;
  }


  /**
  @dev helpers 
 */

  function addBaseURI(string memory _projectURI)
    public
    onlyOwner
  {
    projectBaseURI = _projectURI;
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


  // if traitType is empty it is master or standard assetType and therefore needs to turn true
  // if traitType is not empty it needs to be part of the string specified in projects

  function checkTraitType(uint256 _id, string memory _traitType)
  external
  view
  returns(bool)
  {
    bytes32 traitType_ = keccak256(abi.encodePacked(_traitType));
    bytes memory _typeString = bytes(_traitType);
    bool traitExists = false;
    string[] memory allTypes = projects[_id].traitTypes;

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




  /**
  @dev view functions
 */

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

  function viewProjectChef(uint256 _id)
  external
  view
  returns (address)
  { 
  return projects[_id].chef;
  }

  function viewProjectTraitTypes(uint256 _projectId)
  external
  view
  returns (string[] memory)
  { 
  return projects[_projectId].traitTypes;
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

}