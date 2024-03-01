const MyToken = artifacts.require("MyToken");

module.exports = (deployer) => {
    deployer.deploy(MyToken, "StakingToken", "STT", 2001128);
};
