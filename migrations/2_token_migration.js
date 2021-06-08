const DecPort = artifacts.require("DecPort");

module.exports = async function (deployer) {
  // create shiba treat token
  await deployer.deploy(DecPort);
  let tokenInstance = await DecPort.deployed();
};
