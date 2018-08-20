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
  CHANNEL_NAME_12="$CHANNEL_NAME"12
  CHANNEL_NAME_13="$CHANNEL_NAME"13
  CHANNEL_NAME_14="$CHANNEL_NAME"14
  CHANNEL_NAME_15="$CHANNEL_NAME"15
  CHANNEL_NAME_16="$CHANNEL_NAME"16
  CHANNEL_NAME_17="$CHANNEL_NAME"17
  CHANNEL_NAME_23="$CHANNEL_NAME"23
  CHANNEL_NAME_24="$CHANNEL_NAME"24
  CHANNEL_NAME_25="$CHANNEL_NAME"25
  CHANNEL_NAME_26="$CHANNEL_NAME"26
  CHANNEL_NAME_27="$CHANNEL_NAME"27
  CHANNEL_NAME_34="$CHANNEL_NAME"34
  CHANNEL_NAME_35="$CHANNEL_NAME"35
  CHANNEL_NAME_36="$CHANNEL_NAME"36
  CHANNEL_NAME_37="$CHANNEL_NAME"37
  CHANNEL_NAME_45="$CHANNEL_NAME"45
  CHANNEL_NAME_46="$CHANNEL_NAME"46
  CHANNEL_NAME_47="$CHANNEL_NAME"47
  CHANNEL_NAME_56="$CHANNEL_NAME"56
  CHANNEL_NAME_57="$CHANNEL_NAME"57
  CHANNEL_NAME_67="$CHANNEL_NAME"67

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

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_12 -f ./channel-artifacts/channel12.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_12 -f ./channel-artifacts/channel12.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_12' created ===================== "
  setGlobals 0 1

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_13 -f ./channel-artifacts/channel13.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_13 -f ./channel-artifacts/channel13.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_13' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_14 -f ./channel-artifacts/channel14.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANCHANNEL_NAME_14NEL_NAME_14 -f ./channel-artifacts/channel14.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_14' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_15 -f ./channel-artifacts/channel15.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_15 -f ./channel-artifacts/channel15.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_15' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_16 -f ./channel-artifacts/channel16.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_16 -f ./channel-artifacts/channel16.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_16' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_17 -f ./channel-artifacts/channel17.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_17 -f ./channel-artifacts/channel17.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_17' created ===================== "
  setGlobals 0 2

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_23 -f ./channel-artifacts/channel23.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_23 -f ./channel-artifacts/channel23.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_23' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_24 -f ./channel-artifacts/channel24.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_24 -f ./channel-artifacts/channel24.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_24' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_25 -f ./channel-artifacts/channel25.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_25 -f ./channel-artifacts/channel25.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_25' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_26 -f ./channel-artifacts/channel26.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_26 -f ./channel-artifacts/channel26.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_26' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_27 -f ./channel-artifacts/channel27.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_27 -f ./channel-artifacts/channel27.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_27' created ===================== "
  setGlobals 0 3

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_34 -f ./channel-artifacts/channel34.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_34 -f ./channel-artifacts/channel34.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_34' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_35 -f ./channel-artifacts/channel35.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_35 -f ./channel-artifacts/channel35.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_35' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_36 -f ./channel-artifacts/channel36.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_36 -f ./channel-artifacts/channel36.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_36' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_37 -f ./channel-artifacts/channel37.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_37 -f ./channel-artifacts/channel37.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_37' created ===================== "
  setGlobals 0 4

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_45 -f ./channel-artifacts/channel45.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_45 -f ./channel-artifacts/channel45.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_45' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_46 -f ./channel-artifacts/channel46.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_46 -f ./channel-artifacts/channel46.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_46' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_47 -f ./channel-artifacts/channel47.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_47 -f ./channel-artifacts/channel47.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_47' created ===================== "
  setGlobals 0 5

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_56 -f ./channel-artifacts/channel56.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_56 -f ./channel-artifacts/channel56.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_56' created ===================== "

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_57 -f ./channel-artifacts/channel57.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_57 -f ./channel-artifacts/channel57.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_57' created ===================== "
  setGlobals 0 6

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_67 -f ./channel-artifacts/channel67.tx >&log.txt
    res=$?
                set +x
  else
        set -x
    peer channel create -o orderer.peach.com:7050 -c $CHANNEL_NAME_67 -f ./channel-artifacts/channel67.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
        set +x
  fi
  cat log.txt
  verifyResult $res "Channel creation failed"
  echo "===================== Channel '$CHANNEL_NAME_67' created ===================== "
}

joinChannel () {
  CHANNEL_NAME_12="$CHANNEL_NAME"12
  CHANNEL_NAME_13="$CHANNEL_NAME"13
  CHANNEL_NAME_14="$CHANNEL_NAME"14
  CHANNEL_NAME_15="$CHANNEL_NAME"15
  CHANNEL_NAME_16="$CHANNEL_NAME"16
  CHANNEL_NAME_17="$CHANNEL_NAME"17
  CHANNEL_NAME_23="$CHANNEL_NAME"23
  CHANNEL_NAME_24="$CHANNEL_NAME"24
  CHANNEL_NAME_25="$CHANNEL_NAME"25
  CHANNEL_NAME_26="$CHANNEL_NAME"26
  CHANNEL_NAME_27="$CHANNEL_NAME"27
  CHANNEL_NAME_34="$CHANNEL_NAME"34
  CHANNEL_NAME_35="$CHANNEL_NAME"35
  CHANNEL_NAME_36="$CHANNEL_NAME"36
  CHANNEL_NAME_37="$CHANNEL_NAME"37
  CHANNEL_NAME_45="$CHANNEL_NAME"45
  CHANNEL_NAME_46="$CHANNEL_NAME"46
  CHANNEL_NAME_47="$CHANNEL_NAME"47
  CHANNEL_NAME_56="$CHANNEL_NAME"56
  CHANNEL_NAME_57="$CHANNEL_NAME"57
  CHANNEL_NAME_67="$CHANNEL_NAME"67
	for org in 1 2 3 4 5 6 7; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org $CHANNEL_NAME
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    done
	done
  for org in 1 2; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_12
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_12' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 1 3; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_13
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_13' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 1 4; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_14
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_14' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 1 5; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_15
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_15' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 1 6; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_16
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_16' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 1 7; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_17
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_17' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 2 3; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_23
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_23' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 2 4; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_24
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_24' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 2 5; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_25
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_25' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 2 6; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_26
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_26' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 2 7; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_27
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_27' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 3 4; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_34
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_34' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 3 5; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_35
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_35' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 3 6; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_36
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_36' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 3 7; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_37
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_37' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 4 5; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_45
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_45' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 4 6; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_46
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_46' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 4 7; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_47
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_47' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 5 6; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_56
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_56' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 5 7; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_57
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_57' ===================== "
    sleep $DELAY
    echo
      done
  done
  for org in 6 7; do
      for peer in 0 1; do
    joinChannelWithRetry $peer $org $CHANNEL_NAME_67
    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME_67' ===================== "
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
CHANNEL_NAME_12="$CHANNEL_NAME"12
CHANNEL_NAME_13="$CHANNEL_NAME"13
CHANNEL_NAME_14="$CHANNEL_NAME"14
CHANNEL_NAME_15="$CHANNEL_NAME"15
CHANNEL_NAME_16="$CHANNEL_NAME"16
CHANNEL_NAME_17="$CHANNEL_NAME"17
CHANNEL_NAME_23="$CHANNEL_NAME"23
CHANNEL_NAME_24="$CHANNEL_NAME"24
CHANNEL_NAME_25="$CHANNEL_NAME"25
CHANNEL_NAME_26="$CHANNEL_NAME"26
CHANNEL_NAME_27="$CHANNEL_NAME"27
CHANNEL_NAME_34="$CHANNEL_NAME"34
CHANNEL_NAME_35="$CHANNEL_NAME"35
CHANNEL_NAME_36="$CHANNEL_NAME"36
CHANNEL_NAME_37="$CHANNEL_NAME"37
CHANNEL_NAME_45="$CHANNEL_NAME"45
CHANNEL_NAME_46="$CHANNEL_NAME"46
CHANNEL_NAME_47="$CHANNEL_NAME"47
CHANNEL_NAME_56="$CHANNEL_NAME"56
CHANNEL_NAME_57="$CHANNEL_NAME"57
CHANNEL_NAME_67="$CHANNEL_NAME"67
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1 $CHANNEL_NAME

echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2 $CHANNEL_NAME

echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3 $CHANNEL_NAME

echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4 $CHANNEL_NAME

echo "Updating anchor peers for org5..."
updateAnchorPeers 0 5 $CHANNEL_NAME

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6 $CHANNEL_NAME

echo "Updating anchor peers for org7..."
updateAnchorPeers 0 7 $CHANNEL_NAME

# Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1 $CHANNEL_NAME_12 "12"

echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2 $CHANNEL_NAME_12 "12"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1 $CHANNEL_NAME_13 "13"

echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3 $CHANNEL_NAME_13 "13"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1 $CHANNEL_NAME_14 "14"

echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4 $CHANNEL_NAME_14 "14"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1 $CHANNEL_NAME_15 "15"

echo "Updating anchor peers for org5..."
updateAnchorPeers 0 5 $CHANNEL_NAME_15 "15"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1 $CHANNEL_NAME_16 "16"

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6 $CHANNEL_NAME_16 "16"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1..."
updateAnchorPeers 0 1 $CHANNEL_NAME_17 "17"

echo "Updating anchor peers for org7..."
updateAnchorPeers 0 7 $CHANNEL_NAME_17 "17"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2 $CHANNEL_NAME_23 "23"

echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3 $CHANNEL_NAME_23 "23"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2 $CHANNEL_NAME_24 "24"

echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4 $CHANNEL_NAME_24 "24"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2 $CHANNEL_NAME_25 "25"

echo "Updating anchor peers for org5..."
updateAnchorPeers 0 5 $CHANNEL_NAME_25 "25"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2 $CHANNEL_NAME_26 "26"

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6 $CHANNEL_NAME_26 "26"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org2..."
updateAnchorPeers 0 2 $CHANNEL_NAME_27 "27"

echo "Updating anchor peers for org7..."
updateAnchorPeers 0 7 $CHANNEL_NAME_27 "27"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3 $CHANNEL_NAME_34 "34"

echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4 $CHANNEL_NAME_34 "34"

## Set the anchor peers for each org in the channel

echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3 $CHANNEL_NAME_35 "35"

echo "Updating anchor peers for org5..."
updateAnchorPeers 0 5 $CHANNEL_NAME_35 "35"

## Set the anchor peers for each org in the channel

echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3 $CHANNEL_NAME_36 "36"

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6 $CHANNEL_NAME_36 "36"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org3..."
updateAnchorPeers 0 3 $CHANNEL_NAME_37 "37"

echo "Updating anchor peers for org7..."
updateAnchorPeers 0 7 $CHANNEL_NAME_37 "37"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4 $CHANNEL_NAME_45 "45"

echo "Updating anchor peers for org5..."
updateAnchorPeers 0 5 $CHANNEL_NAME_45 "45"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4 $CHANNEL_NAME_46 "46"

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6 $CHANNEL_NAME_46 "46"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org4..."
updateAnchorPeers 0 4 $CHANNEL_NAME_47 "47"

echo "Updating anchor peers for org7..."
updateAnchorPeers 0 7 $CHANNEL_NAME_47 "47"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org5..."
updateAnchorPeers 0 5 $CHANNEL_NAME_56 "56"

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6 $CHANNEL_NAME_56 "56"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org4..."
updateAnchorPeers 0 5 $CHANNEL_NAME_57 "57"

echo "Updating anchor peers for org6..."
updateAnchorPeers 0 7 $CHANNEL_NAME_57 "57"

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org6..."
updateAnchorPeers 0 6 $CHANNEL_NAME_67 "67"

echo "Updating anchor peers for org7..."
updateAnchorPeers 0 7 $CHANNEL_NAME_67 "67"

# Installing chaincode on each peer 0 in each org
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

# # Instantiate chaincode on peer0.org1
echo "Instantiating chaincode on peer0.org1... peach"
instantiateChaincode 0 1 1.0 $CHANNEL_NAME

echo "Instantiating chaincode on peer0.org1... peach12"
instantiateChaincode 0 1 1.0 $CHANNEL_NAME_12

echo "Instantiating chaincode on peer0.org1... peach13"
instantiateChaincode 0 1 1.0 $CHANNEL_NAME_13

echo "Instantiating chaincode on peer0.org1... peach14"
instantiateChaincode 0 1 1.0 $CHANNEL_NAME_14

echo "Instantiating chaincode on peer0.org1... peach15"
instantiateChaincode 0 1 1.0 $CHANNEL_NAME_15

echo "Instantiating chaincode on peer0.org1... peach16"
instantiateChaincode 0 1 1.0 $CHANNEL_NAME_16

echo "Instantiating chaincode on peer0.org1... peach17"
instantiateChaincode 0 1 1.0 $CHANNEL_NAME_17

echo "Instantiating chaincode on peer0.org2... peach23"
instantiateChaincode 0 2 1.0 $CHANNEL_NAME_23

echo "Instantiating chaincode on peer0.org2... peach24"
instantiateChaincode 0 2 1.0 $CHANNEL_NAME_24

echo "Instantiating chaincode on peer0.org2... peach25"
instantiateChaincode 0 2 1.0 $CHANNEL_NAME_25

echo "Instantiating chaincode on peer0.org2... peach26"
instantiateChaincode 0 2 1.0 $CHANNEL_NAME_26

echo "Instantiating chaincode on peer0.org2... peach27"
instantiateChaincode 0 2 1.0 $CHANNEL_NAME_27

echo "Instantiating chaincode on peer0.org3... peach34"
instantiateChaincode 0 3 1.0 $CHANNEL_NAME_34

echo "Instantiating chaincode on peer0.org3... peach35"
instantiateChaincode 0 3 1.0 $CHANNEL_NAME_35

echo "Instantiating chaincode on peer0.org3... peach36"
instantiateChaincode 0 3 1.0 $CHANNEL_NAME_36

echo "Instantiating chaincode on peer0.org3... peach37"
instantiateChaincode 0 3 1.0 $CHANNEL_NAME_37

echo "Instantiating chaincode on peer0.org4... peach45"
instantiateChaincode 0 4 1.0 $CHANNEL_NAME_45

echo "Instantiating chaincode on peer0.org4... peach46"
instantiateChaincode 0 4 1.0 $CHANNEL_NAME_46

echo "Instantiating chaincode on peer0.org4... peach47"
instantiateChaincode 0 4 1.0 $CHANNEL_NAME_47

echo "Instantiating chaincode on peer0.org5... peach56"
instantiateChaincode 0 5 1.0 $CHANNEL_NAME_56

echo "Instantiating chaincode on peer0.org5... peach57"
instantiateChaincode 0 5 1.0 $CHANNEL_NAME_57

echo "Instantiating chaincode on peer0.org6... peach67"
instantiateChaincode 0 6 1.0 $CHANNEL_NAME_67

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
