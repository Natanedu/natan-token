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

  before(async() => {
    owner = accounts[0];
    natanSale = await NatanSale.new(openingTime.getTime(), endingTime.getTime(), {from: owner});
    natanTokenAddress = await natanSale.token.call();
    natanToken = await NatanToken.at(natanTokenAddress, {from: owner});
  });

  describe("Buy tokens", async () => {
    let beneficiary;
    const dollaramount = 150;
    let tokensAmount = 0;
    let rate = 0;

    before(async () => {
      beneficiary = accounts[3];
      console.log("       mini          = " + MINIMAL_PURCHASE);
      console.log("       max           = " + MAXIMUM_PURCHASE);
    });

    it("buy tokens", async () => {
      let now = new Date().getTime();
      let date = new Date(openingTime);

      if(now <= date.setDate(openingTime.getDate() + 4)) {
        rate = 6;
      }
      else if((now > date.setDate(openingTime.getDate() + 6)) && (now <= date.setDate(openingTime.getDate() + 11))){
        rate = 7;
      }
      else if ((now > date.setDate(openingTime.getDate() + 14)) && (now <= date.setDate(openingTime.getDate() + 18))){
        rate = 8;
      }
      else {
        rate = 10;
      }

      tokensAmount = (dollaramount * 10) / rate;
      console.log("       rate          = " + rate);
      console.log("       tokens amount = " + tokensAmount);

      //change isValidPurchase() to public if you want to test this
      /*natanSale.isValidPurchase(beneficiary, tokensAmount).then((res) => {
        console.log(res);
      });*/
      
      await natanSale.buyTokens(beneficiary, dollaramount, {from: owner});
     
      natanToken.balanceOf(beneficiary).then((res) => {
        let balance = res.toNumber();
        assert.equal(balance,tokensAmount);
      });
    });

    it("beneficiary should Fail to have balance more than maximum purchase", async () => {
      try {
        await natanSale.buyTokens(beneficiary, 5000000, {from: owner});
      } catch (error) {
          //logError(" Beneficiary with address 0x0 tried to buy tokens and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });

    it("invalid beneficiary should Fail to buy tokens", async () => {
      try {
        await natanSale.buyTokens(0, dollaramount, {from: owner});
      } catch (error) {
          //logError(" Beneficiary with address 0x0 tried to buy tokens and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });
    
    it("beneficiary should Fail to buy amout of tokens inferior to the MINIMAL_PURCHASE", async () => {
      try {
        await natanSale.buyTokens(beneficiary, 0.1, {from: owner});
      } catch (error) {
        //logError(" Beneficiary tried to buy amount tokens < minimal purchase");
        return true;
      }
      throw new Error("I should never see this!");
    });

    it("beneficiary should Fail to buy amout of tokens superior to the MAXIMUM_PURCHASE", async () => {
      try {
        await natanSale.buyTokens(beneficiary, 5000000, {from: owner});
      } catch (error) {
        //logError(" Beneficiary tried to buy amount tokens > minimal purchase");
        return true;
      }
      throw new Error("I should never see this!");
    });
 
  });

  describe("Pause/Resume sale", async() => {

    it("should Fail to pause sale from unauthorized source", async () => {
      try {
        await natanSale.pauseSale({from: accounts[3]});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });   

    it("should Fail to resume unpaused sale from unauthorized source", async () => {
      try {
        await natanSale.resumeSale({from: owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });  

    it("Pause sale", async() => {
      await natanSale.pauseSale({from: owner});
      natanSale.isPaused.call().then((res) => {
        assert.equal(res, true);
      });
    });

    it("should Fail to resume sale from unauthorized source", async () => {
      try {
        await natanSale.resumeSale({from: accounts[3]});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });  
    
    it("Resume sale", async() => {
      await natanSale.resumeSale({from: owner});
      natanSale.isPaused.call().then((res) => {
        assert.equal(res, false);
      });
    });

  });

  describe("Finish sale", async () => {

    it("should Fail to finish crowdsale before closing time", async () => {
      try {
        await natanSale.finalizeSale({from: owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });   
    
    it("should Fail to finish crowdsale from unauthorized source", async () => {
      try {
        await natanSale.finalizeSale({from: accounts[9]});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });   

  });

  describe("Finish sale", async () => {

    before(async () => {
      await timeTravel(86400 * 365); // Move forward a year in time
      await mineBlock();  // workaround for https://github.com/ethereumjs/testrpc/issues/336
    });

    it("finish crowdsale", async () => {
      let currentBlock = await web3.eth.getBlock("latest");
      await natanSale.finalizeSale({from: owner});
      natanSale.isFinalized.call().then((res) => {
        assert.equal(res, true);
      });
    });

    it("should Fail to finish crowdsale after it's already finished", async () => {
      try {
        await natanSale.finalizeSale({from:owner});
      } catch (error) {
          //logError(" Tried to withdraw for the second time in the same year and failed");
          return true;
      }
      throw new Error("I should never see this!");
    });   

  });
  
});
