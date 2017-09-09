pragma solidity ^0.4.16;

import './ChangeCoin.sol';
import '../installed_contracts/zeppelin/contracts/ownership/Ownable.sol';
import '../installed_contracts/zeppelin/contracts/math/SafeMath.sol';

contract ChangeCoinCrowdsale is Ownable {
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

  uint256 public minContribution;

  uint256 public hardcap;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event MainSaleClosed();

  uint256 public raisedInPresale = 0 ether;

  function ChangeCoinCrowdsale() {
    startTimestamp = 0;
    endTimestamp = 0;
    rate = 500;
    hardwareWallet = 0x0;
    token = ChangeCoin(0x0);

    minContribution = 0.5 ether;
    hardcap = 200000 ether;

    require(startTimestamp >= now);
    require(endTimestamp >= startTimestamp);
  }

  /**
   * @dev Calculates the amount of bonus coins the buyer gets
   * @param tokens uint the amount of tokens you get according to current rate
   * @return uint the amount of bonus tokens the buyer gets
   */
  function bonusAmmount(uint256 tokens) internal returns(uint256) {
    uint256 bonus5 = tokens /20;
    // add bonus 20% in first 24hours, 15% in first week, 10% in 2nd week
    if (now < startTimestamp + 1 days) { // 5080 is aprox 24h
      return bonus5 * 4;
    } else if (now < startTimestamp + 1 weeks) {
      return bonus5 * 3;
    } else if (now < startTimestamp + 2 weeks) {
      return bonus5 * 2;
    } else {
      return 0;
    }
  }

  // check if valid purchase
  modifier validPurchase {
    require(now >= startTimestamp);
    require(now <= endTimestamp);
    require(msg.value >= minContribution);
    require(weiRaised.add(msg.value).add(raisedInPresale) <= hardcap);
    _;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool timeLimitReached = now > endTimestamp;
    bool capReached = weiRaised.add(raisedInPresale) >= hardcap;
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

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    hardwareWallet.transfer(msg.value);
  }

  // finish mining coins and transfer ownership of Change coin to owner
  function finishMinting() public onlyOwner {
    require(hasEnded());
    uint issuedTokenSupply = token.totalSupply();
    uint restrictedTokens = issuedTokenSupply.mul(60).div(40);
    token.mint(hardwareWallet, restrictedTokens);
    token.finishMinting();
    token.transferOwnership(owner);
    MainSaleClosed();
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

}
