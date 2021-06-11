const Ribe = artifacts.require("Ribe");

const uniswapJson = require("@uniswap/v2-core/build/UniswapV2Factory.json");
const contract = require("@truffle/contract");
const UniSwap = contract(uniswapJson);
UniSwap.setProvider(this.web3._provider);

module.exports = async function (deployer, network, accounts) {
  // deploy uniswap
  const UniswapV2Factory = await deployer.deploy(UniSwap, accounts[0], {from : accounts[0]});
  
  // test prices: ETHER PRICE, TOKEN PRICE
  
  // deploy ETHER
  // TODO

  // deploy USDT
  // TODO
  
  // deploy TOKEN
  // TODO
  
  // create pairs
  
  // create ETHER - USDT pair
  // TODO
  
  // create ETHER - TOKEN pair
  // TODO

  // deploy liquidity value calculator
  // TODO

  // check prices

  // deploy riba dec port contract
  await deployer.deploy(Ribe);
  let tokenInstance = await Ribe.deployed();
};
