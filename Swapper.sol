pragma solidity >=0.8.9;

// SPDX-License-Identifier: MIT

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

contract USDCSwapper {
    
        //address of the pancake swap router
    address private constant UNISWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    
   function swap(uint amount, address _to) internal {
      
    address[] memory path;
      path = new address[](2);
      path[0] = WETH;
      path[1] = USDC;

        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactETHForTokens{value: amount}(0, path,  _to, block.timestamp);
    }
    
    
        receive() external payable {
            
        swap(msg.value,msg.sender);
        
    }
}
