#Levantar red de Universidades y Hyperledger explorer
cd blockchain-explorer/
docker-compose down
cd ..
./network.sh down
docker volume rm blockchain-explorer_pgdata
docker volume rm blockchain-explorer_walletstore

./network.sh up createChannel -c mychannel -ca -s couchdb

cd blockchain-explorer/
bash copia_certificados.sh 
docker-compose -f docker-compose.yaml up -d
cd ..

#Despliegue del contrato 
  #go get github.com/hyperledger/fabric-contract-api-go/contractapi
  #go install golang.org/x/tools/gopls@latest
  #go mod init studentchaincode  
  #go get github.com/hyperledger/fabric-contract-api-go/contractapi
  #go mod tidy
  #GO111MODULE=on go mod vendor
    
./network.sh deployCC -ccn studentchaincode -ccp ./chaincode-go -ccl go -c mychannel > deploy.log
#'^studentchaincode_1.0.1:8828c71ae10d2fcf183e864e55ef2540d1de31bf7d7c821ca26a1c63f030e50f$'
	  
