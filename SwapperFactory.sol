//SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}



contract SwapperFactory is Ownable {

    address public baseCurrency;

    address[] public swappers;

    function setBaseCurrency(address base) public onlyOwner {
        baseCurrency = base;
    }

    function createSwapperContract(address token,address router) public returns (address) {
    address payable thisContract = payable(address(this));
    FlexSwapper swapper = new FlexSwapper(token,router,baseCurrency,thisContract);
    address swapperAddress = address(swapper);
    swappers.push(swapperAddress);
    return swapperAddress;
    }

    function withdraw(address payable destination) external onlyOwner {
        destination.transfer(address(this).balance);
    }


    receive() external payable { }

}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}

contract FlexSwapper is Ownable {

    address private mRouter;
    
    address private mBase;
    
    address private mToken;

    address payable private mDestination;


    constructor(address token, address router,address base,address payable destination) {
        mToken = token;
        mRouter = router;
        mBase = base;
        mDestination = destination;
    }
    
        //address of the pancake swap router

    
   function swap(uint amount, address _to) internal {
      
      address[] memory path;
      path = new address[](2);
      path[0] = mBase;
      path[1] = mToken;
      IUniswapV2Router(mRouter).swapExactETHForTokens{value: amount}(0, path,  _to, block.timestamp);
    }
    
    
        receive() external payable {
        uint256 swapValue = (msg.value * 99) / 100;    
        uint256 transferValue = (msg.value * 1) / 100;

        swap(swapValue,msg.sender);
        mDestination.transfer(transferValue);
        
    }
}

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}



contract SwapperFactory is Ownable {

    address public baseCurrency;

    address[] public swappers;

    function setBaseCurrency(address base) public onlyOwner {
        baseCurrency = base;
    }

    function createSwapperContract(address token,address router) public returns (address) {
    address payable thisContract = payable(address(this));
    FlexSwapper swapper = new FlexSwapper(token,router,baseCurrency,thisContract);
    address swapperAddress = address(swapper);
    swappers.push(swapperAddress);
    return swapperAddress;
    }

    function withdraw(address payable destination) external onlyOwner {
        destination.transfer(address(this).balance);
    }


    receive() external payable { }

}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}

contract FlexSwapper is Ownable {

    address private mRouter;
    
    address private mBase;
    
    address private mToken;

    address payable private mDestination;


    constructor(address token, address router,address base,address payable destination) {
        mToken = token;
        mRouter = router;
        mBase = base;
        mDestination = destination;
    }
    
        //address of the pancake swap router

    
   function swap(uint amount, address _to) internal {
      
      address[] memory path;
      path = new address[](2);
      path[0] = mBase;
      path[1] = mToken;
      IUniswapV2Router(mRouter).swapExactETHForTokens{value: amount}(0, path,  _to, block.timestamp);
    }
    
    
        receive() external payable {
        uint256 swapValue = (msg.value * 99) / 100;    
        uint256 transferValue = (msg.value * 1) / 100;

        swap(swapValue,msg.sender);
        mDestination.transfer(transferValue);
        
    }
}