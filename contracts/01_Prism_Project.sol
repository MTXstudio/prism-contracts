// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


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
  address public prismTokenContract;
  uint256 public nextProjectId = 1;
  uint256 public nextCollectionId = 1;
  string public collectionBaseURI;
  string public projectBaseURI;
  enum AssetType { MASTER, TRAIT, OTHER}
  
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
    uint256 id;
    string name;
    address chef;
    string[] traitTypes;
  }

  struct Collection {
    string name;
    uint256 id;
    uint256 projectId;
    uint256 royalties; // in 1000th e.g. 1000 for 10%
    address manager; // gets royalties 
    uint256 invocations;
    uint256 maxInvocations;
    AssetType assetType;
    bool paused;
  }

  /**
  @dev modifiers
 */

  modifier onlyChef(uint256 _projectId) {
      require(projects[_projectId].chef == _msgSender() || _msgSender() == owner() , "Must own token");
    _;
  }

  modifier onlyOpenCollection(uint256 _id, uint256 _amount) {
    require(collections[_id].invocations + _amount <= collections[_id].maxInvocations, "Must not exceed max invocations");
    require(!collections[_id].paused || _msgSender() == collections[_id].manager || _msgSender() == owner() , "Purchases must not paused");
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

  function checkTraitType(uint256 _id, string calldata _traitType)
  external
  view 
  returns(bool)
  {
    bytes32 traitType_ = keccak256(abi.encodePacked(_traitType));
    bytes memory _typeString = bytes(_traitType);
    string[] memory allTypes = projects[_id].traitTypes;

    if (_typeString.length == 0){
      return true;} 
    else {
      for (uint256 i= 0; i < allTypes.length; i++) {
        bytes32 _typ = keccak256(abi.encodePacked(allTypes[i]));
        if(_typ == traitType_){
          return true;
        }
      }   
    }
    return false;
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
  @dev collection functions
 */

  function createCollection(
    string memory _name,
    uint256 _maxInvocations,
    uint256 _projectId,
    address _manager,
    AssetType _assetType,
    uint256 _royalties // needs to be in 1000: 5% = 500

  ) 
  public 
  onlyChef(_projectId)
  {
    Collection memory collection;
    collection.name = _name;
    collection.maxInvocations = _maxInvocations;
    collection.manager = _manager;
    collection.assetType = _assetType;
    collection.projectId = _projectId;
    collection.royalties = (_royalties * 100) ;
    collection.paused = true;
    collection.id = nextCollectionId;
    collections[nextCollectionId] = collection;
    projectIdToCollection[_projectId].push(collection); 
    addressToCollections[_manager].push(collection);
    
    emit CollectionCreated(_name, nextCollectionId, _projectId, _royalties, _manager, _maxInvocations, _assetType, true);
    nextCollectionId++;
  }

  function editCollection(
    uint256 _id,
    uint256 _projectId,
    string memory _name,
    uint256 _maxInvocations,
    address _manager,
    uint256 _royalties,
    AssetType _assetType,
    bool _paused
  
    )
    public
    onlyChef(collections[_id].projectId)
    {
    collections[_id].name = _name;
    collections[_id].projectId = _projectId;
    collections[_id].maxInvocations = _maxInvocations;
    collections[_id].manager = _manager;
    collections[_id].royalties = (_royalties * 100);
    collections[_id].assetType = _assetType;
    collections[_id].paused = _paused;
  }

  function pauseCollection(uint256 _id) public onlyChef(collections[_id].projectId) {
    collections[_id].paused = !collections[_id].paused;
  }

  function addInvocation(uint256 _id, uint256 _amount) external {
    require(msg.sender == prismTokenContract, "Must be prism token contract" );
    collections[_id].invocations += _amount;
  }


  function viewProjectId(uint256 _id) external view returns(uint256 projectId){
    return collections[_id].projectId;
  }

  function viewMaxInvocations(uint256 _id) external view returns(uint256 maxInvocations){
    return collections[_id].maxInvocations;
  }

  function viewInvocations(uint256 _id) external view returns(uint256 invocations){
    return collections[_id].invocations;
  }

  function viewManager(uint256 _id) external view returns(address manager){
    return collections[_id].manager;
  }

  function viewRoyalties(uint256 _id) external view returns(uint256 royalties){
    return collections[_id].royalties;
  }

  function viewPausedStatus (uint256 _id) external view returns(bool paused){
    return collections[_id].paused;
  }




  // function viewCollection(
  //   uint256 _id
  //   )
  //   external
  //   view
  //   returns(
  //     string memory _name,
  //     uint256 _projectId,
  //     uint256 _collectionId,
  //     uint256 _invocations,
  //     uint256 _maxInvocations,
  //     address _manager,
  //     AssetType _assetType,
  //     uint256 _royalties,
  //     bool _paused
  //   )
  //   {
  //   _name = collections[_id].name;
  //   _maxInvocations = collections[_id].maxInvocations;
  //   _invocations = collections[_id].invocations;
  //   _manager = collections[_id].manager;
  //   _assetType = collections[_id].assetType;
  //   _projectId = collections[_id].projectId;
  //   _royalties = collections[_id].royalties;
  //   _paused = collections[_id].paused;
  //   _collectionId = collections[_id].id;
  // }



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

  function setPrismTokenContract(address _prismTokenContract) public onlyOwner(){
    prismTokenContract = _prismTokenContract;
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



}