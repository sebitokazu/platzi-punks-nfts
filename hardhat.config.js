require("@nomiclabs/hardhat-waffle");
require("dotenv").config()



/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby:{
      url: `${process.env.INFURA_API_URL}`,
      accounts: [
        `${process.env.METAMASK_PRIVATE_KEY}`
      ]
    }
  }
};
