const HDWalletProvider = require("truffle-hdwallet-provider");
const fs = require('fs');
const MNEMONIC = fs.readFileSync("./temp/mnemonic.secret").toString().trim();

module.exports = {

    networks: {

        //dev
        dev: {
            provider: function () {
                return new HDWalletProvider(MNEMONIC, "http://127.0.0.1:7545")
            },
            network_id: 5777,
            gas: 6660000
        },

        //bsc-test
        bsc: {
            provider: function () {
                return new HDWalletProvider(MNEMONIC, "https://data-seed-prebsc-1-s1.binance.org:8545/")
            },
            network_id: 97,
            gas: 9990000
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.6.12",
            docker: false,
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    },

};
