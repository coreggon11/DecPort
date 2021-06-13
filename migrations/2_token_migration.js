const Ribe = artifacts.require("Ribe");
const WETH = artifacts.require("WrappedEther");
const USDT = artifacts.require("USDTether");
const RANDOM = artifacts.require("RandomToken");

const RibeUniSwapUtils = artifacts.require("RibeUniSwapUtils");

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
  
  // deploy Covid Token
  await deployer.deploy(RANDOM, "Covid-19", "C19");
  const covid19 = await RANDOM.deployed();
  const covid19Address = covid19['address'];
  
  // deploy Sars token
  await deployer.deploy(RANDOM, "Sars-CoV 2", "SARS2");
  const sars = await RANDOM.deployed();
  const sarsAddress = sars['address'];

  // deploy RibeUniSwapUtils
  await deployer.deploy(RibeUniSwapUtils, factoryAddress, wethAddress, usdtAddress);
  const ribeUniSwapUtils = await RibeUniSwapUtils.deployed();

  // deploy router
  await deployer.deploy(UniSwapRouter, factoryAddress, wethAddress, {from : accounts[0]});
  const router = await UniSwapRouter.deployed();
  const routerAddress = router['address'];

  // approve weth
  await wethToken.approve(routerAddress, 17500, {from : accounts[0]});
  // approve usdt
  await usdtToken.approve(routerAddress, 25000000, {from : accounts[0]});
  // approve covid
  await covid19.approve(routerAddress, 25000000, {from : accounts[0]});
  // approve sars
  await sars.approve(routerAddress, 25000000, {from : accounts[0]});

  // create pairs
  
  // create ETHER - USDT pair
  const wethUsdtPair = await uniswapV2Factory.createPair(wethAddress, usdtAddress, {from : accounts[0]});
  //const wethUsdtAddress = wethUsdtPair['logs'][0]['args']['pair']; 

  // add liquidity
 await router.addLiquidity(wethAddress, usdtAddress, 
    /* how much ether */10000, /* how much usdt */ 25000000, /* how much ether min */ 10000, /* how much usdt min */ 25000000, 
    accounts[0], /* wait max 30 min */ Math.floor(Date.now() / 1000) + 1800, {from : accounts[0]});

  // create ETHER - TOKEN pair
  const wethCoivdPair = await uniswapV2Factory.createPair(wethAddress, covid19Address, {from : accounts[0]});
  //const wethRandomAddress = wethRandomPair['logs'][0]['args']['pair']; 

  // add liquidity
  await router.addLiquidity(wethAddress, covid19Address, 
    /* how much ether */5000, /* how much random */ 25000000, /* how much ether min */ 5000, /* how much usdt min */ 25000000, 
    accounts[0], /* wait max 30 min */ Math.floor(Date.now() / 1000) + 1800, {from : accounts[0]});

  // create ETHER - TOKEN pair
  const wethSarsPair = await uniswapV2Factory.createPair(wethAddress, sarsAddress, {from : accounts[0]});

  // add liquidity
  await router.addLiquidity(wethAddress, sarsAddress, 
    /* how much ether */2500, /* how much random */ 25000000, /* how much ether min */ 5000, /* how much usdt min */ 25000000, 
    accounts[0], /* wait max 30 min */ Math.floor(Date.now() / 1000) + 1800, {from : accounts[0]});

  // check prices
  // get ether price
  const etherPrice = await ribeUniSwapUtils.ethPrice();
  console.log(etherPrice / 10000);
  // token price 
  const tokenPriceEther = await ribeUniSwapUtils.tokenPriceInEther(covid19Address, {from : accounts[0]});
  console.log(tokenPriceEther / 1000000000000000000);
  // token price usdt
  const tokenPriceUsdt = await ribeUniSwapUtils.tokenPriceInUsdt(covid19Address, {from : accounts[0]});
  console.log(tokenPriceUsdt / 10000000000000000000000);

  console.log("account 0: " + accounts[0]);
  console.log("account 1: " + accounts[1]);

  // deploy riba dec port contract
  await deployer.deploy(Ribe);
  const ribe = await Ribe.deployed();

  const addresses = [wethAddress, covid19Address, sarsAddress];
  const shares = [4000, 2000, 2000];
  // create portfolio with WETH, Sars and Covid token
  // public dynamic
  await ribe.createPortfolio(true, false, addresses, shares, {from : accounts[0]});
  const portfolioCount = await ribe.getPortfolioCount();
  console.log(portfolioCount / 1);
  // TODO invest USDT portfolio
  // TODO not owner invest in portfolio
  
  // TODO public static
  //ribe.createPortfolio(bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_)
  // TODO invest USDT portfolio
  // TODO not owner invest in portfolio

  // TODO private dynamic
  //ribe.createPortfolio(bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_)
  // TODO invest USDT portfolio
  // TODO not owner invest in portfolio

  // TODO private static
  //ribe.createPortfolio(bool isPublic_, bool isDynamic_, address[] memory addresses_, uint16[] memory shares_)
  // TODO invest USDT portfolio
  // TODO not owner invest in portfolio
};
