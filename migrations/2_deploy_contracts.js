/* eslint-env node */
/* global artifacts */

const Meerkoin = artifacts.require('Meerkoin');

function deployContracts(deployer) {
  deployer.deploy(Meerkoin);
}

module.exports = deployContracts;
