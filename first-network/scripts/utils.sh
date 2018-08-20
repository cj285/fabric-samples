#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/peach.com/orderers/orderer.peach.com/msp/tlscacerts/tlsca.peach.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.peach.com/peers/peer0.org1.peach.com/tls/ca.crt
PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.peach.com/peers/peer0.org2.peach.com/tls/ca.crt
PEER0_ORG3_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.peach.com/peers/peer0.org3.peach.com/tls/ca.crt
PEER0_ORG4_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.peach.com/peers/peer0.org4.peach.com/tls/ca.crt
PEER0_ORG5_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.peach.com/peers/peer0.org5.peach.com/tls/ca.crt
PEER0_ORG6_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.peach.com/peers/peer0.org6.peach.com/tls/ca.crt
PEER0_ORG7_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org7.peach.com/peers/peer0.org7.peach.com/tls/ca.crt

# verify the result of the end-to-end test
verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/peach.com/orderers/orderer.peach.com/msp/tlscacerts/tlsca.peach.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/peach.com/users/Admin@peach.com/msp
}

setGlobals() {
  PEER=$1
  ORG=$2
  if [ $ORG -eq 1 ]; then
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.peach.com/users/Admin@org1.peach.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org1.peach.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org1.peach.com:7051
    fi

  elif [ $ORG -eq 2 ]; then
    CORE_PEER_LOCALMSPID="Org2MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.peach.com/users/Admin@org2.peach.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org2.peach.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org2.peach.com:7051
    fi

  elif [ $ORG -eq 3 ]; then
    CORE_PEER_LOCALMSPID="Org3MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.peach.com/users/Admin@org3.peach.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org3.peach.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org3.peach.com:7051
    fi

  elif [ $ORG -eq 4 ]; then
    CORE_PEER_LOCALMSPID="Org4MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG4_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.peach.com/users/Admin@org4.peach.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org4.peach.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org4.peach.com:7051
    fi

  elif [ $ORG -eq 5 ]; then
    CORE_PEER_LOCALMSPID="Org5MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG5_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.peach.com/users/Admin@org5.peach.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org5.peach.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org5.peach.com:7051
    fi

  elif [ $ORG -eq 6 ]; then
    CORE_PEER_LOCALMSPID="Org6MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG6_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.peach.com/users/Admin@org6.peach.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org6.peach.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org6.peach.com:7051
    fi

  elif [ $ORG -eq 7 ]; then
    CORE_PEER_LOCALMSPID="Org7MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG7_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org7.peach.com/users/Admin@org7.peach.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org7.peach.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org7.peach.com:7051
    fi

  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

updateAnchorPeers() {
  PEER=$1
  ORG=$2
  MY_CHANNEL_NAME=$3
  setGlobals $PEER $ORG

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o orderer.peach.com:7050 -c $MY_CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors"$4".tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o orderer.peach.com:7050 -c $MY_CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors"$4".tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$MY_CHANNEL_NAME' ===================== "
  sleep $DELAY
  echo
}

## Sometimes Join takes time hence RETRY at least 5 times
joinChannelWithRetry() {
  PEER=$1
  ORG=$2
  MY_CHANNEL_NAME=$3
  setGlobals $PEER $ORG

  set -x
  peer channel join -b $MY_CHANNEL_NAME.block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$MY_CHANNEL_NAME' "
}

installChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}
  set -x
  peer chaincode install -n ficc -v ${VERSION} -l ${LANGUAGE} -p ${CC_SRC_PATH} >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
  echo
}

instantiateChaincode() {
  PEER=$1
  ORG=$2
  MY_CHANNEL_NAME=$4
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}
  MSP_PEERS=""
  if [ $MY_CHANNEL_NAME = "peach" ]; then
    MSP_PEERS="OR ('Org1MSP.peer','Org2MSP.peer', 'Org3MSP.peer', 'Org4MSP.peer', 'Org5MSP.peer', 'Org6MSP.peer', 'Org7MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach12" ]; then
    MSP_PEERS="OR ('Org1MSP.peer','Org2MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach13" ]; then
    MSP_PEERS="OR ('Org1MSP.peer', 'Org3MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach14" ]; then
    MSP_PEERS="OR ('Org1MSP.peer', 'Org4MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach15" ]; then
    MSP_PEERS="OR ('Org1MSP.peer', 'Org5MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach16" ]; then
    MSP_PEERS="OR ('Org1MSP.peer', 'Org6MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach17" ]; then
    MSP_PEERS="OR ('Org1MSP.peer', 'Org7MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach23" ]; then
    MSP_PEERS="OR ('Org2MSP.peer', 'Org3MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach24" ]; then
    MSP_PEERS="OR ('Org2MSP.peer', 'Org4MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach25" ]; then
    MSP_PEERS="OR ('Org2MSP.peer', 'Org5MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach26" ]; then
    MSP_PEERS="OR ('Org2MSP.peer', 'Org6MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach27" ]; then
    MSP_PEERS="OR ('Org2MSP.peer', 'Org7MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach34" ]; then
    MSP_PEERS="OR ('Org3MSP.peer', 'Org4MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach35" ]; then
    MSP_PEERS="OR ('Org3MSP.peer', 'Org5MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach36" ]; then
    MSP_PEERS="OR ('Org3MSP.peer', 'Org6MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach37" ]; then
    MSP_PEERS="OR ('Org3MSP.peer', 'Org7MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach45" ]; then
    MSP_PEERS="OR ('Org4MSP.peer', 'Org5MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach46" ]; then
    MSP_PEERS="OR ('Org4MSP.peer', 'Org6MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach47" ]; then
    MSP_PEERS="OR ('Org4MSP.peer', 'Org7MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach56" ]; then
    MSP_PEERS="OR ('Org5MSP.peer', 'Org6MSP.peer')"
  elif [ $MY_CHANNEL_NAME = "peach57" ]; then
    MSP_PEERS="OR ('Org5MSP.peer', 'Org7MSP.peer')"
  else
    MSP_PEERS="OR ('Org6MSP.peer', 'Org7MSP.peer')"
  fi

  # while 'peer chaincode' command can get the orderer endpoint from the peer
  # (if join was successful), let's supply it directly as we know it using
  # the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode instantiate -o orderer.peach.com:7050 -C $MY_CHANNEL_NAME -n ficc -l ${LANGUAGE} -v ${VERSION} -c '{"Args":[""]}' -P "$MSP_PEERS">&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode instantiate -o orderer.peach.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $MY_CHANNEL_NAME -n ficc -l ${LANGUAGE} -v 1.0 -c '{"Args":[""]}' -P "$MSP_PEERS">&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$MY_CHANNEL_NAME' failed"
  echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$MY_CHANNEL_NAME' ===================== "
  echo
}

upgradeChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG

  set -x
  peer chaincode upgrade -o orderer.peach.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode upgrade on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is upgraded on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo
}

chaincodeQuery() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  EXPECTED_RESULT=$3
  echo "===================== Querying on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
  local rc=1
  local starttime=$(date +%s)

  # continue to poll
  # we either get a successful response, or reach TIMEOUT
  while
    test "$(($(date +%s) - starttime))" -lt "$TIMEOUT" -a $rc -ne 0
  do
    sleep $DELAY
    echo "Attempting to Query peer${PEER}.org${ORG} ...$(($(date +%s) - starttime)) secs"
    set -x
    peer chaincode query -C $CHANNEL_NAME -n ficc -c '{"Args":["getPayload","init"]}' >&log.txt
    res=$?
    set +x
    test $res -eq 0 && VALUE=$(cat log.txt)
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
    # removed the string "Query Result" from peer chaincode query command
    # result. as a result, have to support both options until the change
    # is merged.
    test $rc -ne 0 && VALUE=$(cat log.txt | egrep '^[0-9]+$')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
  done
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  else
    echo "GOT $VALUE EXPECTED $EXPECTED_RESULT"
    echo "!!!!!!!!!!!!!!! Query result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
    echo
    exit 1
  fi
}

# fetchChannelConfig <channel_id> <output_json>
# Writes the current channel config for a given channel to a JSON file
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=$2

  setOrdererGlobals

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel fetch config config_block.pb -o orderer.peach.com:7050 -c $CHANNEL --cafile $ORDERER_CA
    set +x
  else
    set -x
    peer channel fetch config config_block.pb -o orderer.peach.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
    set +x
  fi

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  set +x
}

# signConfigtxAsPeerOrg <org> <configtx.pb>
# Set the peerOrg admin of an org and signing the config update
signConfigtxAsPeerOrg() {
  PEERORG=$1
  TX=$2
  setGlobals 0 $PEERORG
  set -x
  peer channel signconfigtx -f "${TX}"
  set +x
}

# createConfigUpdate <channel_id> <original_config.json> <modified_config.json> <output.pb>
# Takes an original and modified config, and produces the config update tx
# which transitions between the two
createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb >config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${OUTPUT}"
  set +x
}

# parsePeerConnectionParameters $@
# Helper function that takes the parameters from a chaincode operation
# (e.g. invoke, query, instantiate) and checks for an even number of
# peers and associated org, then sets $PEER_CONN_PARMS and $PEERS
parsePeerConnectionParameters() {
  # check for uneven number of peer and org parameters
  if [ $(($# % 2)) -ne 0 ]; then
    exit 1
  fi

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    PEER="peer$1.org$2"
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $PEER.peach.com:7051"
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "true" ]; then
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER$1_ORG$2_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    fi
    # shift by two to get the next pair of peer/org parameters
    shift
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

# chaincodeInvoke <peer> <org> ...
# Accepts as many peer/org pairs as desired and requests endorsement from each
chaincodeModify() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Modify transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.peach.com:7050 -C $CHANNEL_NAME -n ficc $PEER_CONN_PARMS -c '{"Args":["modifyPayload", "init", "modifiedInit"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.peach.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ficc $PEER_CONN_PARMS -c '{"Args":["modifyPayload", "init", "modifiedInit"]}' >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
}

# chaincodeInvoke <peer> <org> ...
# Accepts as many peer/org pairs as desired and requests endorsement from each
chaincodeSet() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Set transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o orderer.peach.com:7050 -C $CHANNEL_NAME -n ficc $PEER_CONN_PARMS -c '{"Args":["createPayload", "init", "testInit"]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o orderer.peach.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ficc $PEER_CONN_PARMS -c '{"Args":["createPayload", "init", "testInit"]}' >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
}
