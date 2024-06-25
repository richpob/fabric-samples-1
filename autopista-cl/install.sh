# INSTALAR RED UNIVERSITARIA
#Paso 1: Borrar instancias de Dockers y redes
--> Borrar instalaciones previas
#docker stop $(docker ps -a -q)
docker ps -q | xargs -r docker stop
#docker rm $(docker ps -a -q)
docker ps -q | xargs -r docker rm
docker volume prune --force
docker volume prune --force

./network.sh down

#git clone https://github.com/hyperledger/fabric-samples.git
#cd fabric-samples/test-network

export PATH=${PWD}/../bin:${PWD}:$PATH
./network.sh up createChannel -c mychannel -ca
./network.sh deployCC -ccn mycc -ccp ../chaincode/tollcontract -ccl go
