pragma solidity ^0.4.16;

import './ChangeCoin.sol';
import '../installed_contracts/zeppelin/contracts/ownership/Ownable.sol';
import '../installed_contracts/zeppelin/contracts/math/SafeMath.sol';

contract ChangeCoinPresale is Ownable {
  using SafeMath for uint256;

  // The token being sold
  ChangeCoin public token;

  // start and end block where investments are allowed (both inclusive)
  uint256 public startTimestamp;
  uint256 public endTimestamp;

  // address where funds are collected
  address public hardwareWallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  // minimum contributio to participate in tokensale
  uint256 public minContribution;

  // maximum amount of ether being raised
  uint256 public hardcap;

  // number of participants in presale
  uint256 public numberOfPurchasers = 0;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event PreSaleClosed();

  function ChangeCoinPresale() {
    startTimestamp = 0;
    endTimestamp = 0;
    rate = 500;
    hardwareWallet = 0X0;
    token = new ChangeCoin();
    minContribution = 9.9 ether;
    hardcap = 50000 ether;

    require(startTimestamp >= now);
    require(endTimestamp >= startTimestamp);
  }

  /**
   * @dev Calculates the amount of bonus coins the buyer gets
   * @param tokens uint the amount of tokens you get according to current rate
   * @return uint the amount of bonus tokens the buyer gets
   */
  function bonusAmmount(uint256 tokens) internal returns(uint256) {
    // first 500 get extra 30%
    if (numberOfPurchasers < 501) {
      return tokens * 3 / 10;
    } else {
      return tokens /4;
    }
  }

  // check if valid purchase
  modifier validPurchase {
    require(now >= startTimestamp);
    require(now <= endTimestamp);
    require(msg.value >= minContribution);
    require(weiRaised.add(msg.value) <= hardcap);
    _;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool timeLimitReached = now > endTimestamp;
    bool capReached = weiRaised >= hardcap;
    return timeLimitReached || capReached;
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable validPurchase {
    require(beneficiary != 0x0);

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);
    tokens = tokens + bonusAmmount(tokens);

    // update state
    weiRaised = weiRaised.add(weiAmount);
    numberOfPurchasers = numberOfPurchasers + 1;

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    hardwareWallet.transfer(msg.value);
  }

  // transfer ownership of the token to the owner of the presale contract
  function finishPresale() public onlyOwner {
    require(hasEnded());
    token.transferOwnership(owner);
    PreSaleClosed();
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

}
