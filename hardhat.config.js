require("@nomiclabs/hardhat-waffle")

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          evmVersion: "istanbul",
        },
      },
    ],
    overrides: {
      "contracts/helper/PoseidonT3.sol": {
        version: "0.8.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 9999,
          },
          evmVersion: "istanbul",
        },
      },
    },
  },
}
