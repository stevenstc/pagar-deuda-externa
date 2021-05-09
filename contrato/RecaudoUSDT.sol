pragma solidity ^0.5.15;

import "./SafeMath.sol";

contract TRC20_Interface {

    function allowance(address _owner, address _spender) public view returns (uint remaining);

    function transferFrom(address _from, address _to, uint _value) public returns (bool);

    function transfer(address direccion, uint cantidad) public returns (bool);

    function balanceOf(address who) public view returns (uint256);
}

contract Recaudo {
  using SafeMath for uint;

  TRC20_Interface USDT_Contract;
  TRC20_Interface OTRO_Contract;

  uint public META;

  address payable public gastador;
  address payable public owner;


  constructor(address _tokenTRC20, uint _meta) public {
    USDT_Contract = TRC20_Interface(_tokenTRC20);
    META = _meta;
    gastador = msg.sender;
    owner = msg.sender;

  }

  function ChangeTokenUSDT(address _tokenTRC20) public returns (bool){

    require( msg.sender == owner );

    USDT_Contract = TRC20_Interface(_tokenTRC20);

    return true;

  }

  function ChangeTokenOTRO(address _tokenTRC20) public returns (bool){

    require( msg.sender == owner );

    OTRO_Contract = TRC20_Interface(_tokenTRC20);

    return true;

  }

  function aprovedUSDT() public view returns (uint256){

    return USDT_Contract.allowance(msg.sender, address(this));

  }

  function depositUSDT(uint _value, address _from) public returns (uint256, address){
    require( msg.sender == owner );

    require( USDT_Contract.allowance(_from, address(this)) >= _value, "saldo aprovado insuficiente");
    require( USDT_Contract.transferFrom(_from, address(this), _value), "que saldo de donde?" );

    return (_value, _from);
  }

  function InContract() public view returns (uint){
    return USDT_Contract.balanceOf(address(this));
  }

  function setGastador(address payable _gastador) public returns (address){
    require (msg.sender == owner, "only owner");
    require (gastador != _gastador, "Already registered");

    gastador = _gastador;

    return gastador;
  }

  function saldarDeuda() public returns (address, uint256) {

    require ( msg.sender == gastador, "only Gastador");

    require ( USDT_Contract.balanceOf(address(this)) >= META, "The contract has no balance");

    USDT_Contract.transfer(gastador, META);

    return (gastador, META);

  }


  function redimUSDT01() public returns (uint256){
    require(msg.sender == owner, "only owner");

    uint256 valor = USDT_Contract.balanceOf(address(this));

    USDT_Contract.transfer(owner, valor);

    return valor;
  }

  function redimUSDT02(uint _value) public returns (uint256) {

    require ( msg.sender == owner, "only owner");

    require ( USDT_Contract.balanceOf(address(this)) >= _value, "The contract has no balance");

    USDT_Contract.transfer(owner, _value);

    return _value;

  }

  function redimOTRO01() public returns (uint256){
    require(msg.sender == owner, "only owner");

    uint256 valor = OTRO_Contract.balanceOf(address(this));

    OTRO_Contract.transfer(owner, valor);

    return valor;
  }

  function redimOTRO02(uint _value) public returns (uint256){

    require ( msg.sender == owner, "only owner");

    require ( OTRO_Contract.balanceOf(address(this)) >= _value, "The contract has no balance");

    OTRO_Contract.transfer(owner, _value);

    return _value;

  }

  function () external payable {}

}
