/*
   KUPINET DEX              Source code available under GPLv2 license
                          2018  Kupi.net

   KUPINET  is a new generation of decentralized exchanges based on
   state storage, not logs (events). It is designed to be used both
   with or without a frontend. A DAPP connected to KUPINET contract
   will receive 30% share of trade fee. To have it, just pass the
   refund address as the last argument to buy() and sell() methods.
   Trading without a frontend gives you 30% descount.
   KUPINET is recommended to be used with Parity Wallet.


   WANT TO TRADE ON KUPINET? READ THE DOCS:
   https://github.com/kupinet/our-smart-contract


KUPINET CONTRACT ABI:
[{"constant":false,"inputs":[{"name":"amount","type":"uint256"},{"name":"token","type":"address"},{"name":"price_each","type":"uint256"},{"name":"bid_order_spot","type":"uint256"}],"name":"willbuy","outputs":[{"name":"","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"updateAvailable","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"token","type":"address"},{"name":"min_trade_amount","type":"uint256"}],"name":"findBestBid","outputs":[{"name":"bid_order","type":"uint256"},{"name":"volume","type":"uint256"},{"name":"price","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"token","type":"address"},{"name":"user","type":"address"}],"name":"balanceApprovedForToken","outputs":[{"name":"amount","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"user","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"token","type":"address"},{"name":"ask_order","type":"uint256"}],"name":"willsellInfo","outputs":[{"name":"user","type":"address"},{"name":"price","type":"uint256"},{"name":"amount","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"},{"name":"token","type":"address"},{"name":"min_price_each","type":"uint256"},{"name":"bid_orders","type":"uint256[]"},{"name":"rebate_address","type":"address"}],"name":"sellAll","outputs":[{"name":"new_bid_order_amount","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"},{"name":"token","type":"address"},{"name":"min_price_each","type":"uint256"},{"name":"bid_order","type":"uint256"},{"name":"rebate_address","type":"address"}],"name":"sell","outputs":[{"name":"fact_amount","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"token","type":"address"},{"name":"min_trade_amount","type":"uint256"}],"name":"findBestAsk","outputs":[{"name":"ask_order","type":"uint256"},{"name":"volume","type":"uint256"},{"name":"price","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"},{"name":"token","type":"address"},{"name":"price_each","type":"uint256"},{"name":"ask_order_spot","type":"uint256"}],"name":"willsell","outputs":[{"name":"","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"},{"name":"token","type":"address"},{"name":"max_price_each","type":"uint256"},{"name":"ask_orders","type":"uint256[]"},{"name":"rebate_address","type":"address"}],"name":"buyAll","outputs":[{"name":"amount_left","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"token","type":"address"},{"name":"bid_order","type":"uint256"}],"name":"willbuyInfo","outputs":[{"name":"user","type":"address"},{"name":"price","type":"uint256"},{"name":"amount","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"deposit","outputs":[{"name":"","type":"bool"}],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"token","type":"address"}],"name":"willsellFindSpot","outputs":[{"name":"ask_order_spot","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"token","type":"address"}],"name":"willbuyFindSpot","outputs":[{"name":"bid_order_spot","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"amount","type":"uint256"},{"name":"token","type":"address"},{"name":"max_price_each","type":"uint256"},{"name":"ask_order","type":"uint256"},{"name":"rebate_address","type":"address"}],"name":"buy","outputs":[{"name":"fact_amount","type":"uint256"}],"payable":true,"stateMutability":"payable","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"amount","type":"uint256"},{"indexed":false,"name":"token","type":"address"},{"indexed":false,"name":"price_each","type":"uint256"},{"indexed":false,"name":"buyer","type":"address"},{"indexed":false,"name":"seller","type":"address"}],"name":"Trade","type":"event"}]


*/
pragma solidity ^0.4.19;
contract Kupinet {

  address private ceo;
  address private admin;
  address public updateAvailable;
  mapping (address => mapping (uint256 => address)) private willsellUser;
  mapping (address => mapping (uint256 => uint256)) private willsellPrice;
  mapping (address => mapping (uint256 => uint256)) private willsellAmount;
  mapping (address => mapping (uint256 => address)) private willbuyUser;
  mapping (address => mapping (uint256 => uint256)) private willbuyPrice;
  mapping (address => mapping (uint256 => uint256)) private willbuyAmount;
  event Trade(uint256 amount, address token, uint256 price_each, address buyer, address seller);


  function Kupinet() public {
    admin = msg.sender;
    ceo = msg.sender;
  }
  function() public payable {
    if (updateAvailable != 0) revert();
    funds[msg.sender] += msg.value;
  }
  function deposit() public payable returns (bool) {
    if (updateAvailable != 0) revert();
    funds[msg.sender] += msg.value;
    return true;
  }


  function buy(uint256 amount, address token, uint256 max_price_each, uint256 ask_order, address rebate_address) public payable returns (uint256 fact_amount) {
    if (msg.value != 0) funds[msg.sender] += msg.value;
    if ((willsellPrice[token][ask_order] > max_price_each && max_price_each != 0)
      || amount == 0
      || token == 0
      || token == address(this)
      || ask_order == 0
      || funds[msg.sender] <= 1e15
    ) revert();
    address buyer = msg.sender;
    address seller = willsellUser[token][ask_order];
    // Cancel your own order
    if (buyer == seller) {
      if (amount >= willsellAmount[token][ask_order]) {
        willsellAmount[token][ask_order] = 0;
        return amount;
      }
      willsellAmount[token][ask_order] -= amount;
      return amount;
    }
    // Validate amount
    uint256 volume = willsellVolume(token, ask_order);
    if (amount > volume) {
      if (volume == 0) {
        willsellAmount[token][ask_order] = 0;
        return 0;
      }
      amount = volume;
    }
    uint256 pay = willsellPrice[token][ask_order] * amount / 1e18;
    // Buyer pays the fee
    uint256 fee;
    if (pay > 1e16 && traded[msg.sender]) {
      if (rebate_address == 0 || rebate_address == msg.sender) {
        fee = 7e14;
      }
      else fee = 1e15;
    } // else fee = 0
    // Validate payout
    if (pay + fee > funds[msg.sender]) {
      pay = funds[msg.sender] - fee;
      amount = pay * 1e18 / willsellPrice[token][ask_order];
    }
    // Trade
    if (!Kupinet(token).transferFrom(seller, buyer, amount)) return 0;
    funds[seller] = funds[seller] + pay;
    funds[buyer] = funds[buyer] - pay - fee;
    funds[ceo] = funds[ceo] + fee;
    if (fee == 1e15) funds[rebate_address] = funds[rebate_address] + 3e14;
    if (traded[msg.sender] == false) {
      traded[msg.sender] = true;
    }
    // Drop uncovered order
    if (amount == volume) {
      willsellAmount[token][ask_order] = 0;
    }
    else willsellAmount[token][ask_order] -= amount;
    Trade(amount, token, willsellPrice[token][ask_order], buyer, seller);
    return amount;
  }


  function sell(uint256 amount, address token, uint256 min_price_each, uint256 bid_order, address rebate_address) public payable returns (uint256 fact_amount) {
    if (msg.value != 0) funds[msg.sender] += msg.value;
    if (willbuyPrice[token][bid_order] < min_price_each
      || amount == 0
      || token == 0
      || token == address(this)
      || bid_order == 0
    ) revert();
    address buyer = willbuyUser[token][bid_order];
    address seller = msg.sender;
    // Cancel your own order
    if (buyer == seller) {
      if (amount >= willbuyAmount[token][bid_order]) {
        willbuyAmount[token][bid_order] = 0;
        return amount;
      }
      willbuyAmount[token][bid_order] -= amount;
      return amount;
    }
    // Validate amount
    uint256 volume = willbuyVolume(token, bid_order);
    if (amount > volume) {
      if (volume == 0) {
        willbuyAmount[token][bid_order] = 0;
        return 0;
      }
      amount = volume;
    }
    uint256 pay = willbuyPrice[token][bid_order] * amount / 1e18;
    // Seller pays the fee
    uint256 fee;
    if (pay > 1e16 && traded[msg.sender]) {
      if (rebate_address == 0 || rebate_address == msg.sender) {
        fee = 7e14;
      }
      else fee = 1e15;
    } // else fee = 0
    // Trade
    if (!Kupinet(token).transferFrom(seller, buyer, amount)) return 0;
    funds[buyer] = funds[buyer] - pay;
    funds[seller] = funds[seller] + pay - fee;
    funds[ceo] = funds[ceo] + fee;
    if (fee == 1e15) funds[rebate_address] = funds[rebate_address] + 3e14;
    if (traded[msg.sender] == false) {
      traded[msg.sender] = true;
    }
    // Drop uncovered order
    if (amount == volume) {
      willbuyAmount[token][bid_order] = 0;
    }
    else willbuyAmount[token][bid_order] -= amount;
    Trade(amount, token, willbuyPrice[token][bid_order], buyer, seller);
    return amount;
  }


  function willbuy(uint256 amount, address token, uint256 price_each, uint256 bid_order_spot) public payable returns (bool) {
    if (msg.value != 0) funds[msg.sender] += msg.value;
    if (updateAvailable != 0
      || token == 0
      || token == address(this)
      || price_each == 0
      || bid_order_spot == 0
    ) revert();
    while (willbuyAmount[token][bid_order_spot] != 0 && funds[willbuyUser[token][bid_order_spot]] != 0 && willbuyUser[token][bid_order_spot] != msg.sender) ++bid_order_spot;
    if (willbuyUser[token][bid_order_spot] != msg.sender) willbuyUser[token][bid_order_spot] = msg.sender;
    if (willbuyPrice[token][bid_order_spot] != price_each) willbuyPrice[token][bid_order_spot] = price_each;
    if (willbuyAmount[token][bid_order_spot] != amount) willbuyAmount[token][bid_order_spot] = amount;
    return true;
  }

  function willsell(uint256 amount, address token, uint256 price_each, uint256 ask_order_spot) public payable returns (bool) {
    if (msg.value != 0) funds[msg.sender] += msg.value;
    if (updateAvailable != 0
      || token == 0
      || token == address(this)
      || price_each == 0
      || ask_order_spot == 0
    ) revert();
    while (willsellAmount[token][ask_order_spot] != 0 && willsellUser[token][ask_order_spot] != msg.sender) {
      address user = willsellUser[token][ask_order_spot];
      uint256 balanceSeller = Kupinet(token).balanceOf(user);
      if (balanceSeller == 0) break;
      uint256 allowanceSeller = Kupinet(token).allowance(user, address(this));
      if (allowanceSeller == 0) break;
      ++ask_order_spot;
    }
    if (willsellUser[token][ask_order_spot] != msg.sender) willsellUser[token][ask_order_spot] = msg.sender;
    if (willsellPrice[token][ask_order_spot] != price_each) willsellPrice[token][ask_order_spot] = price_each;
    if (willsellAmount[token][ask_order_spot] != amount) willsellAmount[token][ask_order_spot] = amount;
    return true;
  }
  function withdraw(uint256 amount) public {
    if (funds[msg.sender] < amount || amount == 0) amount = funds[msg.sender];
    funds[msg.sender] -= amount;
    msg.sender.transfer(amount);
  }


  function buyAll(uint256 amount, address token, uint256 max_price_each, uint256[] ask_orders, address rebate_address) public payable returns (uint256 amount_left) {
    uint256 i;
    while (amount > 0 || i < ask_orders.length) {
      uint256 ask_order = ask_orders[i];
      uint256 a = willsellAmount[token][ask_order];
      if (a > amount) a = amount;
      uint256 fact_amount = buy(a, token, max_price_each, ask_order, rebate_address);
      amount -= fact_amount;
      ++i;
    }
    return amount;
  }
  function sellAll(uint256 amount, address token, uint256 min_price_each, uint256[] bid_orders, address rebate_address) public payable returns (uint256 new_bid_order_amount) {
    uint256 i;
    while (amount > 0 || i < bid_orders.length) {
      uint256 ask_order = bid_orders[i];
      uint256 a = willbuyAmount[token][ask_order];
      if (a > amount) a = amount;
      uint256 fact_amount = buy(a, token, min_price_each, ask_order, rebate_address);
      amount -= fact_amount;
      ++i;
    }
    return amount;
  }


// Constant methods below

  function name() constant public returns (string) {
    if (updateAvailable != 0) return "KUPINET DEX (deactivated)";
    return "KUPINET DEX";
  }
  function balanceOf(address user)
  constant public returns (uint256 balance) {
    return funds[user];
  }
  function balanceApprovedForToken(address token, address user)
  constant public returns (uint256 amount) {
    if (token == 0 || token == address(this)) return funds[user];
    amount = Kupinet(token).balanceOf(user);
    uint256 allowance = Kupinet(token).allowance(user, address(this));
    if (amount > allowance) amount = allowance;
    return amount;
  }


  function findBestAsk(address token, uint256 min_trade_amount) public
  constant returns (uint256 ask_order, uint256 volume, uint256 price) {
    price = (uint256)(-1);
    uint256 i=1;
    while (willsellUser[token][i] != 0) {
      if (willsellPrice[token][i] < price && willsellAmount[token][i] != 0) {
        volume = willsellVolume(token, i);
        if (volume >= min_trade_amount && volume != 0) {
          price = willsellPrice[token][i];
          ask_order = i;
        }
      }
      ++i;
    }
    if (ask_order == 0) return (0,0,0);
    return;
  }
  function findBestBid(address token, uint256 min_trade_amount) public
  constant returns (uint256 bid_order, uint256 volume, uint256 price) {
    uint256 i=1;
    while (willbuyUser[token][i] != 0) {
      if (willbuyPrice[token][i] > price && willbuyAmount[token][i] != 0) {
        volume = willbuyVolume(token, i);
        if (volume >= min_trade_amount && volume != 0) {
          price = willbuyPrice[token][i];
          bid_order = i;
        }
      }
      ++i;
    }
    if (bid_order == 0) return (0,0,0);
    return;
  }

  function willbuyFindSpot(address token) public
  constant returns (uint256 bid_order_spot) {
    // is ERC20?
    Kupinet(token).symbol();
    uint256 i=1;
    while (willbuyAmount[token][i] != 0 && funds[willbuyUser[token][i]] != 0) ++i;
    return i;
  }
  function willsellFindSpot(address token) public
  constant returns (uint256 ask_order_spot) {
    // is ERC20?
    Kupinet(token).symbol();
    uint256 i=1;
    while (willsellAmount[token][i] != 0) {
      uint256 balanceSeller = Kupinet(token).balanceOf(willsellUser[token][i]);
      if (balanceSeller == 0) return i;
      uint256 allowanceSeller = Kupinet(token).allowance(willsellUser[token][i], address(this));
      if (allowanceSeller == 0) return i;
      ++i;
    }
    return i;
  }


// Get info on orders

  function willbuyInfo(address token, uint256 bid_order) public
  constant returns (address user, uint256 price, uint256 amount) {
    user = willbuyUser[token][bid_order];
    price = willbuyPrice[token][bid_order];
    amount = willbuyAmount[token][bid_order];
    uint256 pay = price * amount / 1e18;
    if (pay > funds[user]) {
      pay = funds[user];
      amount = pay * 1e18 / price;
    }
    return;
  }
  function willbuyVolume(address token, uint256 bid_order) private
  constant returns (uint256) {
    uint256 amount = willbuyAmount[token][bid_order];
    address user = willbuyUser[token][bid_order];
    if (amount == 0 || funds[user] == 0) return 0;
    uint256 price = willbuyPrice[token][bid_order];
    uint256 pay = price * amount / 1e18;
    if (pay > funds[user]) {
      pay = funds[user];
      amount = pay * 1e18 / price;
    }
    return amount;
  }

  function willsellInfo(address token, uint256 ask_order) public
  constant returns (address user, uint256 price, uint256 amount) {
    user = willsellUser[token][ask_order];
    price = willsellPrice[token][ask_order];
    amount = willsellAmount[token][ask_order];
    uint256 balanceSeller = Kupinet(token).balanceOf(user);
    uint256 allowanceSeller = Kupinet(token).allowance(user, address(this));
    if (balanceSeller > allowanceSeller) balanceSeller = allowanceSeller;
    if (amount > balanceSeller) amount = balanceSeller;
    return;
  }
  function willsellVolume(address token, uint256 ask_order) private
  constant returns (uint256) {
    uint256 amount = willsellAmount[token][ask_order];
    if (amount == 0) return 0;
    address user = willsellUser[token][ask_order];
    uint256 balanceSeller = Kupinet(token).balanceOf(user);
    if (balanceSeller == 0) return 0;
    uint256 allowanceSeller = Kupinet(token).allowance(user, address(this));
    if (allowanceSeller == 0) return 0;
    if (balanceSeller > allowanceSeller) balanceSeller = allowanceSeller;
    if (amount > balanceSeller) amount = balanceSeller;
    return amount;
  }


// KUPINET ether pegged token
// Used to conveniently show user deposit in wallets

  function symbol() constant public returns (string) {
    if (updateAvailable != 0) return "exKUPINET";
    return "KUPINET";
  }
  function decimals() constant public returns (uint256) {
    return 18;
  }
  function totalSupply() constant public returns (uint256 supply) {
    return this.balance;
  }
  function transfer(address _to, uint256 _value) public returns (bool success) {
    if (_value > funds[msg.sender]) _value = funds[msg.sender];
    funds[msg.sender] -= _value;
    funds[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    if (_value > funds[msg.sender]) _value = funds[msg.sender];
    if (_value > approved[_from][msg.sender]) _value = approved[_from][msg.sender];
    funds[_from] -= _value;
    funds[_to] += _value;
    approved[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool success) {
    if (_spender == address(this)) return true;
    approved[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    if (_spender == address(this)) return balanceOf(_owner);
    return approved[_owner][_spender];
  }
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  mapping (address => mapping (address => uint256)) private approved;
  mapping (address => uint256) private funds;
  mapping (address => bool) private traded;


//  Admin methods
//  DO NOT EVER TRANSFER TOKENS TO KUPINET OR YOU'LL BE BANNED FROM ETHEREUM

  function refundLostToken(address token, address user) public {
    if (msg.sender != admin && msg.sender != ceo) return;
    uint256 amount = Kupinet(token).balanceOf(address(this));
    Kupinet(token).transfer(user, amount);
  }
  function rollUpdate(address _updateAvailable) public {
    if (msg.sender == admin || msg.sender == ceo) updateAvailable = _updateAvailable;
  }
  function assignCEO(address _ceo) public {
    if (msg.sender == admin) {
      ceo = _ceo;
    }
    else if (msg.sender == ceo) {
      admin = ceo;
      ceo = _ceo;
    }
  }

  function suicide() public {
    // TODO: can suicide after half year since rolling an update
    //      remove ceo fee
  }



}



contract Token1 {
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    uint256 constant MAX_UINT256 = 2**256 - 1;
    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 totalSupply;
    function Token1() public {
        balances[msg.sender] = 1000000;
        totalSupply = 1000000;
        name = "TOKEN1";
        decimals = 18;
        symbol = "TN1";
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender)
    constant public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    function mint(uint256 _value, address _to) {
        balances[_to] += _value;
        totalSupply += _value;
    }
}
