pragma solidity ^0.4.16;

import '../installed_contracts/zeppelin/contracts/token/MintableToken.sol';

contract ChangeCoin is MintableToken {
  string public name = "Change COIN";
  string public symbol = "CAG";
  uint256 public decimals = 18;

  bool public tradingStarted = false;

  /**
   * @dev modifier that throws if trading has not started yet
   */
  modifier hasStartedTrading() {
    require(tradingStarted);
    _;
  }

  /**
   * @dev Allows the owner to enable the trading. This can not be undone
   */
  function startTrading() onlyOwner {
    tradingStarted = true;
  }


  /**
   * @dev Allows anyone to transfer the Change tokens once trading has started
   * @param _to the recipient address of the tokens.
   * @param _value number of tokens to be transfered.
   */
  function transfer(address _to, uint _value) hasStartedTrading returns (bool){
    return super.transfer(_to, _value);
  }

  /**
   * @dev Allows anyone to transfer the Change tokens once trading has started
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) hasStartedTrading returns (bool){
    return super.transferFrom(_from, _to, _value);
  }
}
