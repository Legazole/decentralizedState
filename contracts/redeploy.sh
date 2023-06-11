#!/bin/bash
yarn hardhat clean
yarn hardhat compile
yarn hardhat run scripts/deploy.property.ts --network goerli 

