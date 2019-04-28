/* eslint-env node, mocha */
/* global artifacts, contract, it, assert */

const Meerkoin = artifacts.require('Meerkoin');

let instance;

contract('Meerkoin', (accounts) => {
  it('Should deploy an instance of the Meerkoin contract', () => Meerkoin.deployed()
    .then((contractInstance) => {
      instance = contractInstance;
    }));
});
