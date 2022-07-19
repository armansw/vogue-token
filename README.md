# VOGUE Token Hardhat Project

Here is guide to deploy and verify contract step by step.

## Prepare
- Install node and yarn
- Install dependencies.
    ```ssh
    $ yarn
    ```
- Update .env file

    ```code
    INFURA_KEY=
    MNEMONIC=
    ETHERSCAN_API_KEY=
    ```
    
    >- MNEMONIC= mnemonic deployer wallet
    >- INFURA_KEY= infura key, you can get it from [here](https://infura.io/). If you are first with infura, please check this [document](https://medium.com/jelly-market/how-to-get-infura-api-key-e7d552dd396f)
    >- ETHERSCAN_API_KEY= Etherscan explorer apikey, you can get it from [here](https://etherscan.io/myapikey). If you are first with infura, please check this [document](https://info.etherscan.com/api-keys/)


    There is one env field for VOGUE_ADDR, but this field will be defined after once token would be deployed.


## Build

```ssh
$ yarn refresh
```

## Deploy

```ssh
$ yarn deploy
```
Once deployed, you can get contract addresses deployed on mainnet from console.
```ssh
% yarn deploy
yarn run v1.22.17
$ npx hardhat deploy
Compiled 9 Solidity files successfully
deploying "VogueToken" (tx: 0x7a551b8f9f12c41265a320d0f8b4ade45cdd65d7dd09dfd6de25800363b6aa5a)...: deployed at 0xac5c3604497157637CACfF11153785764d52a451 with 5686189 gas
✨  Done in 23.04s.
```
And update .env with this address (0xac5c3604497157637CACfF11153785764d52a451)

```env
...
VOGUE_ADDR=0xac5c3604497157637CACfF11153785764d52a451

```
## Verify

```ssh
$ yarn verify
```

