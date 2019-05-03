/* eslint-env node, mocha */
/* global artifacts, contract, it, assert */
const Utils = require('web3-utils');
const Accounts = require('web3-eth-accounts');

const Meerkoin = artifacts.require('Meerkoin');

const web3Accounts = new Accounts();
let instance;

const token = {
  name: 'Meerkoin',
  symbol: 'MEER',
  decimals: 18,
  power: 10 ** 18,
  price: 0.01,
};

let nonce;
let metaHash;
const userPrivateKey = '0x2ae8f7a9af03c0151d9422ad1f87238991897e5dd8bf9ce18d6a4edb3bfb8fed';
const userAddress = '0x84EfE1a6e15F2865204E44458d9eBFbA26C0d2f9';

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
    value: Utils.toWei('3'),
  }));

  it('Should check again the balance of account 0', () => instance.balanceOf(accounts[0])
    .then((balance) => {
      assert.equal(balance.toString(), Utils.toWei('3'), 'Balance is wrong');
    }));

  it('Should sell some tokens from account 0', () => instance.sellTokens(
    Utils.toWei('2'),
  )
    .then((tx) => {
      const value = tx.receipt.logs[0].args.value.toString();
      assert.equal(value, Utils.toWei('2'), 'Transferred value is wrong');
    }));

  it('Should check again the balance of account 0', () => instance.balanceOf(accounts[0])
    .then((balance) => {
      assert.equal(balance.toString(), Utils.toWei('1'), 'Balance is wrong');
    }));

  it('Should check the nonce for account 0', () => instance.nonces(accounts[0])
    .then((res) => {
      assert.equal(res, 0, 'Account 0 nonce is wrong');
      nonce = res;
    }));

  it('Should get the hash for the metaTransfer function', () => instance.metaTransferHash(
    accounts[1],
    Utils.toWei('1'),
    Utils.toWei('0.1'),
    nonce,
  )
    .then((res) => {
      const expectedMetaHash = Utils.soliditySha3(
        instance.address,
        'metaTransfer',
        accounts[1],
        Utils.toWei('1'),
        Utils.toWei('0.1'),
        nonce,
      );

      assert.equal(res, expectedMetaHash, 'Meta hash is wrong');
      metaHash = res;
    }));

  it('Should sign and verify the signer of an hash', () => instance.getSigner(
    metaHash,
    web3Accounts.sign(metaHash, userPrivateKey).signature,
  )
    .then((res) => {
      assert.equal(res, userAddress, 'Signer is wrong');
    }));

  it('Should use the metaTransfer function', () => instance.metaTransfer(
    web3Accounts.sign(metaHash, userPrivateKey).signature,
    accounts[1],
    Utils.toWei('1'),
    Utils.toWei('0.1'),
    nonce, {
      from: accounts[2],
    },
  ));

  it('Should check again the balance of account 0', () => instance.balanceOf(accounts[0])
    .then((balance) => {
      assert.equal(balance.toString(), Utils.toWei('0'), 'Balance is wrong');
    }));

  it('Should check account 1 balance', () => instance.balanceOf(accounts[1])
    .then((balance) => {
      assert.equal(balance, Utils.toWei('0.90'), 'Account 1 balance is wrong');
    }));

  it('Should check account 2 balance', () => instance.balanceOf(accounts[2])
    .then((balance) => {
      assert.equal(balance, Utils.toWei('0.1'), 'Account 2 balance is wrong');
    }));
});
