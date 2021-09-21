#!/bin/sh
export NODE_TAG=$1
CONFIG=https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-config.json
BYRON_GENESIS=https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-byron-genesis.json
SHELLEY_GENESIS=https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-shelley-genesis.json
ALONZO_GENESIS=https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-alonzo-genesis.json
TOPOLOGY=https://hydra.iohk.io/build/7366583/download/1/alonzo-purple-topology.json

##Making some folders
mkdir -p ./configuration/config/
mkdir -p ./configuration/topology/
mkdir -p ./configuration/sockets/

##Making DB Folder
mkdir -p ./database/

##Touch for a Socket
touch ./configuration/sockets/node.socket

##Getting Config
echo "--getting config"
wget  $CONFIG -P ./configuration/config
wget  $BYRON_GENESIS -P ./configuration/config/
wget  $SHELLEY_GENESIS -P ./configuration/config/
wget  $ALONZO_GENESIS -P ./configuration/config/

##Getting Topology
echo "--getting topology"
wget $TOPOLOGY -P ./configuration/topology/

##Starting Docker-Compose
docker-compose up
