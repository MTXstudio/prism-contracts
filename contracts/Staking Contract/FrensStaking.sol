pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract FrensStake is Ownable {

    using SafeMath for uint256;

    address public immutable xBTRFLY;
    uint256 public lockTime = 1209600 ; // 2 weeks in seconds 

    /// Constructor ///
    /**
        @dev constructor
     */
    constructor(
        address _xBTRFLY
    ){
        require(_xBTRFLY != address(0));
        xBTRFLY = _xBTRFLY;
    }

    /// Mappings ///
    /** 
        @dev User Address to stake
        */    
    mapping (address => uint256) userToStake ;
    mapping (address => uint256) userToLock ;

    /// Modifiers ///    
    /**
        @dev checks if unstake amount is lower or equal staked amount
        */
    modifier onlyStakedAmount( uint256 _amount) {
        require( _amount <= userToStake[msg.sender], "Amount must be smaller or equal to staked amount" );
        _;
    }

    modifier onlyAfterLockTime() {
        require( userToLock[msg.sender] <= block.timestamp, "LockTime must be over" );
        _;
    }
    

    /// Events ///    
    /**
        @dev event emits whenever someone stakes, unstakes or admin collects earnings
        */

    event Staked(
        uint256 _amount,
        address _user
    );

    event Unstaked(
        uint256 _amount,
        address _user
    );

    event EarningsCollected(
        uint256 _amount,
        address _user
    ); 

    /// Functions ///    
    /**
        @dev Stakes funds of user 
        */
    function stake(
        uint256 _amount
    ) 
        external
        payable
    {
        IERC20(xBTRFLY).transferFrom(msg.sender,address(this),_amount); 
        userToStake[msg.sender] += _amount;
        userToLock[msg.sender] = (block.timestamp.add(lockTime));
        emit Staked(_amount, msg.sender); 

    }

    function unstake(
        uint256 _amount
    ) 
        external 
        onlyStakedAmount(_amount)
        onlyAfterLockTime()
    {
        IERC20(xBTRFLY).transferFrom(address(this), msg.sender,_amount); 
        userToStake[msg.sender] -= _amount;
        emit Unstaked(_amount, msg.sender); 
    }


    /**
        @dev Collecting Earnings that are aggregated 
        */
    function collectEarnings(
        uint256 _amount
    ) 
        external
        onlyOwner
    {
        IERC20(xBTRFLY).transferFrom(address(this), msg.sender,_amount); 
        emit EarningsCollected(_amount, msg.sender); 
    }


    /**
        @dev Contract Owner sets locktime for staking
        */
    function changeLockTime(
        uint256 _seconds
    ) 
        external
        onlyOwner
    {
        lockTime = _seconds;
    }



    /**
        @dev Enables contract owner to change approved ERC20 Contracts
        */
    // function approveERC20(address _erc20Contract, bool _bool ) external onlyOwner {
    //     approvedERC20[_erc20Contract] = _bool;
    // }

}