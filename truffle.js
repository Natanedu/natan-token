/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: "*", // Match any network id
      from:"0xd04a4314b46ac2e2f27fda6efc69da629b5621d1" 
    },
    UnitTest: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" //Match any network id
    },
    rinkeby: {
      host: "192.168.0.104", // Connect to geth on the specified
      port: 8545,
      from: "0x80f793d184055b6d156530d36d5043a20f9805d3", // default address to use for any transaction Truffle makes during migrations
      network_id: '*',
      gas: 4612388 // Gas limit used for deploys
    }
  },
    solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};