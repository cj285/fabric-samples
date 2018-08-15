#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build your first network (BYFN) end-to-end test"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="peach"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5

CC_SRC_PATH="github.com/chaincode/iin/go/"

echo "Channel name : "$CHANNEL_NAME

# import utils
. scripts/utils.sh

createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

joinChannel () {
	for org in 1 2 3 4 5 6 7; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    done
	done
}

## Create channel
echo "Creating channel..."
createChannel

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1

echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2

echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3

echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4

echo "Updating anchor peers for org5..."
updateAnchorPeers 0 5

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6

echo "Updating anchor peers for org7..."
updateAnchorPeers 0 7

## Installing chaincode on each peer 0 in each org
echo "Install chaincode on peer0.org1..."
installChaincode 0 1

echo "Install chaincode on peer0.org2..."
installChaincode 0 2

echo "Install chaincode on peer0.org3..."
installChaincode 0 3

echo "Install chaincode on peer0.org4..."
installChaincode 0 4

echo "Install chaincode on peer0.org5..."
installChaincode 0 5

echo "Install chaincode on peer0.org6..."
installChaincode 0 6

echo "Install chaincode on peer0.org7..."
installChaincode 0 7

echo "Install chaincode on peer1.org1..."
installChaincode 1 1

echo "Install chaincode on peer1.org2..."
installChaincode 1 2

echo "Install chaincode on peer1.org3..."
installChaincode 1 3

echo "Install chaincode on peer1.org4..."
installChaincode 1 4

echo "Install chaincode on peer1.org5..."
installChaincode 1 5

echo "Install chaincode on peer1.org6..."
installChaincode 1 6

echo "Install chaincode on peer1.org7..."
installChaincode 1 7

# Instantiate chaincode on peer0.org1
echo "Instantiating chaincode on peer0.org1..."
instantiateChaincode 0 1

# sleep 10

# # Invoke chaincode on peer0.org1 and peer0.org2
# echo "Sending invoke (set) transaction on peer0.org1 peer0.org2..."
# chaincodeSet 0 1 0 2

# # Query chaincode on peer0.org1
# echo "Querying chaincode on peer0.org1..."
# chaincodeQuery 0 1 '{"payload":"testInit"}'

# # Invoke chaincode on peer0.org1 and peer0.org2
# echo "Sending invoke (modify) transaction on peer1.org3 peer0.org2..."
# chaincodeModify 0 1 0 2

# ## Query on all other peer 1 in all organization
# # Query on chaincode on peer1.org1, check if the result is 90
# echo "Querying chaincode on peer1.org1..."
# chaincodeQuery 1 1 '{"payload":"modifiedInit"}'

# # Query on chaincode on peer1.org2, check if the result is 90
# echo "Querying chaincode on peer1.org2..."
# chaincodeQuery 1 2 '{"payload":"modifiedInit"}'

# # Query on chaincode on peer1.org3, check if the result is 90
# echo "Querying chaincode on peer1.org3..."
# chaincodeQuery 1 3 '{"payload":"modifiedInit"}'

# # Query on chaincode on peer1.org4, check if the result is 90
# echo "Querying chaincode on peer1.org4..."
# chaincodeQuery 1 4 '{"payload":"modifiedInit"}'

# # Query on chaincode on peer1.org5, check if the result is 90
# echo "Querying chaincode on peer1.org5..."
# chaincodeQuery 1 5 '{"payload":"modifiedInit"}'

# # Query on chaincode on peer1.org6, check if the result is 90
# echo "Querying chaincode on peer1.org6..."
# chaincodeQuery 1 6 '{"payload":"modifiedInit"}'

# # Query on chaincode on peer1.org7, check if the result is 90
# echo "Querying chaincode on peer1.org7..."
# chaincodeQuery 1 7 '{"payload":"modifiedInit"}'

echo
echo "========= All GOOD, BYFN execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
