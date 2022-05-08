//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

/*
    @title Proxyable a minimal proxy contract based on the EIP-1167 .
    @author Gabriel Willen (Useless Surgeon)
    @notice Using this contract is only necessary if you need to create large quantities of a contract.
        The use of proxies can significantly reduce the cost of contract creation at the expense of added complexity
        and as such should only be used when absolutely necessary. you must ensure that the memory of the created proxy
        aligns with the memory of the proxied contract. Inspect the created proxy during development to ensure it's
        functioning as intended.
    @custom::warning Do not destroy the contract you create a proxy too. Destroying the contract will corrupt every proxied
        contracted created from it.
*/
contract Proxyable {
    bool private proxy;

    /// @notice checks to see if this is a proxy contract
    /// @return proxy returns false if this is a proxy and true if not
    function isProxy() external view returns (bool) {
        return proxy;
    }

    /// @notice A modifier to ensure that a proxy contract doesn't attempt to create a proxy of itself.
    modifier isProxyable() {
        require(!proxy, "Unable to create a proxy from a proxy");
        _;
    }

    /// @notice initialize a proxy setting isProxy_ to true to prevents any further calls to initialize_
    function initialize_() external isProxyable {
        proxy = true;
    }

    /// @notice creates a proxy of the derived contract
    /// @return proxyAddress the address of the newly created proxy
    function createProxy() external isProxyable returns (address proxyAddress) {
        // the address of this contract because only a non-proxy contract can call this
        bytes20 deployedAddress = bytes20(address(this));
        assembly {
        // load the free memory pointer
            let fmp := mload(0x40)
        // first 20 bytes of built in proxy bytecode
            mstore(fmp, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
        // store 20 bytes from the target address at the 20th bit (inclusive)
            mstore(add(fmp, 0x14), deployedAddress)
        // store the remaining bytes
            mstore(add(fmp, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
        // create a new contract using the proxy memory and return the new address
            proxyAddress := create(0, fmp, 0x37)
        }
        // intiialize the proxy above to set its isProxy_ flag to true
        Proxyable(proxyAddress).initialize_();
    }
}

interface IMineDatabase {
    function isApprovedSource(address source) external view returns (bool);
    function getMineOwner(address mine) external view returns (address);
}

interface IMineLoanTaker {
    function makePayment(uint256 ID, uint256 amount) external returns (bool);
    function rollOverProfits(address stable, uint256 amount) external;
}

contract PersonalMineData {

    /** Stable Token For Repayments */
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    /** User Who May Operate The Mine */
    address public operator;

    /** Master Ownership, If Needed */
    address public master;

    /** Mine Database Contract */
    IMineDatabase public MineDB;

    /** Contract To Take + Repay Loans For The Mine */
    IMineLoanTaker public mineLoanTaker;

    /** Approval To Allow Mine Operators To Do Operations On Your Behalf */
    bool public allowOperatorControl;

    modifier onlyOperator(){
        if (allowOperatorControl) {
            require(msg.sender == master || msg.sender == operator, 'Only Master Or Operator');
        } else {
            require(msg.sender == operator, 'Only Operator');
        }
        _;
    }

    modifier onlyMaster(){
        require(msg.sender == master, 'Only Master');
        _;
    }

    modifier onlyApprovedSource(address source){
        require(
            MineDB.isApprovedSource(source),
            'Source Not Approved For Mining'
        );
    }

}

/**
    Interface between User and Available Mining Sources
    Ensures User cannot withdraw money to themselves from Mine
    Should have upgrade mechanisms built in ( triggerable by User )
    That lets it interact with Mine Sources and reroute its address to its new copy
        Example: for source in sources: IMineSource(source).setAccessTo(newMineAddress)
        If Mine moves to V2, The Mine should be able to tell the Yield Sources to 
        Change Data associated with User's V1 Mine to the new V2 Mine Contract
        This function should be accessible in all Mining Sources

    Mine Will Receive Stable Coins From The Loan Taker And Send Them To Different Approved Sources
    Mine Will Withdraw Stable Coins From Approved Sources And Pay Back The User's Loan Amount (send to loan taker)
    
 */
contract PersonalMine is PersonalMineData{

    function __init__(address operator_, address master_) external {
        require(
            operator == address(0) &&
            master == address(0),
            'Already Initialized'
        );
        require(
            operator_ != address(0) &&
            master_ != address(0),
            'Invalid Init Parameters'
        );
        operator = operator_;
        master = master_;
        MineDB = IMineDatabase(msg.sender);
    }

    function emergencyWithdraw(address token, uint256 amount) external onlyMaster {
        bool success = IERC20(token).transfer(operator, amount);
        require(success, 'Failure On Token Withdraw');
    }

    function setAllowOperatorControl(bool allowOperatorControl) external onlyOperator {
        allowOperatorControl = allowControl;
    }

    function payLoan(uint256 ID, uint256 amount) external onlyOperator {
        require(
            IERC20(BUSD).balanceOf(address(this)) >= amount,
            'Insufficient BUSD Balance'
        );
        IERC20(BUSD).approve(mineLoanTaker, amount);
        IMineLoanTaker(mineLoanTaker).makePayment(ID, amount);
    }

    function rollProfits(address stable, uint256 amount) external onlyOperator {
        require(
            IERC20(stable).balanceOf(address(this)) >= amount,
            'Insufficient BUSD Balance'
        );
        IERC20(stable).approve(mineLoanTaker, amount);
        IMineLoanTaker(mineLoanTaker).rollOverProfits(stable, amount);
    }

    function functionCallOnSource(address source, bytes calldata data) external onlyApprovedSource(source) onlyOperator {
        functionCall(source, data, 'Error Calling Function');
    }

    function functionCallOnSourceWithApprove(address source, bytes calldata data, address token, uint256 amount) external onlyApprovedSource(source) onlyOperator {
        IERC20(token).approve(source, amount);
        functionCall(source, data, 'Error Calling Function');
    }

    function callDataOnSource(address source, bytes calldata data) external onlyApprovedSource(source) onlyOperator {
        source.call(data);
    }

    function transferSourceTokens(address source, address recipient, uint256 amount) external onlyApprovedSource(source) onlyOperator {
        IERC20(source).transfer(recipient, amount);
    }

    function callDataOnSourceWithApprove(address source, address token, uint256 amount, bytes calldata data) external onlyApprovedSource(source) onlyOperator {
        IERC20(token).approve(source, amount);
        source.call(data);
    }

    function withdrawFromSourceWithIdentifier(address source, uint256 amount, uint256 sourceIdentifier) external onlyApprovedSource(source) onlyOperator {
        IMineSource(source).withdraw(amount, sourceIdentifier);
    }

    function depositIntoSourceWithIdentifier(address source, address token, uint256 amount, uint256 sourceIdentifier) external onlyApprovedSource(source) onlyOperator {
        IERC20(token).approve(source, amount);
        IMineSource(source).deposit(token, amount, sourceIdentifier);
    }

}