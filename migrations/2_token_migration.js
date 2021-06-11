const Ribe = artifacts.require("Ribe");

module.exports = async function (deployer) {
  // create shiba treat token
  await deployer.deploy(Ribe);
  let tokenInstance = await Ribe.deployed();
};
