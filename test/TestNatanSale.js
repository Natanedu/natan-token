const NatanSale = artifacts.require("natanCrowdsale");
var BigNumber = require('bignumber.js')

const logTitle = function (title) {
  console.log("*****************************************");
  console.log(title);
  console.log("*****************************************");
}

const logError = function (err) {
  console.log("-----------------------------------------");
  console.log(err);
  console.log("-----------------------------------------");
}

const timeTravel = function(time){
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], //86400 is num seconds in day
      id: new Date().getSeconds()
    }, (err, result) => {
      if(err) {
        return reject(err);
      }
      return resolve(result);
    });
  });
}

const mineBlock = function () {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_mine",
      params: [], 
      id: new Date().getSeconds()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}

contract('NatanSale', function(accounts) {

  const DECIMALSFACTOR = 1000000000000000000;
  const openingTime = new Date(1531699200); // 16 july 2018 01:00:00
  const endingTime = new Date(1563235200);  // 16 july 2019 01:00:00
  const MINIMAL_PURCHASE = 100 * DECIMALSFACTOR;
  const MAXIMUM_PURCHASE = 500 * DECIMALSFACTOR;
  let natanSale;
  let rate = 0;

  before(async() => {
    owner = accounts[0];
    wallet = accounts[1];
    natanSale = await NatanSale.new(openingTime.getTime(), endingTime.getTime(), wallet, {from: owner});
  });

  describe("Token Sale Rate", async () => {

    it("Rate", async function () {
      natanSale.getRate().then(res => {
        rate = res.toNumber();
        let now = new Date().getTime();
        let date = new Date();
        
        if(now <= date.setDate(openingTime.getDate() + 4)) {
          assert.equal(rate,10000*DECIMALSFACTOR);
        }
        else if((now >= date.setDate(openingTime.getDate() + 7)) && (now <= date.setDate(openingTime.getDate() + 11))) {
          assert.equal(rate,5000*DECIMALSFACTOR);
        }
        else if((now >= date.setDate(openingTime.getDate() + 14)) && (now <= date.setDate(openingTime.getDate() + 17))) {
          assert.equal(rate,3000*DECIMALSFACTOR);
        }
        else if((now >= date.setDate(openingTime.getDate() + 32)) && (now <= date.setDate(openingTime.getDate() + 35))) {
          assert.equal(rate,1000*DECIMALSFACTOR);
        }
        else {
          assert.equal(rate,500*DECIMALSFACTOR);
        }
      });
    });

  });

  describe("Buy tokens", async () => {

    it("invalid beneficiary should Fail to buy tokens", async () => {
      try {
        await natanSale.buyTokens(0, 100);
      } catch (error) {
          //logError(" Beneficiary with address 0x0 tried to buy tokens and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });
    
    it("beneficiary should Fail to buy amout of tokens inferior to the MINIMAL_PURCHASE", async () => {
      try {
        await natanSale.buyTokens(accounts[2], MINIMAL_PURCHASE-10);
      } catch (error) {
        //logError(" Beneficiary tried to buy amount tokens < minimal purchase");
        return true;
      }
      throw new Error("I should never see this!");
    });

    it("beneficiary should Fail to buy amout of tokens superior to the MAXIMUM_PURCHASE", async () => {
      try {
        await natanSale.buyTokens(accounts[2], MAXIMUM_PURCHASE+10);
      } catch (error) {
        //logError(" Beneficiary tried to buy amount tokens > minimal purchase");
        return true;
      }
      throw new Error("I should never see this!");
    });

    it("buy tokens", async () => {
      await natanSale.buyTokens(accounts[3], MAXIMUM_PURCHASE-20);
    });
  
  });

  describe("Crowdsale", async () => {

    it("should Fail to finish crowdsale from unauthorized source", async () => {
      try {
        await natanSale.finalize({from: accounts[5]});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

    it("should Fail to finish crowdsale before closing time", async () => {
      try {
        await natanSale.finalize({from: owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

  });

  describe("Crowdsale", async () => {

    before(async () => {
      await timeTravel(86400 * 365); // Move forward a year in time
      await mineBlock();  // workaround for https://github.com/ethereumjs/testrpc/issues/336
    });

    it("finish crowdsale", async () => {
      let currentBlock = await web3.eth.getBlock("latest");
      //console.log("block timestamp " + currentBlock.timestamp);
      //console.log("closing time " + endingTime.getTime());
      await natanSale.finalize({from: owner});
    });

  });
  
  describe("Withdraw tokens for the first year", async () => {

    it("should withdraw 1/3 of the remaining token for the first year", async () => {
      //let currentBlock = await web3.eth.getBlock("latest");
      //console.log(currentBlock.timestamp);
      await natanSale.withdrawFromStorage({from: owner});
    });

  });

  describe("Try withdraw tokens second time for the first year", async () => {

    before(async () => {
      await timeTravel(86400 * 60); // Move forward 2 month in time
      await mineBlock();  // workaround for https://github.com/ethereumjs/testrpc/issues/336
    });

    it("should FAIL to withdraw two times in the year 2019", async () => {
      try {
        await natanSale.withdrawFromStorage({from: owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

  });

  describe("Withdraw tokens for the second year", async () => {

    before(async () => {
      await timeTravel(86400 * 305); // Move forward a year in time
      await mineBlock()
    });

    it("should withdraw 2/3 of the remaining token for the year 2020", async () => {
      await natanSale.withdrawFromStorage({from: owner});
    });

  });

  describe("Try to withdraw tokens second time for the second year", async () => {

    before(async () => {
      await timeTravel(86400 * 60); // Move forward 2 month in time
      await mineBlock();  // workaround for https://github.com/ethereumjs/testrpc/issues/336
    });

    it("should FAIL to withdraw two times in the year 2020", async () => {
      try {
        await natanSale.withdrawFromStorage({from: owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

  });

  describe("Withdraw tokens for the third year", async () => {

    before(async () => {
      await timeTravel(86400 * 305); // Move forward a year in time
      await mineBlock()
    });

    it("should withdraw 3/3 of the remaining token for the year 2021", async () => {
      let isDone = await natanSale.withdrawFromStorage({from: owner});
    });

  });

  describe("Try to withdraw tokens second time for the third year", async () => {

    before(async () => {
      await timeTravel(86400 * 60); // Move forward 2 month in time
      await mineBlock();  // workaround for https://github.com/ethereumjs/testrpc/issues/336
    });

    it("should FAIL to withdraw two times in the year 2021", async () => {
      try {
        await natanSale.withdrawFromStorage({from: owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

  });

  describe("Try to withdraw tokens for the forth year", async () => {

    before(async () => {
      await timeTravel(86400 * 305); // Move forward a year in time
      await mineBlock()
    });

    it("should FAIL to withdraw in the year 2022", async () => {
      try {
        await natanSale.withdrawFromStorage({from: owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

  });

});
