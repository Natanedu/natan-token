const NatanSale = artifacts.require("natanCrowdsale");
const NatanToken = artifacts.require("natanEduToken");
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

  const TOKEN_DECIMALS = 18;
  const DECIMALSFACTOR = 10 ** TOKEN_DECIMALS;
  const openingTime = new Date(1531872000); // 18 july 2018 01:00:00
  const endingTime = new Date(1563408000);  // 18 july 2019 01:00:00
  const MINIMAL_PURCHASE = 100 * DECIMALSFACTOR;
  const MAXIMUM_PURCHASE = 500 * DECIMALSFACTOR;

  let natanSale;
  let natanToken;
  let natanTokenAddress;
  let rate = 0;

  before(async() => {
    owner = accounts[0];
    wallet = accounts[1];
    natanSale = await NatanSale.new(openingTime.getTime(), endingTime.getTime(), wallet, {from: owner});
    natanTokenAddress = await natanSale.token.call();
    natanToken = await NatanToken.at(natanTokenAddress, {from: owner});
  });

  describe("Token Sale Rate", async () => {

    it("Rate", async function () {
      natanSale.getRate().then(res => {
        rate = res.toNumber();
        let now = new Date().getTime();
        let date = new Date(openingTime);
        //console.log("       Rate   : " + rate);
        //console.log("       Now    : " + now);
        //console.log("       Date   : " + date.getTime());
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
    let beneficiary;
    const weiamount = 1;
    let rate;
    let tokens;

    before(async () => {
      beneficiary = accounts[3];
      natanSale.getRate().then(async (res) => {
        rate = res.toNumber();
        tokens = weiamount*rate;

        console.log("       Rate   : " + rate);
        console.log("       tokens = " + tokens);
        console.log("       mini   = " + MINIMAL_PURCHASE);
        console.log("       maxi   = " + MAXIMUM_PURCHASE);
      });
    });

    it("buy tokens", async () => {
      //let tokenAmount = await natanSale._getTokenAmount(weiamount, {from: beneficiary});
      //console.log("       Amount = " + tokenAmount + "( using _getTokenAmount() )");
      //console.log(tokenAmount >= MINIMAL_PURCHASE);
      //console.log(tokenAmount <= MAXIMUM_PURCHASE);
      await natanSale.buyTokens(beneficiary, weiamount, {from: beneficiary});
      natanToken.balanceOf(beneficiary).then((res) => {
        let balance = res.toNumber();
        assert.equal(balance,tokens);
      });
    });

    it("beneficiary should Fail to have balance more than maximum purchase", async () => {
      try {
        await natanSale.buyTokens(beneficiary, weiamount, {from: beneficiary});
      } catch (error) {
          //logError(" Beneficiary with address 0x0 tried to buy tokens and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

    it("invalid beneficiary should Fail to buy tokens", async () => {
      try {
        await natanSale.buyTokens(0, weiamount, {from: beneficiary});
      } catch (error) {
          //logError(" Beneficiary with address 0x0 tried to buy tokens and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });
    
    it("beneficiary should Fail to buy amout of tokens inferior to the MINIMAL_PURCHASE", async () => {
      try {
        await natanSale.buyTokens(beneficiary, 0.001, {from: beneficiary});
      } catch (error) {
        //logError(" Beneficiary tried to buy amount tokens < minimal purchase");
        return true;
      }
      throw new Error("I should never see this!");
    });

    it("beneficiary should Fail to buy amout of tokens superior to the MAXIMUM_PURCHASE", async () => {
      try {
        await natanSale.buyTokens(beneficiary, 1, {from: beneficiary});
      } catch (error) {
        //logError(" Beneficiary tried to buy amount tokens > minimal purchase");
        return true;
      }
      throw new Error("I should never see this!");
    });
 
  });

  describe("Crowdsale", async () => {

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

    it("should Fail to finish crowdsale from unauthorized source", async () => {
      try {
        await natanSale.finalize({from: accounts[5]});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

    it("finish crowdsale", async () => {
      let currentBlock = await web3.eth.getBlock("latest");
      await natanSale.finalize({from: owner});
      natanSale.isFinalized.call().then((res) => {
        assert.equal(res, true);
      });
    });

  });
  
  describe("Withdraw tokens for the first year", async () => {

    it("should withdraw 1/3 of the remaining token for the first year", async () => {
      let currentBlock = await web3.eth.getBlock("latest");
      await natanSale.withdrawFromStorage({from: owner}); 
      natanSale.count.call((res) => {
        assert.equal(res, 1);
      });     
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
      natanSale.count.call((res) => {
        assert.equal(res, 2);
      });     
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
      natanSale.count.call((res) => {
        assert.equal(res, 3);
      });     
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
