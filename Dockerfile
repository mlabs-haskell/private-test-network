FROM ubuntu:20.04

# set working directory

WORKDIR /home
ENV HOME=/home

# set time zone for tzdata dependency

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

# instal dependencies

RUN apt-get update -y \
 && apt-get upgrade -y 
RUN apt-get install   \
    git jq bc make    \
    automake rsync    \
    htop curl         \
    build-essential   \
    pkg-config        \
    libffi-dev        \
    libgmp-dev        \
    libssl-dev        \
    libtinfo-dev      \
    libsystemd-dev    \
    zlib1g-dev make   \
    g++ wget          \
    libncursesw5      \
    tmux              \
    libtool autoconf -y

# install Libsodium

RUN mkdir $HOME/git
WORKDIR $HOME/git
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR $HOME/git/libsodium
RUN git checkout 66f017f1
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# install cabal and dependancies

RUN apt-get -y install libncurses-dev libtinfo5 iproute2 lsof

RUN yes | curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ENV PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:${PATH}"

WORKDIR $HOME
# RUN source /root/.bashrc
RUN ghcup upgrade
RUN ghcup install cabal 3.4.0.0
RUN ghcup set cabal 3.4.0.0

# install correct ghc version

RUN ghcup install ghc 8.10.4
RUN ghcup set ghc 8.10.4

# set variables 

ENV PATH="$HOME/.local/bin:{$PATH}" 
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" 
ENV NODE_HOME=$HOME/cardano-my-node
ENV NODE_CONFIG=alonzo-purple
ENV NODE_BUILD_NUM=7189190
# RUN source /root/.bashrc

# update cabal

RUN cabal update

# Build Node

WORKDIR $HOME/git
RUN git clone https://github.com/input-output-hk/cardano-node.git
WORKDIR $HOME/git/cardano-node
RUN git fetch --all --recurse-submodules --tags
RUN git checkout 708de685d49ec6af4b2d8b3cbfa0eca0e9e43edf

RUN cabal configure -O0 -w ghc-8.10.4

RUN echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
RUN sed -i $HOME/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
RUN rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.4
RUN cabal build cardano-cli cardano-node

# copy cardano-cli and cardano-node into the bin directory

RUN cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
RUN cp $(find $HOME/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node

# configure Alonzo-blue nodes

RUN mkdir $NODE_HOME
WORKDIR $NODE_HOME
RUN wget -O start.sh https://raw.githubusercontent.com/mlabs-haskell/private-test-network/master/scripts/mkfiles.sh?token=AKHJSNUS5TBMX72PXLAMCCTBEUCBS
RUN wget -O 1-toShelley.sh https://raw.githubusercontent.com/mlabs-haskell/private-test-network/master/scripts/update-1.sh?token=AKHJSNS3GKV5VSCLX5BXNCDBEUCR2
RUN wget -O 2-toAllegra.sh https://raw.githubusercontent.com/mlabs-haskell/private-test-network/master/scripts/update-3.sh?token=AKHJSNRZL5OGFXFSCSA4IK3BEUCXI
RUN wget -O 3-toMary.sh https://raw.githubusercontent.com/mlabs-haskell/private-test-network/master/scripts/update-4.sh?token=AKHJSNQICTF7TDW7GO6IFIDBEUC2O
RUN wget -O 4-toAlonzo.sh https://raw.githubusercontent.com/mlabs-haskell/private-test-network/master/scripts/update-5.sh?token=AKHJSNTQEPOWECL5RZ3K42DBEUC5C
RUN wget -O configuration.yaml https://raw.githubusercontent.com/mlabs-haskell/private-test-network/master/config/configuration.yaml?token=AKHJSNW4SVMQOL4CCFEZX2LBEUC72
RUN wget -O genesis.alonzo.json https://raw.githubusercontent.com/mlabs-haskell/private-test-network/master/config/genesis.alonzo.json?token=AKHJSNWFCZSG6W7NEF26XXLBEUDCO

RUN chmod +x 1-toShelley.sh 2-toAllegra.sh 3-toMary.sh 4-toAlonzo.sh start.sh

# update config 

# RUN sed -i ${NODE_CONFIG}-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"

# set socket variable

ENV CARDANO_NODE_SOCKET_PATH="/home/cardano-my-node/example/node-bft1/node.sock"
# ENV CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket"

# set up gLiveview

# RUN apt install bc tcptraceroute -y
# RUN curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
# RUN curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
# RUN chmod 755 gLiveView.sh
# (running curl to get env file second time - issue that prevents the first curl from working ocasionally.)
# RUN curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env

# RUN sed -i env \
#    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/alonzo-purple-config.json\"/g" \
#    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g" 

# start node

# RUN /usr/local/bin/cardano-node run \
#    --topology /home/cardano-my-node/alonzo-purple-topology.json \
#    --database-path /home/cardano-my-node/db \
#    --socket-path /home/cardano-my-node/db/socket \
#    --host-addr 0.0.0.0 \
#    --port 6000 \
#    --config /home/cardano-my-node/alonzo-purple-config.json
