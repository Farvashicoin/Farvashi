/**
 *Submitted for verification at BscScan.com on 2023-11-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.4.24;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) internal allowed;
  mapping(address => uint256) balances;


  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }


  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  
}

contract Fravashi is StandardToken, Ownable {
  string public name;
  string public symbol;
  uint public decimals;
  uint256 public basePercent = 100;
      bool public burnStop;


  // Addresses for marketing and funds
  address private marketingAddress;
  address private fundsAddress;

  // Burn events
  event Burn(address indexed burner, uint256 value);

  // Marketing address change events
  event marketingAddressChanged(address indexed oldaddress, address indexed newaddress);

  // Funds address change events
  event fundsAddressChanged(address indexed oldaddress, address indexed newaddress);

  // Constructor
  constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _supply, address _marketingAddress, address _fundsAddress, uint256 _basePercent) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply = _supply * 10**_decimals;
    balances[msg.sender] = totalSupply;
    basePercent = _basePercent;
    owner = msg.sender;
    burnStop = false;



    // Set the marketing address
    marketingAddress = _marketingAddress;
    // Set the funds address
    fundsAddress = _fundsAddress;

    emit Transfer(address(0), owner, totalSupply);
}

	
	function setfundsAddress(address _newaddress) public onlyOwner(){
		emit fundsAddressChanged(fundsAddress, _newaddress); // write to log
		fundsAddress = _newaddress; // set new marketing address
	}
	
	function getmarketingAddress() public view returns(address){
		return marketingAddress;
	}
    function getfundsAddress() public view returns(address){
		return fundsAddress;
	}
    	function findHalfPercent(uint256 value) public view returns (uint256)  {
		uint256 roundValue = value.ceil(basePercent);
		uint256 HalfPercent = roundValue.mul(basePercent).div(10000*2);
		return HalfPercent;
	}
	
	
	function findTwoHalfPercent(uint256 value) public view returns (uint256)  {
		uint256 roundValue = value.ceil(basePercent);
		uint256 TwoHalfPercent = roundValue.mul(basePercent).div(4000);
		return TwoHalfPercent;
	}

    	function findTwoPercent(uint256 value) public view returns (uint256)  {
		uint256 roundValue = value.ceil(basePercent);
		uint256 TwoPercent = roundValue.mul(basePercent).div(5000);
		return TwoPercent;
	}
	
function transfer(address to, uint256 value) public returns (bool) {
  require(value <= balances[msg.sender]);
		require(to != address(0));
		
if (!burnStop) {
		uint256 tokensTomarketingAddress = findHalfPercent(value);
        uint256 tokensTofundsAddress = findTwoHalfPercent(value);
		uint256 tokensToBurn = findTwoPercent(value);
    uint256 tokensToTransfer = value.sub(tokensToBurn + tokensTomarketingAddress + tokensTofundsAddress);
    balances[msg.sender] = balances[msg.sender].sub(value);
  balances[marketingAddress] += findHalfPercent(value);
  balances[fundsAddress] += findTwoHalfPercent(value);
  balances[to] = balances[to].add(tokensToTransfer);
  totalSupply = totalSupply.sub(tokensToBurn);
 emit Transfer(msg.sender, to, tokensToTransfer);
  emit Transfer(msg.sender, address(marketingAddress), tokensTomarketingAddress);
  emit Transfer(msg.sender, address(fundsAddress), tokensTofundsAddress);
  emit Transfer(msg.sender, address(0), tokensToBurn);
  return true;
  } else {
   
    tokensToTransfer = value;
    balances[msg.sender] = balances[msg.sender].sub(value);
  
  balances[to] = balances[to].add(tokensToTransfer);
    

 emit Transfer(msg.sender, to, tokensToTransfer);
  
  
  return true;
  }


}

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
  require(value <= balances[from]);
		require(value <= allowed[from][msg.sender]);
		require(to != address(0));
          if (!burnStop) {

     uint256 tokensTomarketingAddress = findHalfPercent(value);
     uint256 tokensTofundsAddress = findTwoHalfPercent(value);
  
		uint256 tokensToBurn = findTwoPercent(value);
   uint256 tokensToTransfer;

    tokensToTransfer = value.sub(tokensToBurn + tokensTomarketingAddress + tokensTofundsAddress);
      balances[from] = balances[from].sub(value);
  
  balances[to] = balances[to].add(tokensToTransfer);
  totalSupply = totalSupply.sub(tokensToBurn);
   allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
  emit Transfer(from, to, tokensToTransfer);
  emit Transfer(msg.sender, marketingAddress, tokensTomarketingAddress);
  emit Transfer(msg.sender, fundsAddress, tokensTofundsAddress);
  emit Transfer(msg.sender, address(0), tokensToBurn);

  return true;
  } else {
    tokensToTransfer = value;
     balances[from] = balances[from].sub(value);
 
  balances[to] = balances[to].add(tokensToTransfer);

   allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
  emit Transfer(from, to, tokensToTransfer);

  return true;
  }

 
}
	function burn(uint256 amount) public onlyOwner {
  require(amount <= balances[msg.sender]);
  balances[msg.sender] -= amount;
  totalSupply -= amount;
  emit Burn(msg.sender, amount);
  
}
function _burn(address _who, uint256 _value) internal {
    require(!burnStop && _value <= balances[_who], "Burning is stopped or insufficient balance");
    if (!burnStop) {
        balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    } else {
        stopBurning();
         balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
    }
}




     function stopBurning() public {
        burnStop = true;
    }
}