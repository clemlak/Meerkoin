/* eslint-env node, mocha */
/* global artifacts, contract, it, assert */
const Utils = require('web3-utils');

const Meerkoin = artifacts.require('Meerkoin');

let instance;

const token = {
  name: 'Meerkoin',
  symbol: 'MEER',
  decimals: 18,
  power: 10 ** 18,
  price: 0.01,
};

contract('Meerkoin', (accounts) => {
  it('Should deploy an instance of the Meerkoin contract', () => Meerkoin.deployed()
    .then((contractInstance) => {
      instance = contractInstance;
    }));

  it('Should get the name of the token', () => instance.name()
    .then((name) => {
      assert.equal(name, token.name, 'Name is wrong');
    }));

  it('Should get the symbol of the token', () => instance.symbol()
    .then((symbol) => {
      assert.equal(symbol, token.symbol, 'Symbol is wrong');
    }));

  it('Should get the decimals of the token', () => instance.decimals()
    .then((decimals) => {
      assert.equal(decimals, token.decimals, 'Decimals are wrong');
    }));

  it('Should get the balance of account 0', () => instance.balanceOf(accounts[0])
    .then((balance) => {
      assert.equal(balance, 0, 'Balance is wrong');
    }));

  it('Should buy some tokens', () => instance.buyTokens({
    from: accounts[0],
    value: Utils.toWei('2'),
  }));

  it('Should check again the balance of account 0', () => instance.balanceOf(accounts[0])
    .then((balance) => {
      const expectedBalance = 2 / token.price;

      assert.equal(balance.toString(), Utils.toWei(expectedBalance.toString()), 'Balance is wrong');
    }));
});
