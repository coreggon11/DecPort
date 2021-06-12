const Ribe = artifacts.require("Ribe");
const WETH = artifacts.require("WrappedEther");
const USDT = artifacts.require("USDTether");
const RANDOM = artifacts.require("RandomToken");

const LVC = artifacts.require("LiquidityValueCalculator");

const uniswapJson = require("@uniswap/v2-core/build/UniswapV2Factory.json");
const contract = require("@truffle/contract");
const UniSwap = contract(uniswapJson);
UniSwap.setProvider(this.web3._provider);

const uniswapRouterJson = require("@uniswap/v2-periphery/build/UniswapV2Router01.json");
const UniSwapRouter = contract(uniswapRouterJson);
UniSwapRouter.setProvider(this.web3._provider);

module.exports = async function (deployer, network, accounts) {
  // deploy uniswap
  await deployer.deploy(UniSwap, accounts[0], {from : accounts[0]});
  const uniswapV2Factory = await UniSwap.deployed();
  const factoryAddress = uniswapV2Factory['address'];

  // test prices: ETHER PRICE, TOKEN PRICE
  
  // deploy WETH
  await deployer.deploy(WETH);
  const wethToken = await WETH.deployed();
  const wethAddress = wethToken['address'];

  // deploy USDT
  await deployer.deploy(USDT);
  const usdtToken = await USDT.deployed();
  const usdtAddress = usdtToken['address'];
  
  // deploy TOKEN
  await deployer.deploy(RANDOM);
  const randomToken = await RANDOM.deployed();
  const randomAddress = randomToken['address'];
  
  // deploy liquidity value calculator
  await deployer.deploy(LVC, factoryAddress, wethAddress, usdtAddress);
  const liquidityValueCalculator = await LVC.deployed();

  // deploy router
  await deployer.deploy(UniSwapRouter, factoryAddress, wethAddress, {from : accounts[0]});
  const router = await UniSwapRouter.deployed();
  const routerAddress = router['address'];

  // create pairs
  
  // create ETHER - USDT pair
  const wethUsdtPair = await uniswapV2Factory.createPair(wethAddress, usdtAddress, {from : accounts[0]});
  const wethUsdtAddress = wethUsdtPair['logs'][0]['args']['pair']; 

  // approve weth
  await wethToken.approve(routerAddress, 10000, {from : accounts[0]});
  // approve usdt
  await usdtToken.approve(routerAddress, 25000000, {from : accounts[0]});

  // add liquidity
 await router.addLiquidity(wethAddress, 
    usdtAddress, 
    10000, 
    25000000,
    10000, 
    25000000, 
    accounts[0],
    Math.floor(Date.now() / 1000) + 25000, {from : accounts[0]});

  // get ether price
  const etherPrice = await liquidityValueCalculator.ethPrice();
  console.log(etherPrice);

  // create ETHER - TOKEN pair
  // TODO

  // add liquidity

  // check prices

  // deploy riba dec port contract
  await deployer.deploy(Ribe);
  let tokenInstance = await Ribe.deployed();
};
