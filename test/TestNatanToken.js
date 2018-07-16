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

contract('NatanToken', function(accounts) {

  const DECIMALSFACTOR = new BigNumber('10').pow('18');

  const TOKEN_NAME = "Natan Edu";
  const TOKEN_SYMBOL = "NTN";
  const TOKEN_DECIMALS = 18;

  const TEAM_TOKENS =  7600000 * TOKEN_DECIMALS;
  const STUD_BONUS_TOKENS =  4750000 * TOKEN_DECIMALS;
  const PREICO_TOKENS = 1653000 * TOKEN_DECIMALS;
  const NATANEDU_FOUNDATION = 4750000 * TOKEN_DECIMALS;
  const DEVELOPMENT_TOKENS = 14250000 * TOKEN_DECIMALS;
  const COMMUNITY_TOKENS = 3800000 * TOKEN_DECIMALS;
  const LEGALISSUES_TOKENS = 4750000 * TOKEN_DECIMALS;
  
  let natanToken;

  before(async() => {
    owner = accounts[0];
    bonusAdd = accounts[1];
    preicoAdd = accounts[2];
    foundAdd = accounts[3];
    devAdd = accounts[4];
    commAdd = accounts[5];
    legalAdd = accounts[6];
    coldAdd = accounts[7];
    natanToken = await NatanToken.new({from: owner});
  });

  describe("Token Basic Properties", async () => {

    it("Name", async function () {
      let tokenName = await natanToken.name();
      assert.equal(tokenName,TOKEN_NAME);
    });

    it("Symbol", async function () {
        let tokenSymbol = await natanToken.symbol();
        assert.equal(tokenSymbol,TOKEN_SYMBOL);
    });

    it("Decimals", async () => {
        let tokenDecimals = await natanToken.decimals();
        assert.equal(parseInt(tokenDecimals),TOKEN_DECIMALS);
    });

  });

  describe("Mint tokens", async () => {

    it("Mint team tokens", async () => {
        await natanToken.mint(owner, TEAM_TOKENS, {from: owner});
        let teamBalance = await natanToken.balanceOf(owner, {from: owner});
        assert.equal(teamBalance, TEAM_TOKENS);
    });

    it("Mint bonus tokens", async () => {
        await natanToken.mint(bonusAdd, STUD_BONUS_TOKENS, {from: owner});
        let bonusBalance = await natanToken.balanceOf(bonusAdd, {from: owner});
        assert.equal(bonusBalance, STUD_BONUS_TOKENS);
    });

    it("Mint pre ICO tokens", async () => {
        await natanToken.mint(preicoAdd, PREICO_TOKENS, {from: owner});
        let preicoBalance = await natanToken.balanceOf(preicoAdd, {from: owner});
        assert.equal(preicoBalance, PREICO_TOKENS);
    });

    it("Mint foundation tokens", async () => {
        await natanToken.mint(foundAdd, NATANEDU_FOUNDATION, {from: owner});
        let foundationBalance = await natanToken.balanceOf(foundAdd, {from: owner});
        assert.equal(foundationBalance, NATANEDU_FOUNDATION);
    });

    it("Mint development tokens", async () => {
        await natanToken.mint(devAdd, DEVELOPMENT_TOKENS, {from: owner});
        let developmentBalance = await natanToken.balanceOf(devAdd, {from: owner});
        assert.equal(developmentBalance, DEVELOPMENT_TOKENS);
    });

    it("Mint comunity tokens", async () => {
        await natanToken.mint(commAdd, COMMUNITY_TOKENS, {from: owner});
        let communityBalance = await natanToken.balanceOf(commAdd, {from: owner});
        assert.equal(communityBalance, COMMUNITY_TOKENS);
    });

    it("Mint legal issues tokens", async () => {
        await natanToken.mint(legalAdd, LEGALISSUES_TOKENS, {from: owner});
        let legalBalance = await natanToken.balanceOf(legalAdd, {from: owner});
        assert.equal(legalBalance, LEGALISSUES_TOKENS);
    });

    it("Mint cold wallet tokens", async () => {
        await natanToken.mint(coldAdd, LEGALISSUES_TOKENS, {from: owner});
        let coldBalance = await natanToken.balanceOf(coldAdd, {from: owner});
        assert.equal(coldBalance, LEGALISSUES_TOKENS);
    });

  });
  
  describe("Exclude accounts to transfer tokens", async () => {
      it("exclude accounts", async () => {
          await natanToken.addExcluded(owner, {from: owner});
          await natanToken.addExcluded(bonusAdd, {from: owner});
          await natanToken.addExcluded(preicoAdd, {from: owner});
      });
  });

  describe("Token Transfer Functions", async function() {

    it("should transfer 1000 NTN from owner to another address", async () => {
        await natanToken.transfer(accounts[8], 1000, {from: owner});
        natanToken.balanceOf(accounts[8]).then(res => {
            let account1Balance = res.toNumber();
            assert.equal(account1Balance,1000);
        });
    });

    it("should FAIL to transfer to null address", async () => {
        try {
            await natanToken.transfer(0, 1000, {from: owner});
        } catch (error) {
            //logError(" Tried to transfer to null address and failed");
            return true;
        }
        throw new Error("I should never see this!");
    });

    it('should FAIL to transfer more tokens than available', async() => {
        try {
            await natanToken.transfer(accounts[8], TEAM_TOKENS+1, {from: owner});
        } catch (error) {
            //logError("Tried to transfer more tokens than available and failed");
            return true;
        }
        throw new Error("I should never see this!")
    });

  });

  describe("Token TransferFrom", async() => {
      
    it('should FAIL to transferFrom to null address', async() => {
        try {
            await natanToken.transferFrom(preicoAdd,0,100,{from: owner});
        } catch (error) {
            //logError("Tried to transferFrom to null address and failed");
            return true;
        }
        throw new Error("I should never see this!")
    });

    it('should FAIL to transferFrom if _from has not enough balance', async() => {
        try {
            await natanToken.transferFrom(preicoAdd,accounts[8],PREICO_TOKENS+1,{from: owner});
        } catch (error) {
            //logError("✅   Tried to transferFrom without enough balance and failed");
            return true;
        }
        throw new Error("I should never see this!")
    });
  
  });
  
  describe("withdraw the remaining tokens", async () => {

    it("withdraw first year tokens", async () => {
        await natanToken.withdrawFromStorage(1, {from: owner});
    });

    it("withdraw second year tokens", async () => {
        await natanToken.withdrawFromStorage(2, {from: owner});
    });

    it("withdraw third year tokens", async () => {
        await natanToken.withdrawFromStorage(3, {from: owner});
    });

    it('should FAIL to withdraw tokens for the forth year', async() => {
        try {
            await natanToken.withdrawFromStorage(4, {from: owner});
        } catch (error) {
            //logError("Tried to withdraw tokens for another year");
            return true;
        }
        throw new Error("I should never see this!")
    });

  });

});
