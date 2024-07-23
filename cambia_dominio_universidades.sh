#!/bin/bash

#Paso 1: Borrar instancias de Dockers y redes
#--> Borrar instalaciones previas
#docker stop $(docker ps -a -q)
docker ps -q | xargs -r docker stop
#docker rm $(docker ps -a -q)
docker ps -q | xargs -r docker rm
docker volume prune --force
docker volume prune --force
cd ~/fabric-samples/
./test-network/network.sh down

# Directorio base
BASE_DIR="/home/ubuntu/fabric-samples/universidades/"
sudo rm -R $BASE_DIR
cp -R ./test-network $BASE_DIR 
pwd

# Buscar y reemplazar recursivamente en archivos .yaml
find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/Org1/Iebs/g' {} +
find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/Org2/Cantabria/g' {} +
find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/example.com/universidades.com/g' {} +
find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/org1/iebs/g' {} +
find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/org2/cantabria/g' {} +
#find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/mychannel/universidadeschannel/g' {} +
find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/fabric_test/universidades_network/g' {} +


# Buscar y reemplazar recursivamente en archivos .sh
find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/Org1/Iebs/g' {} +
find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/Org2/Cantabria/g' {} +
find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/example.com/universidades.com/g' {} +
find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/org1/iebs/g' {} +
find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/org2/cantabria/g' {} +
#find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/mychannel/universidadeschannel/g' {} +
find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/fabric_test/universidades_network/g' {} +

cd $BASE_DIR 
./network.sh down
./network.sh up createChannel -c mychannel -ca
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go

# Buscar y reemplazar recursivamente en archivos .yml y . json
find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/Org1/Iebs/g' {} +
# ts json yml js
BASE_DIR="/home/ubuntu/fabric-samples/universidades/blockchain-explorer"
find $BASE_DIR -type f -name "*.json" -exec sed -i 's/Org1/Iebs/g' {} +
find $BASE_DIR -type f -name "*.json" -exec sed -i 's/Org2/Cantabria/g' {} +
find $BASE_DIR -type f -name "*.json" -exec sed -i 's/example.com/universidades.com/g' {} +
find $BASE_DIR -type f -name "*.json" -exec sed -i 's/org1/iebs/g' {} +
find $BASE_DIR -type f -name "*.json" -exec sed -i 's/org2/cantabria/g' {} +
find $BASE_DIR -type f -name "*.json" -exec sed -i 's/fabric_test/universidades_netwok/g' {} +

find $BASE_DIR -type f -name "*.yml" -exec sed -i 's/Org1/Iebs/g' {} +
find $BASE_DIR -type f -name "*.yml" -exec sed -i 's/Org2/Cantabria/g' {} +
find $BASE_DIR -type f -name "*.yml" -exec sed -i 's/example.com/universidades.com/g' {} +
find $BASE_DIR -type f -name "*.yml" -exec sed -i 's/org1/iebs/g' {} +
find $BASE_DIR -type f -name "*.yml" -exec sed -i 's/org2/cantabria/g' {} +
find $BASE_DIR -type f -name "*.yml" -exec sed -i 's/fabric_test/universidades_netwok/g' {} +

#Copiar certificados que tienen otro nombre
#"path": "/tmp/crypto/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/signcerts/User1@iebs.universidades.com-cert.pem"
#  "path": "/tmp/crypto/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/keystore/priv_sk"

rm ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/signcerts/User1@iebs.universidades.com-cert.pem
rm ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/keystore/priv_sk
cp ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/signcerts/cert.pem ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/signcerts/User1@iebs.universidades.com-cert.pem
cp $(find ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/keystore -name "*sk" | head -n 1) ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/keystore/priv_sk


# Buscar y reemplazar recursivamente en archivos .yaml test-network
# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/cantabria.universidadesiebs.com/ruta78.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/iebs.universidadesiebs.com/mop.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/universidadesiebs.com/autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/universidadesiebs.com/autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/universidades_g7/autopistas_g7/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/cantabria.autopistasmop.com/ruta78.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/iebs.autopistasmop.com/mop.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/universidadeschannel/autopistaschannel/g' {} +
# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/universidadeschannel/autopistaschannel/g' {} +
# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/universidades_g7/autopistas_g7/g' {} +

# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/universidadesg7_network/autopistas_g7_network/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/universidadesg7_network/autopistas_g7_network/g' {} +

# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/orderer.example.com/orderer.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/peer0.org1.example.com/peer0.mop.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/peer0.org2.example.com/peer0.ruta78.autopistasmop.com/g' {} +

# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/orderer.example.com/orderer.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/peer0.org1.example.com/peer0.mop.autopistasmop.com/g' {} +
# find $BASE_DIR -type f -name "*.yaml" -exec sed -i 's/peer0.org2.example.com/peer0.ruta78.autopistasmop.com/g' {} +

# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/docker-compose-universidades/docker-compose-autopistas/g' {} +

  
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/crypto-config-iebs/crypto-config-mop/g' {} +
# find $BASE_DIR -type f -name "*.sh" -exec sed -i 's/crypto-config-cantabria/crypto-config-ruta78/g' {} +
  

# echo "Reemplazo completado en todos los archivos .yaml y .sh dentro del directorio $BASE_DIR"

# echo Buscar y renombrar archivos .sh y .yaml que contengan "iebs" en el nombre
# find $BASE_DIR -type f \( -name '*iebs*.sh' -o -name '*iebs*.yaml' \) | while read -r file; do
#     # Obtener el nuevo nombre reemplazando "iebs" por "mop"
#     new_name=$(echo "$file" | sed 's/iebs/mop/g')
#     # Renombrar el archivo
#     mv "$file" "$new_name"
# done

# echo Buscar y renombrar archivos .sh y .yaml que contengan "cantabria" en el nombre
# find $BASE_DIR -type f \( -name '*cantabria*.sh' -o -name '*cantabria*.yaml' \) | while read -r file; do
#     # Obtener el nuevo nombre reemplazando "cantabria" por "ruta78"
#     new_name=$(echo "$file" | sed 's/cantabria/ruta78/g')
#     # Renombrar el archivo
#     mv "$file" "$new_name"
# done

# echo Buscar y renombrar archivos .sh y .yaml que contengan "universidades" en el nombre
# find $BASE_DIR -type f \( -name '*universidades*.sh' -o -name '*universidades*.yaml' \) | while read -r file; do
#     # Obtener el nuevo nombre reemplazando "universidades" por "autopistas"
#     new_name=$(echo "$file" | sed 's/universidades/autopistas/g')
#     # Renombrar el archivo
#     mv "$file" "$new_name"
# done

# echo "Renombrado completado."
# rm ./autopistas_g7/configtx/configtx.yaml 
# rm ./autopistas_g7/docker/docker-compose*
# rm ./autopistas_g7/install_autopistas.sh 

# echo "Copia de fichero modificados MSP. Compose e Install"
# cp ./Otros/configtx.yaml ./autopistas_g7/configtx/
# cp ./Otros/docker-compose-autopistas.yaml ./autopistas_g7/docker/
# cp ./Otros/install_autopistas.sh ./autopistas_g7/