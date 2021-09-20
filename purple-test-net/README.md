# How to get local node-cli and connect to Alonzo purple testnet

This approach uses scripts from
[Alonzo-testnet](https://github.com/input-output-hk/Alonzo-testnet/tree/main/Alonzo-solutions/exercise1/docker) repository as it seems to be the easiest way to stay in sync with testnet updates.

* Start local node
  * Pick desired (probably, last avaliable) release tag from [IOHK DockerHub](https://hub.docker.com/r/inputoutput/cardano-node/tags)
  * Run `start.sh` providing tag as parameter, e.g:

      ```
      start.sh 1.30.0-rc4
      ```

      This will create needed directories, start node and share node socket to host machine to `./configuration/sockets` directory
* Get node cli **compatible** with current node version by either
  * Downloading ready to go binaries, e.g. <https://hydra.iohk.io/build/7667961/download/1/cardano-node-1.29.0-linux.tar.gz> (links periodically published in IOHK Discord)
  * Building one yourself:
    * clone [cardano-node repo](https://github.com/input-output-hk/cardano-node)
    * checkout to desired commit
    * run `nix-build -A cardano-cli` and use built one
* After node started successfully and node cli prepared, set environment variable `CARDANO_NODE_SOCKET_PATH` to point to node socket shared to host (local) machine. Now `cardan-cli` could be used locally. Try something like this to check if cli works: `cardano-cli query tip --testnet-magic 8`

  Should output something like this if successful:

  ```
  {
    "epoch": 278,
    "hash": "ebcfd0bdb21430fc155f3efcceea04c30bd752bd30355c7f84e07e318590e873",
    "slot": 1999797,
    "block": 93586,
    "era": "Alonzo",
    "syncProgress": "100.00"
  }

```
