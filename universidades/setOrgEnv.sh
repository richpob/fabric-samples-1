#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using Iebs
ORG=${1:-Iebs}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/test-network/organizations/ordererOrganizations/universidades.com/tlsca/tlsca.universidades.com-cert.pem
PEER0_ORG1_CA=${DIR}/test-network/organizations/peerOrganizations/iebs.universidades.com/tlsca/tlsca.iebs.universidades.com-cert.pem
PEER0_ORG2_CA=${DIR}/test-network/organizations/peerOrganizations/cantabria.universidades.com/tlsca/tlsca.cantabria.universidades.com-cert.pem
PEER0_ORG3_CA=${DIR}/test-network/organizations/peerOrganizations/org3.universidades.com/tlsca/tlsca.org3.universidades.com-cert.pem


if [[ ${ORG,,} == "iebs" || ${ORG,,} == "digibank" ]]; then

   CORE_PEER_LOCALMSPID=IebsMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/iebs.universidades.com/tlsca/tlsca.iebs.universidades.com-cert.pem

elif [[ ${ORG,,} == "cantabria" || ${ORG,,} == "magnetocorp" ]]; then

   CORE_PEER_LOCALMSPID=CantabriaMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/cantabria.universidades.com/users/Admin@cantabria.universidades.com/msp
   CORE_PEER_ADDRESS=localhost:9051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/cantabria.universidades.com/tlsca/tlsca.cantabria.universidades.com-cert.pem

else
   echo "Unknown \"$ORG\", please choose Iebs/Digibank or Cantabria/Magnetocorp"
   echo "For example to get the environment variables to set upa Cantabria shell environment run:  ./setOrgEnv.sh Cantabria"
   echo
   echo "This can be automated to set them as well with:"
   echo
   echo 'export $(./setOrgEnv.sh Cantabria | xargs)'
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_ORG1_CA=${PEER0_ORG1_CA}"
echo "PEER0_ORG2_CA=${PEER0_ORG2_CA}"
echo "PEER0_ORG3_CA=${PEER0_ORG3_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"
