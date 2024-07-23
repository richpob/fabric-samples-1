go install golang.org/x/tools/gopls@latest
go mod init studentchaincode
go get github.com/hyperledger/fabric-contract-api-go/contractapi
go mod tidy
GO111MODULE=on go mod vendor

go install golang.org/x/tools/gopls@latest 

  
  
  # Se empaqueta Chaincode
go list -json -mod=mod
peer lifecycle chaincode package toll.tar.gz --path chaincodes/ --lang golang --label toll_1.0

  # Paso 11: Adherir Contrato a MOP
  export FABRIC_CFG_PATH=${PWD}/../config
  export CORE_PEER_TLS_ENABLED=true
  export PEER0_IEBS_CA=${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="IebsMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_IEBS_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
peer lifecycle chaincode install toll.tar.gz 

  

    # Paso 12: Adherir Contrato  CantabriaMSP
  export FABRIC_CFG_PATH=${PWD}/../config
  export PEER0_RUTA78_CA=${PWD}/organizations/peerOrganizations/cantabria.universidades.com/peers/peer0.cantabria.universidades.com/tls/ca.crt
  export CORE_PEER_LOCALMSPID="CantabriaMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RUTA78_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/cantabria.universidades.com/users/Admin@cantabria.universidades.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
peer lifecycle chaincode install toll.tar.gz 

peer lifecycle chaincode queryinstalled

//copiar el ID del package, es una combinación del nombre del chaincode y el hash del contenido del código
export CC_PACKAGE_ID=toll_1.0:01466b191f54d341ed51be76037e082ee70d8131dbf1f1b3350f2e679138d443
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --channelID mychannel --signature-policy "OR('IebsMSP.member','CantabriaMSP.member')" --name studentchaincode --version 2.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem
  export FABRIC_CFG_PATH=${PWD}/../config
  export CORE_PEER_LOCALMSPID="IebsMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_IEBS_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --channelID mychannel --signature-policy "OR('IebsMSP.member','CantabriaMSP.member')" --name studentchaincode --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name  --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem --output json
  export FABRIC_CFG_PATH=${PWD}/../config
  export CORE_PEER_LOCALMSPID="CantabriaMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RUTA78_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/cantabria.universidades.com/users/Admin@cantabria.universidades.com/msp
  export CORE_PEER_ADDRESS=localhost:9051

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --channelID mychannel --signature-policy "OR('IebsMSP.member','CantabriaMSP.member')" --name studentchaincode --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name studentchaincode --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem --output json

export CORE_PEER_LOCALMSPID="IebsMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_IEBS_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --signature-policy "OR('IebsMSP.member','CantabriaMSP.member')" --channelID mychannel --name studentchaincode --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/cantabria.universidades.com/peers/peer0.cantabria.universidades.com/tls/ca.crt

peer lifecycle chaincode querycommitted --channelID mychannel --name studentchaincode --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

//probar el chaincode Toll 
  export FABRIC_CFG_PATH=${PWD}/../config
  export CORE_PEER_LOCALMSPID="CantabriaMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_RUTA78_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/cantabria.universidades.com/users/Admin@cantabria.universidades.com/msp
  export CORE_PEER_ADDRESS=localhost:9051

  export FABRIC_CFG_PATH=${PWD}/../config
  export CORE_PEER_LOCALMSPID="IebsMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_IEBS_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem -C mychannel -n studentchaincode --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'

peer chaincode query -C mychannel -n studentchaincode -c '{"function":"QueryTollRecord","Args":["0xc83273f025ecEd0317f52DfE26d95C4638a10D7E"]}'

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem -C mychannel -n studentchaincode --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/cantabria.universidades.com/peers/peer0.cantabria.universidades.com/tls/ca.crt -c '{"function":"CreateAsset","Args":["asset8","green","16","Sergio","750"]}'
peer chaincode query -C mychannel -n studentchaincode -c '{"Args":["QueryTollRecord"]}'


###### NUEVO CODIGO #########
#Aprobar contrato por ambas organizaciones
export PACKAGE_ID="studentchaincode_1.0.1:8828c71ae10d2fcf183e864e55ef2540d1de31bf7d7c821ca26a1c63f030e50f"
#Org1 - Iebs
export CORE_PEER_LOCALMSPID="CantabriaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

peer lifecycle chaincode approveformyorg --orderer orderer.universidades.com:7050 --ordererTLSHostnameOverride orderer.universidades.com --channelID mychannel --name studentchaincode --version 1.0 --sequence 2 --tls --cafile $ORDERER_CA --package-id $PACKAGE_ID

#Org2 - Cantabria
export CORE_PEER_LOCALMSPID="IebsMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/path/to/iebs/peer/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/path/to/iebs/admin/msp
export CORE_PEER_ADDRESS=localhost:8051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

peer lifecycle chaincode approveformyorg --orderer orderer.universidades.com:7050 --ordererTLSHostnameOverride orderer.universidades.com --channelID mychannel --name studentchaincode --version 1.0 --sequence 2 --tls --cafile $ORDERER_CA --package-id <PACKAGE_ID>



# Por favor entregar la línea de comando para ejecutar la función InitLedger del contrato adjunto "studentchaincode". Este contrato se desplegó en Hyperledger Fabric 2.4 a través del siguiente comando `./network.sh deployCC -ccn studentchaincode -ccp ./chaincode-go -ccl go` y la red fue desplegada con el siguiente comando `./network.sh up createChannel -c mychannel -ca -s couchdb`
#Para invocar la función InitLedger del contrato studentchaincode, ejecuta el siguiente comando en la CLI de Hyperledger Fabric:
#Org1
# export PATH=${PWD}/../bin:$PATH
# export FABRIC_CFG_PATH=$PWD/../config/
# export CORE_PEER_TLS_ENABLED=true
# export CORE_PEER_LOCALMSPID="IebsMSP"
# export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt
# export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
# export CORE_PEER_ADDRESS=localhost:7051
# export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

# peer chaincode invoke -C mychannel  -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"InitLedger","Args":[]}'

# #ORG2
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="CantabriaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/cantabria.universidades.com/peers/peer0.cantabria.universidades.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/cantabria.universidades.com/users/Admin@cantabria.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:9051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

#Ejecutar funcion de Initledger
peer chaincode invoke -C mychannel  -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"InitLedger","Args":[]}'

#export PEER0_IEBS_CA=/home/ubuntu/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/msp/tlscacerts/ca.crt
export PEER0_IEBS_CA=$CORE_PEER_TLS_ROOTCERT_FILE
#/home/ubuntu/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/tlsca/tlsca.iebs.universidades.com-cert.pem


#ver chaincode aprobado por las partes
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name studentchaincode --version 1.0 --sequence 2 --tls --cafile $ORDERER_CA --output json

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --channelID mychannel --name studentchaincode --version 1.0 --sequence 2 --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_IEBS_CA


# Version 2
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="IebsMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"InitLedger","Args":[]}'

#otra prueba
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --channelID cursochannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/cantabria.universidades.com/peers/peer0.cantabria.universidades.com/tls/ca.crt