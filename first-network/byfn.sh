#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script will orchestrate a sample end-to-end execution of the Hyperledger
# Fabric network.
#
# The end-to-end verification provisions a sample Fabric network consisting of
# two organizations, each maintaining two peers, and a “solo” ordering service.
#
# This verification makes use of two fundamental tools, which are necessary to
# create a functioning transactional network with digital signature validation
# and access control:
#
# * cryptogen - generates the x509 certificates used to identify and
#   authenticate the various components in the network.
# * configtxgen - generates the requisite configuration artifacts for orderer
#   bootstrap and channel creation.
#
# Each tool consumes a configuration yaml file, within which we specify the topology
# of our network (cryptogen) and the location of our certificates for various
# configuration operations (configtxgen).  Once the tools have been successfully run,
# we are able to launch our network.  More detail on the tools and the structure of
# the network will be provided later in this document.  For now, let's get going...

# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  byfn.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-i <imagetag>] [-v]"
  echo "    <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'upgrade'  - upgrade the network from version 1.1.x to 1.2.x"
  echo "    -c <channel name> - channel name to use (defaults to \"mychannel\")"
  echo "    -t <timeout> - CLI timeout duration in seconds (defaults to 10)"
  echo "    -d <delay> - delay duration in seconds (defaults to 3)"
  echo "    -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-cli.yaml)"
  echo "    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
  echo "    -l <language> - the chaincode language: golang (default) or node"
  echo "    -i <imagetag> - the tag to be used to launch the network (defaults to \"latest\")"
  echo "    -v - verbose mode"
  echo "  byfn.sh -h (print this message)"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	byfn.sh generate -c mychannel"
  echo "	byfn.sh up -c mychannel -s couchdb"
  echo "        byfn.sh up -c mychannel -s couchdb -i 1.2.x"
  echo "	byfn.sh up -l node"
  echo "	byfn.sh down -c mychannel"
  echo "        byfn.sh upgrade -c mychannel"
  echo
  echo "Taking all defaults:"
  echo "	byfn.sh generate"
  echo "	byfn.sh up"
  echo "	byfn.sh down"
}

# Ask user for confirmation to proceed
function askProceed() {
  read -p "Continue? [Y/n] " ans
  case "$ans" in
  y | Y | "")
    echo "proceeding ..."
    ;;
  n | N)
    echo "exiting..."
    exit 1
    ;;
  *)
    echo "invalid response"
    askProceed
    ;;
  esac
}

# Obtain CONTAINER_IDS and remove them
# TODO Might want to make this optional - could clear other containers
function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*.mycc.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# TODO list generated image naming patterns
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*.mycc.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

# Versions of fabric known not to work with this release of first-network
BLACKLISTED_VERSIONS="^1\.0\. ^1\.1\.0-preview ^1\.1\.0-alpha"

# Do some basic sanity checking to make sure that the appropriate versions of fabric
# binaries/images are available.  In the future, additional checking for the presence
# of go or other items could be added.
function checkPrereqs() {
  # Note, we check configtxlator externally because it does not require a config file, and peer in the
  # docker image because of FAB-8551 that makes configtxlator return 'development version' in docker
  LOCAL_VERSION=$(configtxlator version | sed -ne 's/ Version: //p')
  DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-tools:$IMAGETAG peer version | sed -ne 's/ Version: //p' | head -1)

  echo "LOCAL_VERSION=$LOCAL_VERSION"
  echo "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"

  if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
    echo "=================== WARNING ==================="
    echo "  Local fabric binaries and docker images are  "
    echo "  out of  sync. This may cause problems.       "
    echo "==============================================="
  fi

  for UNSUPPORTED_VERSION in $BLACKLISTED_VERSIONS; do
    echo "$LOCAL_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
      echo "ERROR! Local Fabric binary version of $LOCAL_VERSION does not match this newer version of BYFN and is unsupported. Either move to a later version of Fabric or checkout an earlier version of fabric-samples."
      exit 1
    fi

    echo "$DOCKER_IMAGE_VERSION" | grep -q $UNSUPPORTED_VERSION
    if [ $? -eq 0 ]; then
      echo "ERROR! Fabric Docker image version of $DOCKER_IMAGE_VERSION does not match this newer version of BYFN and is unsupported. Either move to a later version of Fabric or checkout an earlier version of fabric-samples."
      exit 1
    fi
  done
}

# Generate the needed certificates, the genesis block and start the network.
function networkUp() {
  checkPrereqs
  # generate artifacts if they don't exist
  if [ ! -d "crypto-config" ]; then
    generateCerts
    replacePrivateKey
    generateChannelArtifacts
  fi
  if [ "${IF_COUCHDB}" == "couchdb" ]; then
    IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH up -d 2>&1
  else
    IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE up -d 2>&1
  fi
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    exit 1
  fi
  # now run the end to end script
  docker exec cli scripts/script.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Test failed"
    exit 1
  fi
}

# Upgrade the network components which are at version 1.1.x to 1.2.x
# Stop the orderer and peers, backup the ledger for orderer and peers, cleanup chaincode containers and images
# and relaunch the orderer and peers with latest tag
function upgradeNetwork() {
  docker inspect -f '{{.Config.Volumes}}' orderer.peach.com | grep -q '/var/hyperledger/production/orderer'
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! This network does not appear to be using volumes for its ledgers, did you start from fabric-samples >= v1.1.x?"
    exit 1
  fi

  LEDGERS_BACKUP=./ledgers-backup

  # create ledger-backup directory
  mkdir -p $LEDGERS_BACKUP

  export IMAGE_TAG=$IMAGETAG
  if [ "${IF_COUCHDB}" == "couchdb" ]; then
    COMPOSE_FILES="-f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH"
  else
    COMPOSE_FILES="-f $COMPOSE_FILE"
  fi

  # removing the cli container
  docker-compose $COMPOSE_FILES stop cli
  docker-compose $COMPOSE_FILES up -d --no-deps cli

  echo "Upgrading orderer"
  docker-compose $COMPOSE_FILES stop orderer.peach.com
  docker cp -a orderer.peach.com:/var/hyperledger/production/orderer $LEDGERS_BACKUP/orderer.peach.com
  docker-compose $COMPOSE_FILES up -d --no-deps orderer.peach.com

  for PEER in peer0.org1.peach.com peer1.org1.peach.com peer0.org2.peach.com peer1.org2.peach.com; do
    echo "Upgrading peer $PEER"

    # Stop the peer and backup its ledger
    docker-compose $COMPOSE_FILES stop $PEER
    docker cp -a $PEER:/var/hyperledger/production $LEDGERS_BACKUP/$PEER/

    # Remove any old containers and images for this peer
    CC_CONTAINERS=$(docker ps | grep dev-$PEER | awk '{print $1}')
    if [ -n "$CC_CONTAINERS" ]; then
      docker rm -f $CC_CONTAINERS
    fi
    CC_IMAGES=$(docker images | grep dev-$PEER | awk '{print $1}')
    if [ -n "$CC_IMAGES" ]; then
      docker rmi -f $CC_IMAGES
    fi

    # Start the peer again
    docker-compose $COMPOSE_FILES up -d --no-deps $PEER
  done

  docker exec cli scripts/upgrade_to_v12.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Test failed"
    exit 1
  fi
}

# Tear down running network
function networkDown() {
  # stop org3 containers also in addition to org1 and org2, in case we were running sample to add org3
  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH down --volumes --remove-orphans

  # Don't remove the generated artifacts -- note, the ledgers are always removed
  if [ "$MODE" != "restart" ]; then
    # Bring down the network, deleting the volumes
    #Delete any ledger backups
    docker run -v $PWD:/tmp/first-network --rm hyperledger/fabric-tools:$IMAGETAG rm -Rf /tmp/first-network/ledgers-backup
    #Cleanup the chaincode containers
    clearContainers
    #Cleanup images
    removeUnwantedImages
    # remove orderer block and other channel configuration transactions and certs
    # rm -rf channel-artifacts/*.block channel-artifacts/*.tx crypto-config ./org3-artifacts/crypto-config/ channel-artifacts/org3.json
    # remove the docker-compose yaml file that was customized to the example
    rm -f docker-compose-e2e.yaml
  fi
}

# Using docker-compose-e2e-template.yaml, replace constants with private key file names
# generated by the cryptogen tool and output a docker-compose.yaml specific to this
# configuration
function replacePrivateKey() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp docker-compose-e2e-template.yaml docker-compose-cli.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  cd crypto-config/peerOrganizations/org1.peach.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cli.yaml
  cd crypto-config/peerOrganizations/org2.peach.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cli.yaml
  cd crypto-config/peerOrganizations/org3.peach.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA3_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cli.yaml
  cd crypto-config/peerOrganizations/org4.peach.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA4_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cli.yaml
  cd crypto-config/peerOrganizations/org5.peach.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA5_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cli.yaml
  cd crypto-config/peerOrganizations/org6.peach.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA6_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cli.yaml
  cd crypto-config/peerOrganizations/org7.peach.com/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA7_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cli.yaml
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  # If MacOSX, remove the temporary backup of the docker-compose file
  if [ "$ARCH" == "Darwin" ]; then
    rm docker-compose-e2e.yamlt
  fi
}

# We will use the cryptogen tool to generate the cryptographic material (x509 certs)
# for our various network entities.  The certificates are based on a standard PKI
# implementation where validation is achieved by reaching a common trust anchor.
#
# Cryptogen consumes a file - ``crypto-config.yaml`` - that contains the network
# topology and allows us to generate a library of certificates for both the
# Organizations and the components that belong to those Organizations.  Each
# Organization is provisioned a unique root certificate (``ca-cert``), that binds
# specific components (peers and orderers) to that Org.  Transactions and communications
# within Fabric are signed by an entity's private key (``keystore``), and then verified
# by means of a public key (``signcerts``).  You will notice a "count" variable within
# this file.  We use this to specify the number of peers per Organization; in our
# case it's two peers per Org.  The rest of this template is extremely
# self-explanatory.
#
# After we run the tool, the certs will be parked in a folder titled ``crypto-config``.

# Generates Org certs using cryptogen tool
function generateCerts() {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi
  set -x
  cryptogen generate --config=./crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}

# The `configtxgen tool is used to create four artifacts: orderer **bootstrap
# block**, fabric **channel configuration transaction**, and two **anchor
# peer transactions** - one for each Peer Org.
#
# The orderer block is the genesis block for the ordering service, and the
# channel transaction file is broadcast to the orderer at channel creation
# time.  The anchor peer transactions, as the name might suggest, specify each
# Org's anchor peer on this channel.
#
# Configtxgen consumes a file - ``configtx.yaml`` - that contains the definitions
# for the sample network. There are three members - one Orderer Org (``OrdererOrg``)
# and two Peer Orgs (``Org1`` & ``Org2``) each managing and maintaining two peer nodes.
# This file also specifies a consortium - ``SampleConsortium`` - consisting of our
# two Peer Orgs.  Pay specific attention to the "Profiles" section at the top of
# this file.  You will notice that we have two unique headers. One for the orderer genesis
# block - ``TwoOrgsOrdererGenesis`` - and one for our channel - ``TwoOrgsChannel``.
# These headers are important, as we will pass them in as arguments when we create
# our artifacts.  This file also contains two additional specifications that are worth
# noting.  Firstly, we specify the anchor peers for each Peer Org
# (``peer0.org1.peach.com`` & ``peer0.org2.peach.com``).  Secondly, we point to
# the location of the MSP directory for each member, in turn allowing us to store the
# root certificates for each Org in the orderer genesis block.  This is a critical
# concept. Now any network entity communicating with the ordering service can have
# its digital signature verified.
#
# This function will generate the crypto material and our four configuration
# artifacts, and subsequently output these files into the ``channel-artifacts``
# folder.
#
# If you receive the following warning, it can be safely ignored:
#
# [bccsp] GetDefault -> WARN 001 Before using BCCSP, please call InitFactories(). Falling back to bootBCCSP.
#
# You can ignore the logs regarding intermediate certs, we are not using them in
# this crypto implementation.

# Generate orderer genesis block, channel configuration transaction and
# anchor peer update transactions
function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  set -x
  configtxgen -profile SevenOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel12.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org1Org2Channel -outputCreateChannelTx ./channel-artifacts/channel12.tx -channelID "$CHANNEL_NAME"12
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel.tx13' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org1Org3Channel -outputCreateChannelTx ./channel-artifacts/channel13.tx -channelID "$CHANNEL_NAME"13
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel.tx14' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org1Org4Channel -outputCreateChannelTx ./channel-artifacts/channel14.tx -channelID "$CHANNEL_NAME"14
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel.tx15' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org1Org5Channel -outputCreateChannelTx ./channel-artifacts/channel15.tx -channelID "$CHANNEL_NAME"15
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel.tx16' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org1Org6Channel -outputCreateChannelTx ./channel-artifacts/channel16.tx -channelID "$CHANNEL_NAME"16
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel17.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org1Org7Channel -outputCreateChannelTx ./channel-artifacts/channel17.tx -channelID "$CHANNEL_NAME"17
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel23.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org2Org3Channel -outputCreateChannelTx ./channel-artifacts/channel23.tx -channelID "$CHANNEL_NAME"23
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel24.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org2Org4Channel -outputCreateChannelTx ./channel-artifacts/channel24.tx -channelID "$CHANNEL_NAME"24
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel.tx25' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org2Org5Channel -outputCreateChannelTx ./channel-artifacts/channel25.tx -channelID "$CHANNEL_NAME"25
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel26.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org2Org6Channel -outputCreateChannelTx ./channel-artifacts/channel26.tx -channelID "$CHANNEL_NAME"26
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel27.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org2Org7Channel -outputCreateChannelTx ./channel-artifacts/channel27.tx -channelID "$CHANNEL_NAME"27
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel34.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org3Org4Channel -outputCreateChannelTx ./channel-artifacts/channel34.tx -channelID "$CHANNEL_NAME"34
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel35.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org3Org5Channel -outputCreateChannelTx ./channel-artifacts/channel35.tx -channelID "$CHANNEL_NAME"35
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel36.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org3Org6Channel -outputCreateChannelTx ./channel-artifacts/channel36.tx -channelID "$CHANNEL_NAME"36
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel37.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org3Org7Channel -outputCreateChannelTx ./channel-artifacts/channel37.tx -channelID "$CHANNEL_NAME"37
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel45.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org4Org5Channel -outputCreateChannelTx ./channel-artifacts/channel45.tx -channelID "$CHANNEL_NAME"45
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel46.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org4Org6Channel -outputCreateChannelTx ./channel-artifacts/channel46.tx -channelID "$CHANNEL_NAME"46
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel47.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org4Org7Channel -outputCreateChannelTx ./channel-artifacts/channel47.tx -channelID "$CHANNEL_NAME"47
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel56.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org5Org6Channel -outputCreateChannelTx ./channel-artifacts/channel56.tx -channelID "$CHANNEL_NAME"56
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel57.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org5Org7Channel -outputCreateChannelTx ./channel-artifacts/channel57.tx -channelID "$CHANNEL_NAME"57
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo
  echo "###################################################################"
  echo "### Generating channel configuration transaction 'channel67.tx' ###"
  echo "###################################################################"
  set -x
  configtxgen -profile Org6Org7Channel -outputCreateChannelTx ./channel-artifacts/channel67.tx -channelID "$CHANNEL_NAME"67
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi
  echo


  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org2MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org3MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org4MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org4MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org4MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org4MSP..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org5MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org5MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org5MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org5MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org6MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org6MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org6MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org6MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org7MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile SevenOrgsChannel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org7MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org7MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org7MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org2Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org1MSPanchors12.tx -channelID "$CHANNEL_NAME"12 -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org2Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org2MSPanchors12.tx -channelID "$CHANNEL_NAME"12 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org2MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org3Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org1MSPanchors13.tx -channelID "$CHANNEL_NAME"13 -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org3Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org3MSPanchors13.tx -channelID "$CHANNEL_NAME"13 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org3MSP..."
    exit 1
  fi
  echo
#--
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org4Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org1MSPanchors14.tx -channelID "$CHANNEL_NAME"14 -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org4MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org4Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org4MSPanchors14.tx -channelID "$CHANNEL_NAME"14 -asOrg Org4MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org4MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org1MSPanchors15.tx -channelID "$CHANNEL_NAME"15 -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#--
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org5MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org5MSPanchors15.tx -channelID "$CHANNEL_NAME"15 -asOrg Org5MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org5MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org1MSPanchors16.tx -channelID "$CHANNEL_NAME"16 -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org6MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org6MSPanchors16.tx -channelID "$CHANNEL_NAME"16 -asOrg Org6MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org6MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org1MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org1MSPanchors17.tx -channelID "$CHANNEL_NAME"17 -asOrg Org1MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org7MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org1Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org7MSPanchors17.tx -channelID "$CHANNEL_NAME"17 -asOrg Org7MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org7MSP..."
    exit 1
  fi
  echo
#---
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org3Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org2MSPanchors23.tx -channelID "$CHANNEL_NAME"23 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org3Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org3MSPanchors23.tx -channelID "$CHANNEL_NAME"23 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org3MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org4Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org2MSPanchors24.tx -channelID "$CHANNEL_NAME"24 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org4MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org4Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org4MSPanchors24.tx -channelID "$CHANNEL_NAME"24 -asOrg Org4MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org2MSPanchors25.tx -channelID "$CHANNEL_NAME"25 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org5MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org5MSPanchors25.tx -channelID "$CHANNEL_NAME"25 -asOrg Org5MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org2MSPanchors26.tx -channelID "$CHANNEL_NAME"26 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org6MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org6MSPanchors26.tx -channelID "$CHANNEL_NAME"26 -asOrg Org6MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org2MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org2MSPanchors27.tx -channelID "$CHANNEL_NAME"27 -asOrg Org2MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org7MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org2Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org7MSPanchors27.tx -channelID "$CHANNEL_NAME"27 -asOrg Org7MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org4Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org3MSPanchors34.tx -channelID "$CHANNEL_NAME"34 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org4MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org4Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org4MSPanchors34.tx -channelID "$CHANNEL_NAME"34 -asOrg Org4MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org3MSPanchors35.tx -channelID "$CHANNEL_NAME"35 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org5MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org5MSPanchors35.tx -channelID "$CHANNEL_NAME"35 -asOrg Org5MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org3MSPanchors36.tx -channelID "$CHANNEL_NAME"36 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org6MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org6MSPanchors36.tx -channelID "$CHANNEL_NAME"36 -asOrg Org6MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org3MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org3MSPanchors37.tx -channelID "$CHANNEL_NAME"37 -asOrg Org3MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org7MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org3Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org7MSPanchors37.tx -channelID "$CHANNEL_NAME"37 -asOrg Org7MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org4MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org4Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org4MSPanchors45.tx -channelID "$CHANNEL_NAME"45 -asOrg Org4MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org5MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org4Org5Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org5MSPanchors45.tx -channelID "$CHANNEL_NAME"45 -asOrg Org5MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org4MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org4Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org4MSPanchors46.tx -channelID "$CHANNEL_NAME"46 -asOrg Org4MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org6MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org4Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org6MSPanchors46.tx -channelID "$CHANNEL_NAME"46 -asOrg Org6MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org4MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org4Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org4MSPanchors47.tx -channelID "$CHANNEL_NAME"47 -asOrg Org4MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org7MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org4Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org7MSPanchors47.tx -channelID "$CHANNEL_NAME"47 -asOrg Org7MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org5MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org5Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org5MSPanchors56.tx -channelID "$CHANNEL_NAME"56 -asOrg Org5MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org6MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org5Org6Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org6MSPanchors56.tx -channelID "$CHANNEL_NAME"56 -asOrg Org6MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org5MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org5Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org5MSPanchors57.tx -channelID "$CHANNEL_NAME"57 -asOrg Org5MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org7MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org5Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org7MSPanchors57.tx -channelID "$CHANNEL_NAME"57 -asOrg Org7MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
#---
#---
  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org6MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org6Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org6MSPanchors67.tx -channelID "$CHANNEL_NAME"67 -asOrg Org6MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "#######    Generating anchor peer update for Org7MSP   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile Org6Org7Channel -outputAnchorPeersUpdate \
    ./channel-artifacts/Org7MSPanchors67.tx -channelID "$CHANNEL_NAME"67 -asOrg Org7MSP
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for Org1MSP..."
    exit 1
  fi
  echo
}


# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform, e.g., darwin-amd64 or linux-amd64
OS_ARCH=$(echo "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=10
# default for delay between commands
CLI_DELAY=3
# channel name defaults to "mychannel"
CHANNEL_NAME="peach"
# use this as the default docker-compose yaml definition
COMPOSE_FILE=docker-compose-cli.yaml
#
COMPOSE_FILE_COUCH=docker-compose-couch.yaml
# org3 docker compose file
COMPOSE_FILE_ORG3=docker-compose-org3.yaml
#
# use golang as the default language for chaincode
LANGUAGE=golang
# default image tag
IMAGETAG="latest"
# Parse commandline args
if [ "$1" = "-m" ]; then # supports old usage, muscle memory is powerful!
  shift
fi
MODE=$1
shift
# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$MODE" == "up" ]; then
  EXPMODE="Starting"
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping"
elif [ "$MODE" == "restart" ]; then
  EXPMODE="Restarting"
elif [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and genesis block"
elif [ "$MODE" == "upgrade" ]; then
  EXPMODE="Upgrading the network"
else
  printHelp
  exit 1
fi

while getopts "h?c:t:d:f:s:l:i:v" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  c)
    CHANNEL_NAME=$OPTARG
    ;;
  t)
    CLI_TIMEOUT=$OPTARG
    ;;
  d)
    CLI_DELAY=$OPTARG
    ;;
  f)
    COMPOSE_FILE=$OPTARG
    ;;
  s)
    IF_COUCHDB=$OPTARG
    ;;
  l)
    LANGUAGE=$OPTARG
    ;;
  i)
    IMAGETAG=$(go env GOARCH)"-"$OPTARG
    ;;
  v)
    VERBOSE=true
    ;;
  esac
done


# Announce what was requested

if [ "${IF_COUCHDB}" == "couchdb" ]; then
  echo
  echo "${EXPMODE} for channel '${CHANNEL_NAME}' with CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds and using database '${IF_COUCHDB}'"
else
  echo "${EXPMODE} for channel '${CHANNEL_NAME}' with CLI timeout of '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds"
fi
# ask for confirmation to proceed
askProceed

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateCerts
  replacePrivateKey
  generateChannelArtifacts
elif [ "${MODE}" == "restart" ]; then ## Restart the network
  networkDown
  networkUp
elif [ "${MODE}" == "upgrade" ]; then ## Upgrade the network from version 1.1.x to 1.2.x
  upgradeNetwork
else
  printHelp
  exit 1
fi
