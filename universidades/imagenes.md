# 1. Evidencias del despliegue Red Universitaria y Chaincode
## Hyerledger Explorer
### Dashboard
![image](https://github.com/user-attachments/assets/fda89f7c-7f0d-4443-9761-c06405bba46e)
### Network
![image](https://github.com/user-attachments/assets/ba8337e7-35b8-4657-ab7d-24e2b39ea0ce)
### Bloques
![image](https://github.com/user-attachments/assets/c6b7d624-bc96-4906-88b2-74b59c644669)
### Transacciones
![image](https://github.com/user-attachments/assets/6b491c0b-84e7-4484-bd51-dc1eb17f1e93)
#### TX de InitLedger
![image](https://github.com/user-attachments/assets/1a53153d-4690-43ba-b4e9-0da539ca5aaa)
#### TX de Nuevo registo
![image](https://github.com/user-attachments/assets/caaf3555-7cb4-4aa7-af23-e00a1588b7a7)
#### TX de Cambio de Universidad
![image](https://github.com/user-attachments/assets/5ae18b58-0f58-4e85-8b82-b895467812a0)
#### TX de Consulta de Alumno
![image](https://github.com/user-attachments/assets/275d0e63-6d9b-4031-8b52-59732162e499)
### Chaincode 
![image](https://github.com/user-attachments/assets/a18e69fa-66ae-453e-87c6-a7d89776910a)
### Canales
![image](https://github.com/user-attachments/assets/94397482-3fea-41d9-9b6c-a6c0ecc4a0a2)

## CouchDB
### Regitros en la Base de Datos
![image](https://github.com/user-attachments/assets/b72400e7-302a-44a6-862b-40288a071142)
### Registro de nuevo alumno
![image](https://github.com/user-attachments/assets/ac2d3a73-ac10-4286-b8e4-c568b54bd228)
### Cambio de Universidad
![image](https://github.com/user-attachments/assets/0ec2f186-0c21-4270-9675-ae6531508d40)

# Ambiente de desarrollo
## VS Code
![image](https://github.com/user-attachments/assets/ee5ed2bf-dfdd-4642-81d7-e6b8554c7126)
## Compementos docker y despliegue de instancia y volumnes de la red universitaria, Hyperledger Explorer y chaincode
![image](https://github.com/user-attachments/assets/d2a532ff-0f36-4959-ae12-d50d01051f15)

# Codigos Fuentes
## Smart Contract o Chaincoude StudentChaincode.go
```go lang
package main

import (
    "encoding/json"
    "fmt"

    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// StudentChaincode implementation of Chaincode
type StudentChaincode struct {
    contractapi.Contract
}

// Student describes basic details of a student
type Student struct {
    ID        string `json:"id"`
    Name      string `json:"name"`
    University string `json:"university"`
}

// InitLedger adds a base set of students to the ledger
func (s *StudentChaincode) InitLedger(ctx contractapi.TransactionContextInterface) error {
    students := []Student{
        {ID: "1", Name: "John Doe", University: "IEBS"},
        {ID: "2", Name: "Jane Smith", University: "Cantabria"},
    }

    for _, student := range students {
        studentJSON, err := json.Marshal(student)
        if err != nil {
            return err
        }

        err = ctx.GetStub().PutState(student.ID, studentJSON)
        if err != nil {
            return fmt.Errorf("failed to put to world state. %s", err.Error())
        }
    }

    return nil
}

// RegisterStudent adds a new student to the ledger
func (s *StudentChaincode) RegisterStudent(ctx contractapi.TransactionContextInterface, id string, name string, university string) error {
    student := Student{
        ID:        id,
        Name:      name,
        University: university,
    }

    studentJSON, err := json.Marshal(student)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(id, studentJSON)
}

// TransferStudent transfers a student from one university to another
func (s *StudentChaincode) TransferStudent(ctx contractapi.TransactionContextInterface, id string, newUniversity string) error {
    studentJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return fmt.Errorf("failed to read from world state: %v", err)
    }
    if studentJSON == nil {
        return fmt.Errorf("student %s does not exist", id)
    }

    var student Student
    err = json.Unmarshal(studentJSON, &student)
    if err != nil {
        return err
    }

    student.University = newUniversity

    studentJSON, err = json.Marshal(student)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(id, studentJSON)
}

// QueryStudent returns the student stored in the world state with given id
func (s *StudentChaincode) QueryStudent(ctx contractapi.TransactionContextInterface, id string) (*Student, error) {
    studentJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return nil, fmt.Errorf("failed to read from world state: %v", err)
    }
    if studentJSON == nil {
        return nil, fmt.Errorf("student %s does not exist", id)
    }

    var student Student
    err = json.Unmarshal(studentJSON, &student)
    if err != nil {
        return nil, err
    }

    return &student, nil
}

func main() {
    chaincode, err := contractapi.NewChaincode(new(StudentChaincode))
    if err != nil {
        fmt.Printf("Error create chaincode: %s", err.Error())
        return
    }

    if err := chaincode.Start(); err != nil {
        fmt.Printf("Error starting chaincode: %s", err.Error())
    }
}

```
## Script sh de creacion ambiente Hyperledger Fabric 2.5 y Explorer
``` bash
#Levantar red de Universidades y Hyperledger explorer
cd blockchain-explorer/
docker-compose down
cd ..
./network.sh down
docker volume rm blockchain-explorer_pgdata
docker volume rm blockchain-explorer_walletstore

./network.sh up createChannel -c mychannel -ca -s couchdb
#Copiar certificados que tienen otro nombre para Explorer
rm ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/signcerts/User1@iebs.universidades.com-cert.pem
rm ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/keystore/priv_sk
cp ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/signcerts/cert.pem ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/signcerts/User1@iebs.universidades.com-cert.pem
cp $(find ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/keystore -name "*sk" | head -n 1) ~/fabric-samples/universidades/organizations/peerOrganizations/iebs.universidades.com/users/User1@iebs.universidades.com/msp/keystore/priv_sk

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

```
## Script de TX de funcciones del smartcontract 
``` bash
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

###### CODIGO PARA INTERACTUAR CON CONTRATO#########
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

# Ejercicios con Registros 
#Se ha cambiado la politica de endorsement a ANY, para que baste solo una organizacion para escribir
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="IebsMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

#Se crean los registros iniciales del contrato InitLedger
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"InitLedger","Args":[]}'

#se crea un tercer alumno para la universidad IEBS
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"InitLedger","Args":[]}'

#Se cambia el primer elemento desde la universidad IEBS a Cantabria
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"InitLedger","Args":[]}'


#######
#Comandos "peer" para Ejecutar las Funciones
#1. Registrar un Estudiante (RegisterStudent)
#Para registrar un estudiante con ID "3", nombre "Richard Poblete" y universidad "IEBS":
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"RegisterStudent","Args":["3","Richard Poblete","IEBS"]}'

#2. Transferir un Estudiante (TransferStudent)
#Para transferir un estudiante con ID "1" a la universidad "Cantabria":
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"TransferStudent","Args":["1","Cantabria"]}'

#3. Consultar un Estudiante (QueryStudent)
#Para consultar la información de un estudiante con ID "1":
peer chaincode query -C mychannel -n studentchaincode -c '{"Args":["QueryStudent","1"]}'
```
## Log de la ejecucion de los SH (instalacion de ambiente e interaccion con chaincode student
``` bash
[0;34mUsing docker and docker-compose[0m
[0;34mStopping network[0m
[0;34mRemoving remaining containers[0m
[0;34mRemoving generated chaincode docker images[0m
Untagged: dev-peer0.cantabria.universidades.com-studentchaincode_1.0.1-8828c71ae10d2fcf183e864e55ef2540d1de31bf7d7c821ca26a1c63f030e50f-a6f6be16be2743a3428953522fc6fb6e2c79a75f88b5529ac98a384e5af97910:latest
Deleted: sha256:b30c98f0a5f49b8b267ddc2d974071f8edc6f5fa534201439035ac12e8ebd649
Deleted: sha256:b9bf8b3a56b68e77f256925246119caa8355655287982f5e756677da8c3a2598
Deleted: sha256:06c2ab96ee7210b82b16273bd01041c082fd5f66c71ad4d9d37351117402aceb
Deleted: sha256:ea18ec54aad7773ffea1821ca048bfb8a317a45a03942794265cf2581bd4eeb3
Untagged: dev-peer0.iebs.universidades.com-studentchaincode_1.0.1-8828c71ae10d2fcf183e864e55ef2540d1de31bf7d7c821ca26a1c63f030e50f-52d7c2b80dabe94e1c4baae701129671da0853e60c58e60fbd32e2e17149f0a6:latest
Deleted: sha256:2e76e8ce48575b2502d8ac605ebe29a248acdd128076a0f480a08d7f3aee4762
Deleted: sha256:842129e9181dc7e831b0c5aa31f7bb59de3c9d236c84d8a9fd677d5c3e5ffc2d
Deleted: sha256:114fdada83aeab78f4ab6bd258caacfb104b06c0a7c774e89fb1947a70b6b2b0
Deleted: sha256:ed8389c113751f22f2247ede7af73c3dd3e96fce557d448d6e7cf96ca1d80d05
blockchain-explorer_pgdata
blockchain-explorer_walletstore
[0;34mUsing docker and docker-compose[0m
[0;34mCreating channel 'mychannel'.[0m
[0;34mIf network is not up, starting nodes with CLI timeout of '5' tries and CLI delay of '3' seconds and using database 'couchdb with crypto from 'Certificate Authorities'[0m
[0;34mBringing up network[0m
[0;34mLOCAL_VERSION=v2.5.9[0m
[0;34mDOCKER_IMAGE_VERSION=v2.5.9[0m
[0;34mCA_LOCAL_VERSION=v1.5.12[0m
[0;34mCA_DOCKER_IMAGE_VERSION=v1.5.12[0m
[0;34mGenerating certificates using Fabric CA[0m
 Network universidades_network  Creating
 Network universidades_network  Created
 Container ca_iebs  Creating
 Container ca_orderer  Creating
 Container ca_cantabria  Creating
 Container ca_orderer  Created
 Container ca_cantabria  Created
 Container ca_iebs  Created
 Container ca_orderer  Starting
 Container ca_cantabria  Starting
 Container ca_iebs  Starting
 Container ca_cantabria  Started
 Container ca_iebs  Started
 Container ca_orderer  Started
[0;34mCreating Iebs Identities[0m
[0;34mEnrolling the CA admin[0m
[0;34mRegistering peer0[0m
Password: peer0pw
[0;34mRegistering user[0m
Password: user1pw
[0;34mRegistering the org admin[0m
Password: iebsadminpw
[0;34mGenerating the peer0 msp[0m
[0;34mGenerating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names[0m
[0;34mGenerating the user msp[0m
[0;34mGenerating the org admin msp[0m
[0;34mCreating Cantabria Identities[0m
[0;34mEnrolling the CA admin[0m
[0;34mRegistering peer0[0m
Password: peer0pw
[0;34mRegistering user[0m
Password: user1pw
[0;34mRegistering the org admin[0m
Password: cantabriaadminpw
[0;34mGenerating the peer0 msp[0m
[0;34mGenerating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names[0m
[0;34mGenerating the user msp[0m
[0;34mGenerating the org admin msp[0m
[0;34mCreating Orderer Org Identities[0m
[0;34mEnrolling the CA admin[0m
[0;34mRegistering orderer[0m
Password: ordererpw
[0;34mRegistering the orderer admin[0m
Password: ordererAdminpw
[0;34mGenerating the orderer msp[0m
[0;34mGenerating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names[0m
[0;34mGenerating the admin msp[0m
[0;34mGenerating CCP files for Iebs and Cantabria[0m
 Volume "compose_orderer.universidades.com"  Creating
 Volume "compose_orderer.universidades.com"  Created
 Volume "compose_peer0.cantabria.universidades.com"  Creating
 Volume "compose_peer0.cantabria.universidades.com"  Created
 Volume "compose_peer0.iebs.universidades.com"  Creating
 Volume "compose_peer0.iebs.universidades.com"  Created
time="2024-07-23T16:26:36-04:00" level=warning msg="Found orphan containers ([ca_cantabria ca_orderer ca_iebs]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up."
 Container couchdb0  Creating
 Container orderer.universidades.com  Creating
 Container couchdb1  Creating
 Container orderer.universidades.com  Created
 Container couchdb1  Created
 Container couchdb0  Created
 Container peer0.cantabria.universidades.com  Creating
 Container peer0.iebs.universidades.com  Creating
 Container peer0.iebs.universidades.com  Created
 Container peer0.cantabria.universidades.com  Created
 Container orderer.universidades.com  Starting
 Container couchdb0  Starting
 Container couchdb1  Starting
 Container orderer.universidades.com  Started
 Container couchdb1  Started
 Container couchdb0  Started
 Container peer0.cantabria.universidades.com  Starting
 Container peer0.iebs.universidades.com  Starting
 Container peer0.cantabria.universidades.com  Started
 Container peer0.iebs.universidades.com  Started
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS                  PORTS                                                                                                                             NAMES
076942d23094   hyperledger/fabric-peer:latest      "peer node start"        3 seconds ago    Up Less than a second   0.0.0.0:9051->9051/tcp, :::9051->9051/tcp, 7051/tcp, 0.0.0.0:9445->9445/tcp, :::9445->9445/tcp                                    peer0.cantabria.universidades.com
bcfd013a5836   hyperledger/fabric-peer:latest      "peer node start"        3 seconds ago    Up Less than a second   0.0.0.0:7051->7051/tcp, :::7051->7051/tcp, 0.0.0.0:9444->9444/tcp, :::9444->9444/tcp                                              peer0.iebs.universidades.com
c10b16bf11fe   couchdb:3.3.3                       "tini -- /docker-ent…"   6 seconds ago    Up Less than a second   4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp, :::7984->5984/tcp                                                                     couchdb1
7739bf3c67da   couchdb:3.3.3                       "tini -- /docker-ent…"   6 seconds ago    Up Less than a second   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp, :::5984->5984/tcp                                                                     couchdb0
23623548969a   hyperledger/fabric-orderer:latest   "orderer"                6 seconds ago    Up Less than a second   0.0.0.0:7050->7050/tcp, :::7050->7050/tcp, 0.0.0.0:7053->7053/tcp, :::7053->7053/tcp, 0.0.0.0:9443->9443/tcp, :::9443->9443/tcp   orderer.universidades.com
38d66c2491e9   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   15 seconds ago   Up 10 seconds           0.0.0.0:8054->8054/tcp, :::8054->8054/tcp, 7054/tcp, 0.0.0.0:18054->18054/tcp, :::18054->18054/tcp                                ca_cantabria
c6d2426dd651   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   15 seconds ago   Up 10 seconds           0.0.0.0:9054->9054/tcp, :::9054->9054/tcp, 7054/tcp, 0.0.0.0:19054->19054/tcp, :::19054->19054/tcp                                ca_orderer
2ad2dd1082cd   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   15 seconds ago   Up 10 seconds           0.0.0.0:7054->7054/tcp, :::7054->7054/tcp, 0.0.0.0:17054->17054/tcp, :::17054->17054/tcp                                          ca_iebs
[0;34mUsing docker and docker-compose[0m
[0;34mGenerating channel genesis block 'mychannel.block'[0m
[0;34mUsing organization 1[0m
/home/ubuntu/fabric-samples/universidades/../bin/configtxgen
[0;34mCreating channel mychannel[0m
[0;34mAdding orderers[0m
Status: 201
{
	"name": "mychannel",
	"url": "/participation/v1/channels/mychannel",
	"consensusRelation": "consenter",
	"status": "active",
	"height": 1
}

[0;32mChannel 'mychannel' created[0m
[0;34mJoining iebs peer to the channel...[0m
[0;34mUsing organization 1[0m
[34m2024-07-23 16:26:49.006 -04 0001 INFO[0m [channelCmd] [34;1mInitCmdFactory[0m -> Endorser and orderer connections initialized
[34m2024-07-23 16:26:49.057 -04 0002 INFO[0m [channelCmd] [34;1mexecuteJoin[0m -> Successfully submitted proposal to join channel
[0;34mJoining cantabria peer to the channel...[0m
[0;34mUsing organization 2[0m
[34m2024-07-23 16:26:52.120 -04 0001 INFO[0m [channelCmd] [34;1mInitCmdFactory[0m -> Endorser and orderer connections initialized
[34m2024-07-23 16:26:52.173 -04 0002 INFO[0m [channelCmd] [34;1mexecuteJoin[0m -> Successfully submitted proposal to join channel
[0;34mSetting anchor peer for iebs...[0m
[0;34mUsing organization 1[0m
[0;34mFetching channel config for channel mychannel[0m
[0;34mUsing organization 1[0m
[0;34mFetching the most recent configuration block for the channel[0m
[0;34mDecoding config block to JSON and isolating config to /home/ubuntu/fabric-samples/universidades/channel-artifacts/IebsMSPconfig.json[0m
[0;34mGenerating anchor peer update transaction for Org1 on channel mychannel[0m
[34m2024-07-23 16:26:52.403 -04 0001 INFO[0m [channelCmd] [34;1mInitCmdFactory[0m -> Endorser and orderer connections initialized
[34m2024-07-23 16:26:52.411 -04 0002 INFO[0m [channelCmd] [34;1mupdate[0m -> Successfully submitted channel update
[0;32mAnchor peer set for org 'IebsMSP' on channel 'mychannel'[0m
[0;34mSetting anchor peer for cantabria...[0m
[0;34mUsing organization 2[0m
[0;34mFetching channel config for channel mychannel[0m
[0;34mUsing organization 2[0m
[0;34mFetching the most recent configuration block for the channel[0m
[0;34mDecoding config block to JSON and isolating config to /home/ubuntu/fabric-samples/universidades/channel-artifacts/CantabriaMSPconfig.json[0m
[0;34mGenerating anchor peer update transaction for Org2 on channel mychannel[0m
[34m2024-07-23 16:26:52.655 -04 0001 INFO[0m [channelCmd] [34;1mInitCmdFactory[0m -> Endorser and orderer connections initialized
[34m2024-07-23 16:26:52.664 -04 0002 INFO[0m [channelCmd] [34;1mupdate[0m -> Successfully submitted channel update
[0;32mAnchor peer set for org 'CantabriaMSP' on channel 'mychannel'[0m
[0;32mChannel 'mychannel' joined[0m
ubuntu@ubuntu:~/fabric-samples/universidades$ export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="IebsMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/iebs.universidades.com/peers/peer0.iebs.universidades.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/iebs.universidades.com/users/Admin@iebs.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem
ubuntu@ubuntu:~/fabric-samples/universidades$ peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"InitLedger","Args":[]}'
2024-07-23 17:22:56.718 -04 0001 INFO [chaincodeCmd] chaincodeInvokeOrQuery -> Chaincode invoke successful. result: status:200 

ubuntu@ubuntu:~/fabric-samples/universidades$ peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"RegisterStudent","Args":["3","Richard Poblete","IEBS"]}'
2024-07-23 17:39:16.212 -04 0001 INFO [chaincodeCmd] chaincodeInvokeOrQuery -> Chaincode invoke successful. result: status:200 
ubuntu@ubuntu:~/fabric-samples/universidades$ peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C mychannel -n studentchaincode -c '{"function":"TransferStudent","Args":["1","Cantabria"]}'
2024-07-23 17:40:04.230 -04 0001 INFO [chaincodeCmd] chaincodeInvokeOrQuery -> Chaincode invoke successful. result: status:200 
ubuntu@ubuntu:~/fabric-samples/universidades$ peer chaincode query -C mychannel -n studentchaincode -c '{"Args":["QueryStudent","1"]}'
{"id":"1","name":"John Doe","university":"Cantabria"}

``` 

# 2. Implementacion de Red Hyperledger 2.2 y ejecucion de caliper
## Interpretación General delos resultados obtenidos
### Eficiencia:
La prueba muestra una alta eficiencia con 3000 transacciones exitosas y ninguna fallida.
### Rendimiento:
El rendimiento de 330.1 TPS indica que el sistema pudo manejar 330.1 transacciones completas por segundo, lo cual es un buen indicador de capacidad.
### Latencia:
Las latencias máxima y promedio son muy bajas (0.01 segundos), lo que sugiere un sistema muy rápido y con baja latencia.
En resumen, los resultados indican que la operación readAsset se ejecutó de manera eficiente y rápida, con un alto rendimiento y una latencia mínima.

## Resultado Fast dos
![image](https://github.com/user-attachments/assets/1246be3b-0550-42db-b078-49f3c28a5b27)

## Resultado Fast
![image](https://github.com/user-attachments/assets/69b001d6-86a3-4eb6-893f-75f8a4be3417)

## Resultado primera ejecucion
![image](https://github.com/user-attachments/assets/9ed72cf9-4d18-402d-962c-ba1728e0f525)

## Script sh
``` bash
#Instalación de Hyperledger Fabric 2.2
#Preparar el entorno:

sudo apt update
sudo apt install -y curl docker.io docker-compose
#Instalar Go:

wget https://golang.org/dl/go1.16.3.linux-amd64.tar.gz
sudo tar -xvf go1.16.3.linux-amd64.tar.gz -C /usr/local
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
#Descargar Hyperledger Fabric Samples:
mkdir -p ~/fabric-samples
cd ~/fabric-samples
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.0
#Levantar la Red de Prueba
#Iniciar la red:
cd ~/fabric-samples/test-network
./network.sh up createChannel -c mychannel -ca

#Desplegar el Chaincode Basic
#Desplegar el chaincode:
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go

#Verificar la Implementación
#Consultar el chaincode:
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'


############################################################
HYPERLEDGER CALIPER

//CLONAR LA VERSIÓN ESPECÍFICA DE FABRIC-SAMPLES CON LA QUE FUNCIONA CALIPER 2.2.0
mkdir ~/caliper
cd ~/caliper

//CREAR EL WORKSPACE DE CALIPER
cd ~/caliper
mkdir ~/caliper/caliper-workspace

cd ~/caliper/caliper-workspace

mkdir networks
mkdir benchmarks
mkdir workload

npm install --only=prod @hyperledger/caliper-cli@0.4.2

npx caliper bind --caliper-bind-sut fabric:2.2

//CREAR EL FICHER DE CONEXIÓN DE CALIPER CONTRA FABRIC
vi networks/networkConfig.yaml

name: Calier test
version: "2.0.0"

caliper:
  blockchain: fabric

channels:
  - channelName: mychannel
    contracts:
    - id: basic

organizations:
  - mspid: Org1MSP
    identities:
      certificates:
      - name: 'User1'
        clientPrivateKey:
          path: '../fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore/priv_sk'
        clientSignedCert:
          path: '../fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem'
    connectionProfile:
      path: '../fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/connection-org1.yaml'
      discover: true



//CREAR EL ARCHIVO DE TESTS
vi workload/readAsset.js 

'use strict';

const { WorkloadModuleBase } = require('@hyperledger/caliper-core');

class MyWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }
    
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);

        for (let i=0; i<this.roundArguments.assets; i++) {
            const assetID = `${this.workerIndex}_${i}`;
            console.log(`Worker ${this.workerIndex}: Creating asset ${assetID}`);
            const request = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'CreateAsset',
                invokerIdentity: 'User1',
                contractArguments: [assetID,'blue','20','penguin','500'],
                readOnly: false
            };

            await this.sutAdapter.sendRequests(request);
        }
    }
    
    async submitTransaction() {
        const randomId = Math.floor(Math.random()*this.roundArguments.assets);
        const myArgs = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'ReadAsset',
            invokerIdentity: 'User1',
            contractArguments: [`${this.workerIndex}_${randomId}`],
            readOnly: true
        };

        await this.sutAdapter.sendRequests(myArgs);
    }
    
    async cleanupWorkloadModule() {
        for (let i=0; i<this.roundArguments.assets; i++) {
            const assetID = `${this.workerIndex}_${i}`;
            console.log(`Worker ${this.workerIndex}: Deleting asset ${assetID}`);
            const request = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'DeleteAsset',
                invokerIdentity: 'User1',
                contractArguments: [assetID],
                readOnly: false
            };

            await this.sutAdapter.sendRequests(request);
        }
    }
}

function createWorkloadModule() {
    return new MyWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;


//CREAR EL ARCHIVO DE BENCHMARKING
vi benchmarks/myAssetBenchmark.yaml 

test:
    name: basic-contract-benchmark
    description: test benchmark
    workers:
      type: local
      number: 2
    rounds:
      - label: readAsset
        description: Read asset benchmark
        txDuration: 30
        rateControl: 
          type: fixed-load
          opts:
            transactionLoad: 2
        workload:
          module: workload/readAsset.js
          arguments:
            assets: 10
            contractId: basic


//LANZAR LAS PRUEBAS
cd ~/caliper/caliper-workspace
npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmark.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled


//DESCARGAR EL REPO PARA VISUALIZARLO


//SEGUNDA PRUEBA - MÁS TRANSACCIONES
cp benchmarks/myAssetBenchmark.yaml benchmarks/myAssetBenchmarkFast.yaml

-> subir las TPS -> cambiar txDuration por txNumber y aumentar los workers y los assets creados
vi benchmarks/myAssetBenchmarkFast.yam


test:
    name: basic-contract-benchmark
    description: test benchmark
    workers:
      type: local
      number: 3
    rounds:
      - label: readAsset
        description: Read asset benchmark
        txNumber: 300
        rateControl:
          type: fixed-load
          opts:
            transactionLoad: 2
        workload:
          module: workload/readAsset.js
          arguments:
            assets: 40
            contractId: basic


//LANZAR LA NUEVA CONFIGURACIÓN
npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmarkFast.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled


//CAMBIAMOS PORQUE ERAN POCAS TRANSACCIONES
-> Bajamos worker y aumentamos transacciones 
cp benchmarks/myAssetBenchmarkFast.yaml benchmarks/myAssetBenchmarkFastDos.yaml
vi benchmarks/myAssetBenchmarkFastDos.yaml

test:
    name: basic-contract-benchmark
    description: test benchmark
    workers:
      type: local
      number: 2
    rounds:
      - label: readAsset
        description: Read asset benchmark
        txNumber: 3000
        rateControl:
          type: fixed-load
          opts:
            transactionLoad: 2
        workload:
          module: workload/readAsset.js
          arguments:
            assets: 40
            contractId: basic

-> Comparar con los otros tests 

npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmarkFastDos.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled
``` 
## Log de ejecucion
``` log
ubuntu@ubuntu:~/caliper/fabric-samples/test-network$ ./network.sh up createChannel -c mychannel
Creating channel 'mychannel'.
If network is not up, starting nodes with CLI timeout of '5' tries and CLI delay of '3' seconds and using database 'leveldb with crypto from 'cryptogen'
Bringing up network
LOCAL_VERSION=2.2.0
DOCKER_IMAGE_VERSION=v2.5.9
Local fabric binaries and docker images are out of  sync. This may cause problems.
/home/ubuntu/caliper/fabric-samples/test-network/../bin/cryptogen
Generating certificates using cryptogen tool
Creating Org1 Identities
+ cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output=organizations
org1.example.com
+ res=0
Creating Org2 Identities
+ cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output=organizations
org2.example.com
+ res=0
Creating Orderer Org Identities
+ cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output=organizations
+ res=0
Generating CCP files for Org1 and Org2
/home/ubuntu/caliper/fabric-samples/test-network/../bin/configtxgen
Generating Orderer Genesis block
+ configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
2024-07-23 22:59:10.506 -04 [common.tools.configtxgen] main -> INFO 001 Loading configuration
2024-07-23 22:59:10.522 -04 [common.tools.configtxgen.localconfig] completeInitialization -> INFO 002 orderer type: etcdraft
2024-07-23 22:59:10.522 -04 [common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 Orderer.EtcdRaft.Options unset, setting to tick_interval:"500ms" election_tick:10 heartbeat_tick:1 max_inflight_blocks:5 snapshot_interval_size:16777216 
2024-07-23 22:59:10.522 -04 [common.tools.configtxgen.localconfig] Load -> INFO 004 Loaded configuration: /home/ubuntu/caliper/fabric-samples/test-network/configtx/configtx.yaml
2024-07-23 22:59:10.524 -04 [common.tools.configtxgen] doOutputBlock -> INFO 005 Generating genesis block
2024-07-23 22:59:10.524 -04 [common.tools.configtxgen] doOutputBlock -> INFO 006 Writing genesis block
+ res=0
[+] Running 8/8
 ⠿ Network fabric_test                     Created                                                                                       0.1s
 ⠿ Volume "docker_peer0.org1.example.com"  Created                                                                                       0.0s
 ⠿ Volume "docker_peer0.org2.example.com"  Created                                                                                       0.0s
 ⠿ Volume "docker_orderer.example.com"     Created                                                                                       0.0s
 ⠿ Container peer0.org2.example.com        Started                                                                                       8.6s
 ⠿ Container orderer.example.com           Started                                                                                       8.6s
 ⠿ Container peer0.org1.example.com        Started                                                                                       8.6s
 ⠿ Container cli                           Started                                                                                       7.3s
CONTAINER ID   IMAGE                               COMMAND             CREATED         STATUS                  PORTS                                                                                                NAMES
9dab54423e56   hyperledger/fabric-tools:latest     "/bin/bash"         7 seconds ago   Up Less than a second                                                                                                        cli
a4833068ac3e   hyperledger/fabric-orderer:latest   "orderer"           9 seconds ago   Up Less than a second   0.0.0.0:7050->7050/tcp, :::7050->7050/tcp, 0.0.0.0:17050->17050/tcp, :::17050->17050/tcp             orderer.example.com
555db7f50f57   hyperledger/fabric-peer:latest      "peer node start"   9 seconds ago   Up Less than a second   0.0.0.0:7051->7051/tcp, :::7051->7051/tcp, 0.0.0.0:17051->17051/tcp, :::17051->17051/tcp             peer0.org1.example.com
2e4676fe117b   hyperledger/fabric-peer:latest      "peer node start"   9 seconds ago   Up Less than a second   0.0.0.0:9051->9051/tcp, :::9051->9051/tcp, 7051/tcp, 0.0.0.0:19051->19051/tcp, :::19051->19051/tcp   peer0.org2.example.com
Generating channel create transaction 'mychannel.tx'
+ configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel
2024-07-23 22:59:19.569 -04 [common.tools.configtxgen] main -> INFO 001 Loading configuration
2024-07-23 22:59:19.589 -04 [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /home/ubuntu/caliper/fabric-samples/test-network/configtx/configtx.yaml
2024-07-23 22:59:19.589 -04 [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 003 Generating new channel configtx
2024-07-23 22:59:19.592 -04 [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 004 Writing new channel tx
+ res=0
Creating channel mychannel
Using organization 1
+ peer channel create -o localhost:7050 -c mychannel --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls --cafile /home/ubuntu/caliper/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
+ res=0
2024-07-23 22:59:22.660 -04 [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2024-07-23 22:59:22.675 -04 [cli.common] readBlock -> INFO 002 Expect block, but got status: &{NOT_FOUND}
2024-07-23 22:59:22.676 -04 [channelCmd] InitCmdFactory -> INFO 003 Endorser and orderer connections initialized
2024-07-23 22:59:22.879 -04 [cli.common] readBlock -> INFO 004 Expect block, but got status: &{SERVICE_UNAVAILABLE}
2024-07-23 22:59:22.883 -04 [channelCmd] InitCmdFactory -> INFO 005 Endorser and orderer connections initialized
2024-07-23 22:59:23.086 -04 [cli.common] readBlock -> INFO 006 Expect block, but got status: &{SERVICE_UNAVAILABLE}
2024-07-23 22:59:23.091 -04 [channelCmd] InitCmdFactory -> INFO 007 Endorser and orderer connections initialized
2024-07-23 22:59:23.293 -04 [cli.common] readBlock -> INFO 008 Expect block, but got status: &{SERVICE_UNAVAILABLE}
2024-07-23 22:59:23.299 -04 [channelCmd] InitCmdFactory -> INFO 009 Endorser and orderer connections initialized
2024-07-23 22:59:23.501 -04 [cli.common] readBlock -> INFO 00a Expect block, but got status: &{SERVICE_UNAVAILABLE}
2024-07-23 22:59:23.508 -04 [channelCmd] InitCmdFactory -> INFO 00b Endorser and orderer connections initialized
2024-07-23 22:59:23.714 -04 [cli.common] readBlock -> INFO 00c Received block: 0
Channel 'mychannel' created
Joining org1 peer to the channel...
Using organization 1
+ peer channel join -b ./channel-artifacts/mychannel.block
+ res=0
2024-07-23 22:59:26.766 -04 [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2024-07-23 22:59:26.783 -04 [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
Joining org2 peer to the channel...
Using organization 2
+ peer channel join -b ./channel-artifacts/mychannel.block
+ res=0
2024-07-23 22:59:29.830 -04 [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2024-07-23 22:59:29.847 -04 [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
Setting anchor peer for org1...
Using organization 1
Fetching channel config for channel mychannel
Using organization 1
Fetching the most recent configuration block for the channel
+ peer channel fetch config config_block.pb -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
2024-07-24 02:59:29.948 UTC 0001 INFO [channelCmd] InitCmdFactory -> Endorser and orderer connections initialized
2024-07-24 02:59:29.949 UTC 0002 INFO [cli.common] readBlock -> Received block: 0
2024-07-24 02:59:29.949 UTC 0003 INFO [channelCmd] fetch -> Retrieving last config block: 0
2024-07-24 02:59:29.950 UTC 0004 INFO [cli.common] readBlock -> Received block: 0
Decoding config block to JSON and isolating config to Org1MSPconfig.json
+ configtxlator proto_decode --input config_block.pb --type common.Block
+ jq '.data.data[0].payload.data.config'
Generating anchor peer update transaction for Org1 on channel mychannel
+ jq '.channel_group.groups.Application.groups.Org1MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org1.example.com","port": 7051}]},"version": "0"}}' Org1MSPconfig.json
+ configtxlator proto_encode --input Org1MSPconfig.json --type common.Config
+ configtxlator proto_encode --input Org1MSPmodified_config.json --type common.Config
+ configtxlator compute_update --channel_id mychannel --original original_config.pb --updated modified_config.pb
+ configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate
+ jq .
++ cat config_update.json
+ echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":{' '"channel_id":' '"mychannel",' '"isolated_data":' '{},' '"read_set":' '{' '"groups":' '{' '"Application":' '{' '"groups":' '{' '"Org1MSP":' '{' '"groups":' '{},' '"mod_policy":' '"",' '"policies":' '{' '"Admins":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Endorsement":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Readers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Writers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '}' '},' '"values":' '{' '"MSP":' '{' '"mod_policy":' '"",' '"value":' null, '"version":' '"0"' '}' '},' '"version":' '"0"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"1"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"0"' '},' '"write_set":' '{' '"groups":' '{' '"Application":' '{' '"groups":' '{' '"Org1MSP":' '{' '"groups":' '{},' '"mod_policy":' '"Admins",' '"policies":' '{' '"Admins":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Endorsement":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Readers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Writers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '}' '},' '"values":' '{' '"AnchorPeers":' '{' '"mod_policy":' '"Admins",' '"value":' '{' '"anchor_peers":' '[' '{' '"host":' '"peer0.org1.example.com",' '"port":' 7051 '}' ']' '},' '"version":' '"0"' '},' '"MSP":' '{' '"mod_policy":' '"",' '"value":' null, '"version":' '"0"' '}' '},' '"version":' '"1"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"1"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"0"' '}' '}}}}'
+ configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope
2024-07-24 02:59:30.136 UTC 0001 INFO [channelCmd] InitCmdFactory -> Endorser and orderer connections initialized
2024-07-24 02:59:30.145 UTC 0002 INFO [channelCmd] update -> Successfully submitted channel update
Anchor peer set for org 'Org1MSP' on channel 'mychannel'
Setting anchor peer for org2...
Using organization 2
Fetching channel config for channel mychannel
Using organization 2
Fetching the most recent configuration block for the channel
+ peer channel fetch config config_block.pb -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
2024-07-24 02:59:30.273 UTC 0001 INFO [channelCmd] InitCmdFactory -> Endorser and orderer connections initialized
2024-07-24 02:59:30.275 UTC 0002 INFO [cli.common] readBlock -> Received block: 1
2024-07-24 02:59:30.275 UTC 0003 INFO [channelCmd] fetch -> Retrieving last config block: 1
2024-07-24 02:59:30.275 UTC 0004 INFO [cli.common] readBlock -> Received block: 1
Decoding config block to JSON and isolating config to Org2MSPconfig.json
+ configtxlator proto_decode --input config_block.pb --type common.Block
+ jq '.data.data[0].payload.data.config'
Generating anchor peer update transaction for Org2 on channel mychannel
+ jq '.channel_group.groups.Application.groups.Org2MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org2.example.com","port": 9051}]},"version": "0"}}' Org2MSPconfig.json
+ configtxlator proto_encode --input Org2MSPconfig.json --type common.Config
+ configtxlator proto_encode --input Org2MSPmodified_config.json --type common.Config
+ configtxlator compute_update --channel_id mychannel --original original_config.pb --updated modified_config.pb
+ configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate
+ jq .
++ cat config_update.json
+ echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":{' '"channel_id":' '"mychannel",' '"isolated_data":' '{},' '"read_set":' '{' '"groups":' '{' '"Application":' '{' '"groups":' '{' '"Org2MSP":' '{' '"groups":' '{},' '"mod_policy":' '"",' '"policies":' '{' '"Admins":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Endorsement":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Readers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Writers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '}' '},' '"values":' '{' '"MSP":' '{' '"mod_policy":' '"",' '"value":' null, '"version":' '"0"' '}' '},' '"version":' '"0"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"1"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"0"' '},' '"write_set":' '{' '"groups":' '{' '"Application":' '{' '"groups":' '{' '"Org2MSP":' '{' '"groups":' '{},' '"mod_policy":' '"Admins",' '"policies":' '{' '"Admins":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Endorsement":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Readers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '},' '"Writers":' '{' '"mod_policy":' '"",' '"policy":' null, '"version":' '"0"' '}' '},' '"values":' '{' '"AnchorPeers":' '{' '"mod_policy":' '"Admins",' '"value":' '{' '"anchor_peers":' '[' '{' '"host":' '"peer0.org2.example.com",' '"port":' 9051 '}' ']' '},' '"version":' '"0"' '},' '"MSP":' '{' '"mod_policy":' '"",' '"value":' null, '"version":' '"0"' '}' '},' '"version":' '"1"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"1"' '}' '},' '"mod_policy":' '"",' '"policies":' '{},' '"values":' '{},' '"version":' '"0"' '}' '}}}}'
+ configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope
2024-07-24 02:59:30.452 UTC 0001 INFO [channelCmd] InitCmdFactory -> Endorser and orderer connections initialized
2024-07-24 02:59:30.461 UTC 0002 INFO [channelCmd] update -> Successfully submitted channel update
Anchor peer set for org 'Org2MSP' on channel 'mychannel'
Channel 'mychannel' joined
ubuntu@ubuntu:~/caliper/fabric-samples/test-network$ ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go
deploying chaincode on channel 'mychannel'
executing with the following
- CHANNEL_NAME: mychannel
- CC_NAME: basic
- CC_SRC_PATH: ../asset-transfer-basic/chaincode-go
- CC_SRC_LANGUAGE: go
- CC_VERSION: 1.0
- CC_SEQUENCE: 1
- CC_END_POLICY: NA
- CC_COLL_CONFIG: NA
- CC_INIT_FCN: NA
- DELAY: 3
- MAX_RETRY: 5
- VERBOSE: false
Vendoring Go dependencies at ../asset-transfer-basic/chaincode-go
~/caliper/fabric-samples/asset-transfer-basic/chaincode-go ~/caliper/fabric-samples/test-network
~/caliper/fabric-samples/test-network
Finished vendoring Go dependencies
+ peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-go --lang golang --label basic_1.0
+ res=0
Chaincode is packaged
Installing chaincode on peer0.org1...
Using organization 1
+ peer lifecycle chaincode install basic.tar.gz
+ res=0
2024-07-23 22:59:53.187 -04 [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJbasic_1.0:3cfcf67978d6b3f7c5e0375660c995b21db19c4330946079afc3925ad7306881\022\tbasic_1.0" > 
2024-07-23 22:59:53.187 -04 [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: basic_1.0:3cfcf67978d6b3f7c5e0375660c995b21db19c4330946079afc3925ad7306881
Chaincode is installed on peer0.org1
Install chaincode on peer0.org2...
Using organization 2
+ peer lifecycle chaincode install basic.tar.gz
+ res=0
2024-07-23 23:00:08.154 -04 [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJbasic_1.0:3cfcf67978d6b3f7c5e0375660c995b21db19c4330946079afc3925ad7306881\022\tbasic_1.0" > 
2024-07-23 23:00:08.154 -04 [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: basic_1.0:3cfcf67978d6b3f7c5e0375660c995b21db19c4330946079afc3925ad7306881
Chaincode is installed on peer0.org2
Using organization 1
+ peer lifecycle chaincode queryinstalled
+ res=0
Installed chaincodes on peer:
Package ID: basic_1.0:3cfcf67978d6b3f7c5e0375660c995b21db19c4330946079afc3925ad7306881, Label: basic_1.0
Query installed successful on peer0.org1 on channel
Using organization 1
+ peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/ubuntu/caliper/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:3cfcf67978d6b3f7c5e0375660c995b21db19c4330946079afc3925ad7306881 --sequence 1
+ res=0
2024-07-23 23:00:10.261 -04 [chaincodeCmd] ClientWait -> INFO 001 txid [9f4e461fda254d1106e431d168d91dc2dc100e9405a34eae638dd835fcea0e9a] committed with status (VALID) at 
Chaincode definition approved on peer0.org1 on channel 'mychannel'
Using organization 1
Checking the commit readiness of the chaincode definition on peer0.org1 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org1, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json
+ res=0
{
        "approvals": {
                "Org1MSP": true,
                "Org2MSP": false
        }
}
Checking the commit readiness of the chaincode definition successful on peer0.org1 on channel 'mychannel'
Using organization 2
Checking the commit readiness of the chaincode definition on peer0.org2 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org2, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json
+ res=0
{
        "approvals": {
                "Org1MSP": true,
                "Org2MSP": false
        }
}
Checking the commit readiness of the chaincode definition successful on peer0.org2 on channel 'mychannel'
Using organization 2
+ peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/ubuntu/caliper/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:3cfcf67978d6b3f7c5e0375660c995b21db19c4330946079afc3925ad7306881 --sequence 1
+ res=0
2024-07-23 23:00:18.457 -04 [chaincodeCmd] ClientWait -> INFO 001 txid [1886cfed52a14dfdfe9a197b9af12240182b0b475d4a8652fc51f64d990ee02e] committed with status (VALID) at 
Chaincode definition approved on peer0.org2 on channel 'mychannel'
Using organization 1
Checking the commit readiness of the chaincode definition on peer0.org1 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org1, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json
+ res=0
{
        "approvals": {
                "Org1MSP": true,
                "Org2MSP": true
        }
}
Checking the commit readiness of the chaincode definition successful on peer0.org1 on channel 'mychannel'
Using organization 2
Checking the commit readiness of the chaincode definition on peer0.org2 on channel 'mychannel'...
Attempting to check the commit readiness of the chaincode definition on peer0.org2, Retry after 3 seconds.
+ peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --output json
+ res=0
{
        "approvals": {
                "Org1MSP": true,
                "Org2MSP": true
        }
}
Checking the commit readiness of the chaincode definition successful on peer0.org2 on channel 'mychannel'
Using organization 1
Using organization 2
+ peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /home/ubuntu/caliper/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID mychannel --name basic --peerAddresses localhost:7051 --tlsRootCertFiles /home/ubuntu/caliper/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles /home/ubuntu/caliper/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --version 1.0 --sequence 1
+ res=0
2024-07-23 23:00:27.465 -04 [chaincodeCmd] ClientWait -> INFO 002 txid [21f868d41e4d68f55f19159b7082a64c3d09af8ddbbe85ddc07a49093e26ca99] committed with status (VALID) at localhost:9051
2024-07-23 23:00:27.465 -04 [chaincodeCmd] ClientWait -> INFO 001 txid [21f868d41e4d68f55f19159b7082a64c3d09af8ddbbe85ddc07a49093e26ca99] committed with status (VALID) at localhost:7051
Chaincode definition committed on channel 'mychannel'
Using organization 1
Querying chaincode definition on peer0.org1 on channel 'mychannel'...
Attempting to Query committed status on peer0.org1, Retry after 3 seconds.
+ peer lifecycle chaincode querycommitted --channelID mychannel --name basic
+ res=0
Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
Query chaincode definition successful on peer0.org1 on channel 'mychannel'
Using organization 2
Querying chaincode definition on peer0.org2 on channel 'mychannel'...
Attempting to Query committed status on peer0.org2, Retry after 3 seconds.
+ peer lifecycle chaincode querycommitted --channelID mychannel --name basic
+ res=0
Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
Query chaincode definition successful on peer0.org2 on channel 'mychannel'
Chaincode initialization is not required
ubuntu@ubuntu:~/caliper/fabric-samples/test-network$ export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

ubuntu@ubuntu:~/caliper/fabric-samples/test-network$ npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmarkFast.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled
Usage:
 caliper launch manager --caliper-bind-sut fabric:2.2 [other options]

Options:
  --help, -h           Show usage information  [boolean]
  --version            Show version information  [boolean]
  --caliper-bind-sut   The name and version of the platform to bind to  [string]
  --caliper-bind-cwd   The working directory for performing the SDK install  [string]
  --caliper-bind-args  Additional arguments to pass to "npm install". Use the "=" notation when setting this parameter  [string]
  --caliper-bind-file  Yaml file to override default (supported) package versions when binding an SDK  [string]

Error: Benchmark configuration file "/home/ubuntu/caliper/fabric-samples/test-network/benchmarks/myAssetBenchmarkFast.yaml" does not exist
    at Function.assertConfigurationFilePaths (/usr/local/lib/node_modules/@hyperledger/caliper-cli/node_modules/@hyperledger/caliper-core/lib/common/utils/caliper-utils.js:68:19)
    at Function.handler (/usr/local/lib/node_modules/@hyperledger/caliper-cli/lib/launch/lib/launchManager.js:32:22)
    at Object.module.exports.handler (/usr/local/lib/node_modules/@hyperledger/caliper-cli/lib/launch/launchManagerCommand.js:46:44)
    at Object.runCommand (/usr/local/lib/node_modules/@hyperledger/caliper-cli/node_modules/yargs/lib/command.js:240:40)
    at Object.parseArgs [as _parseArgs] (/usr/local/lib/node_modules/@hyperledger/caliper-cli/node_modules/yargs/yargs.js:1154:41)
    at Object.runCommand (/usr/local/lib/node_modules/@hyperledger/caliper-cli/node_modules/yargs/lib/command.js:198:30)
    at Object.parseArgs [as _parseArgs] (/usr/local/lib/node_modules/@hyperledger/caliper-cli/node_modules/yargs/yargs.js:1154:41)
    at Object.get [as argv] (/usr/local/lib/node_modules/@hyperledger/caliper-cli/node_modules/yargs/yargs.js:1088:21)
    at Object.<anonymous> (/usr/local/lib/node_modules/@hyperledger/caliper-cli/caliper.js:39:5)
    at Module._compile (internal/modules/cjs/loader.js:999:30)
ubuntu@ubuntu:~/caliper/fabric-samples/test-network$ cd ~/caliper/caliper-workspace
npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmark.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled
2024.07.23-23:03:16.486 info  [caliper] [cli-launch-manager]    Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:03:16.487 info  [caliper] [cli-launch-manager]    Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmark.yaml
2024.07.23-23:03:16.487 info  [caliper] [cli-launch-manager]    Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:03:16.487 info  [caliper] [cli-launch-manager]    Set SUT type: fabric
2024.07.23-23:03:16.520 info  [caliper] [benchmark-validator]   No observer specified, will default to `none`
2024.07.23-23:03:16.520 info  [caliper] [caliper-engine]        Starting benchmark flow
2024.07.23-23:03:16.977 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:03:16.996 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:03:16.997 info  [caliper] [caliper-engine]        Skipping start commands due to benchmark flow conditioning
2024.07.23-23:03:16.997 info  [caliper] [caliper-engine]        Skipping initialization phase due to benchmark flow conditioning
2024.07.23-23:03:16.997 info  [caliper] [caliper-engine]        Skipping install smart contract phase due to benchmark flow conditioning
2024.07.23-23:03:16.999 info  [caliper] [monitor.js]    No resource monitors specified
2024.07.23-23:03:17.001 info  [caliper] [default-observer]      Observer interval set to 5000 seconds
2024.07.23-23:03:17.003 info  [caliper] [round-orchestrator]    Preparing worker connections
2024.07.23-23:03:17.003 info  [caliper] [worker-orchestrator]   Launching worker 1 of 2
2024.07.23-23:03:17.010 info  [caliper] [worker-orchestrator]   Launching worker 2 of 2
2024.07.23-23:03:17.015 info  [caliper] [worker-orchestrator]   Messenger not configured, entering configure phase...
2024.07.23-23:03:17.016 info  [caliper] [worker-orchestrator]   No existing workers detected, entering worker launch phase...
2024.07.23-23:03:17.016 info  [caliper] [worker-orchestrator]   Waiting for 2 workers to be connected...
2024.07.23-23:03:17.333 info  [caliper] [cli-launch-worker]     Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:03:17.334 info  [caliper] [cli-launch-worker]     Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmark.yaml
2024.07.23-23:03:17.334 info  [caliper] [cli-launch-worker]     Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:03:17.334 info  [caliper] [cli-launch-worker]     Set SUT type: fabric
2024.07.23-23:03:17.336 info  [caliper] [cli-launch-worker]     Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:03:17.337 info  [caliper] [cli-launch-worker]     Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmark.yaml
2024.07.23-23:03:17.337 info  [caliper] [cli-launch-worker]     Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:03:17.337 info  [caliper] [cli-launch-worker]     Set SUT type: fabric
2024.07.23-23:03:17.392 info  [caliper] [worker-orchestrator]   2 workers connected, progressing to worker assignment phase.
2024.07.23-23:03:17.392 info  [caliper] [worker-orchestrator]   Workers currently unassigned, awaiting index assignment...
2024.07.23-23:03:17.393 info  [caliper] [worker-orchestrator]   Waiting for 2 workers to be assigned...
2024.07.23-23:03:17.419 info  [caliper] [worker-orchestrator]   2 workers assigned, progressing to worker initialization phase.
2024.07.23-23:03:17.419 info  [caliper] [worker-orchestrator]   Waiting for 2 workers to be ready...
2024.07.23-23:03:17.967 info  [caliper] [worker-message-handler]        Initializing Worker#0...
2024.07.23-23:03:17.967 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:03:17.967 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:03:17.967 info  [caliper] [worker-message-handler]        Worker#0 initialized
2024.07.23-23:03:17.969 info  [caliper] [worker-orchestrator]   2 workers ready, progressing to test preparation phase.
2024.07.23-23:03:17.969 info  [caliper] [round-orchestrator]    Started round 1 (readAsset)
2024.07.23-23:03:17.971 info  [caliper] [worker-message-handler]        Preparing Worker#0 for Round#0
2024.07.23-23:03:17.974 info  [caliper] [connectors/v2/FabricGateway]   Connecting user with identity User1 to a Network Gateway
2024.07.23-23:03:18.138 info  [caliper] [connectors/v2/FabricGateway]   Successfully connected user with identity User1 to a Network Gateway
2024.07.23-23:03:18.138 info  [caliper] [connectors/v2/FabricGateway]   Generating contract map for user User1
2024.07.23-23:03:18.167 info  [caliper] [worker-message-handler]        Initializing Worker#1...
2024.07.23-23:03:18.167 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:03:18.167 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:03:18.167 info  [caliper] [worker-message-handler]        Worker#1 initialized
2024.07.23-23:03:18.168 info  [caliper] [worker-message-handler]        Preparing Worker#1 for Round#0
2024.07.23-23:03:18.168 info  [caliper] [connectors/v2/FabricGateway]   Connecting user with identity User1 to a Network Gateway
2024.07.23-23:03:18.188 info  [caliper] [connectors/v2/FabricGateway]   Successfully connected user with identity User1 to a Network Gateway
2024.07.23-23:03:18.188 info  [caliper] [connectors/v2/FabricGateway]   Generating contract map for user User1
2024.07.23-23:03:18.218 info  [caliper] [caliper-worker]        Info: worker 0 prepare test phase for round 0 is starting...
Worker 0: Creating asset 0_0
2024.07.23-23:03:18.265 info  [caliper] [caliper-worker]        Info: worker 1 prepare test phase for round 0 is starting...
Worker 1: Creating asset 1_0
Worker 1: Creating asset 1_1
Worker 0: Creating asset 0_1
Worker 1: Creating asset 1_2
Worker 0: Creating asset 0_2
Worker 0: Creating asset 0_3
Worker 1: Creating asset 1_3
Worker 0: Creating asset 0_4
Worker 1: Creating asset 1_4
Worker 1: Creating asset 1_5
Worker 0: Creating asset 0_5
Worker 0: Creating asset 0_6
Worker 1: Creating asset 1_6
Worker 0: Creating asset 0_7
Worker 1: Creating asset 1_7
Worker 0: Creating asset 0_8
Worker 1: Creating asset 1_8
Worker 1: Creating asset 1_9
Worker 0: Creating asset 0_9
2024.07.23-23:03:38.543 info  [caliper] [caliper-worker]        Info: worker 1 prepare test phase for round 0 is completed
2024.07.23-23:03:38.543 info  [caliper] [worker-message-handler]        Worker#1 prepared for Round#0
2024.07.23-23:03:38.543 info  [caliper] [caliper-worker]        Info: worker 0 prepare test phase for round 0 is completed
2024.07.23-23:03:38.544 info  [caliper] [worker-message-handler]        Worker#0 prepared for Round#0
2024.07.23-23:03:38.545 info  [caliper] [worker-orchestrator]   2 workers prepared, progressing to test phase.
2024.07.23-23:03:38.545 info  [caliper] [round-orchestrator]    Monitors successfully started
2024.07.23-23:03:38.547 info  [caliper] [worker-message-handler]        Worker#0 is starting Round#0
2024.07.23-23:03:38.547 info  [caliper] [worker-message-handler]        Worker#1 is starting Round#0
2024.07.23-23:03:38.551 info  [caliper] [caliper-worker]        Worker #0 starting workload loop
2024.07.23-23:03:38.551 info  [caliper] [caliper-worker]        Worker #1 starting workload loop
2024.07.23-23:03:43.563 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 1041 Succ: 1040 Fail:0 Unfinished:1
2024.07.23-23:03:48.548 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 2796 Succ: 2794 Fail:0 Unfinished:2
2024.07.23-23:03:53.548 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 4615 Succ: 4612 Fail:0 Unfinished:3
2024.07.23-23:03:58.550 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 6441 Succ: 6440 Fail:0 Unfinished:1
2024.07.23-23:04:03.550 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 8257 Succ: 8255 Fail:0 Unfinished:2
2024.07.23-23:04:08.551 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 10134 Succ: 10133 Fail:0 Unfinished:1
Worker 1: Deleting asset 1_0
Worker 0: Deleting asset 0_0
Worker 1: Deleting asset 1_1
Worker 0: Deleting asset 0_1
2024.07.23-23:04:13.556 info  [caliper] [default-observer]      Resetting txCount indicator count
Worker 0: Deleting asset 0_2
Worker 1: Deleting asset 1_2
Worker 1: Deleting asset 1_3
Worker 0: Deleting asset 0_3
Worker 0: Deleting asset 0_4
Worker 1: Deleting asset 1_4
2024.07.23-23:04:18.558 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_5
Worker 0: Deleting asset 0_5
Worker 0: Deleting asset 0_6
Worker 1: Deleting asset 1_6
2024.07.23-23:04:23.562 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_7
Worker 0: Deleting asset 0_7
Worker 1: Deleting asset 1_8
Worker 0: Deleting asset 0_8
Worker 0: Deleting asset 0_9
Worker 1: Deleting asset 1_9
2024.07.23-23:04:28.566 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
2024.07.23-23:04:29.841 info  [caliper] [connectors/v2/FabricGateway]   disconnecting gateway for user User1
2024.07.23-23:04:29.841 info  [caliper] [connectors/v2/FabricGateway]   disconnecting gateway for user User1
2024.07.23-23:04:29.844 info  [caliper] [worker-message-handler]        Worker#1 finished Round#0
2024.07.23-23:04:29.844 info  [caliper] [worker-message-handler]        Worker#0 finished Round#0
2024.07.23-23:04:34.848 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
2024.07.23-23:04:34.851 info  [caliper] [report-builder]        ### Test result ###
2024.07.23-23:04:34.860 info  [caliper] [report-builder] 
+-----------+-------+------+-----------------+-----------------+-----------------+-----------------+------------------+
| Name      | Succ  | Fail | Send Rate (TPS) | Max Latency (s) | Min Latency (s) | Avg Latency (s) | Throughput (TPS) |
|-----------|-------|------|-----------------|-----------------|-----------------|-----------------|------------------|
| readAsset | 10502 | 0    | 354.9           | 0.02            | 0.00            | 0.01            | 354.8            |
+-----------+-------+------+-----------------+-----------------+-----------------+-----------------+------------------+

2024.07.23-23:04:34.861 info  [caliper] [round-orchestrator]    Finished round 1 (readAsset) in 30.104 seconds
2024.07.23-23:04:34.861 info  [caliper] [monitor.js]    Stopping all monitors
2024.07.23-23:04:34.861 info  [caliper] [report-builder]        ### All test results ###
2024.07.23-23:04:34.862 info  [caliper] [report-builder] 
+-----------+-------+------+-----------------+-----------------+-----------------+-----------------+------------------+
| Name      | Succ  | Fail | Send Rate (TPS) | Max Latency (s) | Min Latency (s) | Avg Latency (s) | Throughput (TPS) |
|-----------|-------|------|-----------------|-----------------|-----------------|-----------------|------------------|
| readAsset | 10502 | 0    | 354.9           | 0.02            | 0.00            | 0.01            | 354.8            |
+-----------+-------+------+-----------------+-----------------+-----------------+-----------------+------------------+

2024.07.23-23:04:34.876 info  [caliper] [report-builder]        Generated report with path /home/ubuntu/caliper/caliper-workspace/report.html
2024.07.23-23:04:34.876 info  [caliper] [monitor.js]    Stopping all monitors
2024.07.23-23:04:34.876 info  [caliper] [worker-orchestrator]   Sending exit message to connected workers
2024.07.23-23:04:34.877 info  [caliper] [round-orchestrator]    Benchmark finished in 76.908 seconds. Total rounds: 1. Successful rounds: 1. Failed rounds: 0.
2024.07.23-23:04:34.877 info  [caliper] [caliper-engine]        Skipping end command due to benchmark flow conditioning
2024.07.23-23:04:34.877 info  [caliper] [cli-launch-manager]    Benchmark successfully finished
2024.07.23-23:04:34.878 info  [caliper] [worker-message-handler]        Worker#0 is exiting
2024.07.23-23:04:34.878 info  [caliper] [worker-message-handler]        Worker#1 is exiting


ubuntu@ubuntu:~/caliper/caliper-workspace$ npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmarkFast.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled
2024.07.23-23:09:24.601 info  [caliper] [cli-launch-manager]    Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:09:24.602 info  [caliper] [cli-launch-manager]    Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmarkFast.yaml
2024.07.23-23:09:24.602 info  [caliper] [cli-launch-manager]    Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:09:24.602 info  [caliper] [cli-launch-manager]    Set SUT type: fabric
2024.07.23-23:09:24.632 info  [caliper] [benchmark-validator]   No observer specified, will default to `none`
2024.07.23-23:09:24.632 info  [caliper] [caliper-engine]        Starting benchmark flow
2024.07.23-23:09:25.084 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:09:25.102 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:09:25.104 info  [caliper] [caliper-engine]        Skipping start commands due to benchmark flow conditioning
2024.07.23-23:09:25.104 info  [caliper] [caliper-engine]        Skipping initialization phase due to benchmark flow conditioning
2024.07.23-23:09:25.104 info  [caliper] [caliper-engine]        Skipping install smart contract phase due to benchmark flow conditioning
2024.07.23-23:09:25.106 info  [caliper] [monitor.js]    No resource monitors specified
2024.07.23-23:09:25.107 info  [caliper] [default-observer]      Observer interval set to 5000 seconds
2024.07.23-23:09:25.109 info  [caliper] [round-orchestrator]    Preparing worker connections
2024.07.23-23:09:25.110 info  [caliper] [worker-orchestrator]   Launching worker 1 of 3
2024.07.23-23:09:25.117 info  [caliper] [worker-orchestrator]   Launching worker 2 of 3
2024.07.23-23:09:25.122 info  [caliper] [worker-orchestrator]   Launching worker 3 of 3
2024.07.23-23:09:25.128 info  [caliper] [worker-orchestrator]   Messenger not configured, entering configure phase...
2024.07.23-23:09:25.129 info  [caliper] [worker-orchestrator]   No existing workers detected, entering worker launch phase...
2024.07.23-23:09:25.129 info  [caliper] [worker-orchestrator]   Waiting for 3 workers to be connected...
2024.07.23-23:09:25.452 info  [caliper] [cli-launch-worker]     Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:09:25.454 info  [caliper] [cli-launch-worker]     Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmarkFast.yaml
2024.07.23-23:09:25.454 info  [caliper] [cli-launch-worker]     Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:09:25.454 info  [caliper] [cli-launch-worker]     Set SUT type: fabric
2024.07.23-23:09:25.470 info  [caliper] [cli-launch-worker]     Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:09:25.472 info  [caliper] [cli-launch-worker]     Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmarkFast.yaml
2024.07.23-23:09:25.472 info  [caliper] [cli-launch-worker]     Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:09:25.472 info  [caliper] [cli-launch-worker]     Set SUT type: fabric
2024.07.23-23:09:25.494 info  [caliper] [cli-launch-worker]     Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:09:25.496 info  [caliper] [cli-launch-worker]     Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmarkFast.yaml
2024.07.23-23:09:25.496 info  [caliper] [cli-launch-worker]     Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:09:25.496 info  [caliper] [cli-launch-worker]     Set SUT type: fabric
2024.07.23-23:09:25.563 info  [caliper] [worker-orchestrator]   3 workers connected, progressing to worker assignment phase.
2024.07.23-23:09:25.563 info  [caliper] [worker-orchestrator]   Workers currently unassigned, awaiting index assignment...
2024.07.23-23:09:25.565 info  [caliper] [worker-orchestrator]   Waiting for 3 workers to be assigned...
2024.07.23-23:09:25.599 info  [caliper] [worker-orchestrator]   3 workers assigned, progressing to worker initialization phase.
2024.07.23-23:09:25.600 info  [caliper] [worker-orchestrator]   Waiting for 3 workers to be ready...
2024.07.23-23:09:26.206 info  [caliper] [worker-message-handler]        Initializing Worker#0...
2024.07.23-23:09:26.206 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:09:26.205 info  [caliper] [worker-message-handler]        Initializing Worker#2...
2024.07.23-23:09:26.205 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:09:26.205 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:09:26.205 info  [caliper] [worker-message-handler]        Worker#2 initialized
2024.07.23-23:09:26.207 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:09:26.209 info  [caliper] [worker-message-handler]        Worker#0 initialized
2024.07.23-23:09:26.215 info  [caliper] [worker-orchestrator]   3 workers ready, progressing to test preparation phase.
2024.07.23-23:09:26.215 info  [caliper] [round-orchestrator]    Started round 1 (readAsset)
2024.07.23-23:09:26.217 info  [caliper] [worker-message-handler]        Preparing Worker#0 for Round#0
2024.07.23-23:09:26.216 info  [caliper] [worker-message-handler]        Initializing Worker#1...
2024.07.23-23:09:26.217 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:09:26.217 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:09:26.217 info  [caliper] [worker-message-handler]        Worker#1 initialized
2024.07.23-23:09:26.217 info  [caliper] [worker-message-handler]        Preparing Worker#2 for Round#0
2024.07.23-23:09:26.218 info  [caliper] [worker-message-handler]        Preparing Worker#1 for Round#0
2024.07.23-23:09:26.220 info  [caliper] [connectors/v2/FabricGateway]   Connecting user with identity User1 to a Network Gateway
2024.07.23-23:09:26.221 info  [caliper] [connectors/v2/FabricGateway]   Connecting user with identity User1 to a Network Gateway
2024.07.23-23:09:26.222 info  [caliper] [connectors/v2/FabricGateway]   Connecting user with identity User1 to a Network Gateway
2024.07.23-23:09:26.424 info  [caliper] [connectors/v2/FabricGateway]   Successfully connected user with identity User1 to a Network Gateway
2024.07.23-23:09:26.424 info  [caliper] [connectors/v2/FabricGateway]   Generating contract map for user User1
2024.07.23-23:09:26.427 info  [caliper] [connectors/v2/FabricGateway]   Successfully connected user with identity User1 to a Network Gateway
2024.07.23-23:09:26.428 info  [caliper] [connectors/v2/FabricGateway]   Generating contract map for user User1
2024.07.23-23:09:26.449 info  [caliper] [connectors/v2/FabricGateway]   Successfully connected user with identity User1 to a Network Gateway
2024.07.23-23:09:26.449 info  [caliper] [connectors/v2/FabricGateway]   Generating contract map for user User1
2024.07.23-23:09:26.505 info  [caliper] [caliper-worker]        Info: worker 2 prepare test phase for round 0 is starting...
Worker 2: Creating asset 2_0
2024.07.23-23:09:26.508 info  [caliper] [caliper-worker]        Info: worker 0 prepare test phase for round 0 is starting...
Worker 0: Creating asset 0_0
2024.07.23-23:09:26.538 info  [caliper] [caliper-worker]        Info: worker 1 prepare test phase for round 0 is starting...
Worker 1: Creating asset 1_0
Worker 2: Creating asset 2_1
Worker 0: Creating asset 0_1
Worker 1: Creating asset 1_1
Worker 0: Creating asset 0_2
Worker 2: Creating asset 2_2
Worker 1: Creating asset 1_2
Worker 1: Creating asset 1_3
Worker 2: Creating asset 2_3
Worker 0: Creating asset 0_3
Worker 1: Creating asset 1_4
Worker 0: Creating asset 0_4
Worker 2: Creating asset 2_4
Worker 0: Creating asset 0_5
Worker 1: Creating asset 1_5
Worker 2: Creating asset 2_5
Worker 1: Creating asset 1_6
Worker 2: Creating asset 2_6
Worker 0: Creating asset 0_6
Worker 2: Creating asset 2_7
Worker 0: Creating asset 0_7
Worker 1: Creating asset 1_7
Worker 0: Creating asset 0_8
Worker 2: Creating asset 2_8
Worker 1: Creating asset 1_8
Worker 1: Creating asset 1_9
Worker 0: Creating asset 0_9
Worker 2: Creating asset 2_9
Worker 0: Creating asset 0_10
Worker 2: Creating asset 2_10
Worker 1: Creating asset 1_10
Worker 1: Creating asset 1_11
Worker 0: Creating asset 0_11
Worker 2: Creating asset 2_11
Worker 1: Creating asset 1_12
Worker 2: Creating asset 2_12
Worker 0: Creating asset 0_12
Worker 2: Creating asset 2_13
Worker 0: Creating asset 0_13
Worker 1: Creating asset 1_13
Worker 1: Creating asset 1_14
Worker 2: Creating asset 2_14
Worker 0: Creating asset 0_14
Worker 2: Creating asset 2_15
Worker 0: Creating asset 0_15
Worker 1: Creating asset 1_15
Worker 1: Creating asset 1_16
Worker 2: Creating asset 2_16
Worker 0: Creating asset 0_16
Worker 2: Creating asset 2_17
Worker 1: Creating asset 1_17
Worker 0: Creating asset 0_17
Worker 1: Creating asset 1_18
Worker 0: Creating asset 0_18
Worker 2: Creating asset 2_18
Worker 0: Creating asset 0_19
Worker 2: Creating asset 2_19
Worker 1: Creating asset 1_19
Worker 1: Creating asset 1_20
Worker 0: Creating asset 0_20
Worker 2: Creating asset 2_20
Worker 2: Creating asset 2_21
Worker 0: Creating asset 0_21
Worker 1: Creating asset 1_21
Worker 2: Creating asset 2_22
Worker 1: Creating asset 1_22
Worker 0: Creating asset 0_22
Worker 1: Creating asset 1_23
Worker 2: Creating asset 2_23
Worker 0: Creating asset 0_23
Worker 2: Creating asset 2_24
Worker 0: Creating asset 0_24
Worker 1: Creating asset 1_24
Worker 1: Creating asset 1_25
Worker 2: Creating asset 2_25
Worker 0: Creating asset 0_25
Worker 2: Creating asset 2_26
Worker 0: Creating asset 0_26
Worker 1: Creating asset 1_26
Worker 1: Creating asset 1_27
Worker 0: Creating asset 0_27
Worker 2: Creating asset 2_27
Worker 2: Creating asset 2_28
Worker 1: Creating asset 1_28
Worker 0: Creating asset 0_28
Worker 1: Creating asset 1_29
Worker 2: Creating asset 2_29
Worker 0: Creating asset 0_29
Worker 0: Creating asset 0_30
Worker 2: Creating asset 2_30
Worker 1: Creating asset 1_30
Worker 1: Creating asset 1_31
Worker 0: Creating asset 0_31
Worker 2: Creating asset 2_31
Worker 1: Creating asset 1_32
Worker 2: Creating asset 2_32
Worker 0: Creating asset 0_32
Worker 1: Creating asset 1_33
Worker 2: Creating asset 2_33
Worker 0: Creating asset 0_33
Worker 1: Creating asset 1_34
Worker 2: Creating asset 2_34
Worker 0: Creating asset 0_34
Worker 1: Creating asset 1_35
Worker 0: Creating asset 0_35
Worker 2: Creating asset 2_35
Worker 0: Creating asset 0_36
Worker 1: Creating asset 1_36
Worker 2: Creating asset 2_36
Worker 2: Creating asset 2_37
Worker 0: Creating asset 0_37
Worker 1: Creating asset 1_37
Worker 0: Creating asset 0_38
Worker 2: Creating asset 2_38
Worker 1: Creating asset 1_38
Worker 1: Creating asset 1_39
Worker 0: Creating asset 0_39
Worker 2: Creating asset 2_39
2024.07.23-23:10:47.550 info  [caliper] [caliper-worker]        Info: worker 1 prepare test phase for round 0 is completed
2024.07.23-23:10:47.550 info  [caliper] [caliper-worker]        Info: worker 0 prepare test phase for round 0 is completed
2024.07.23-23:10:47.550 info  [caliper] [caliper-worker]        Info: worker 2 prepare test phase for round 0 is completed
2024.07.23-23:10:47.550 info  [caliper] [worker-message-handler]        Worker#2 prepared for Round#0
2024.07.23-23:10:47.550 info  [caliper] [worker-message-handler]        Worker#0 prepared for Round#0
2024.07.23-23:10:47.550 info  [caliper] [worker-message-handler]        Worker#1 prepared for Round#0
2024.07.23-23:10:47.551 info  [caliper] [worker-orchestrator]   3 workers prepared, progressing to test phase.
2024.07.23-23:10:47.552 info  [caliper] [round-orchestrator]    Monitors successfully started
2024.07.23-23:10:47.553 info  [caliper] [worker-message-handler]        Worker#0 is starting Round#0
2024.07.23-23:10:47.553 info  [caliper] [worker-message-handler]        Worker#1 is starting Round#0
2024.07.23-23:10:47.556 info  [caliper] [worker-message-handler]        Worker#2 is starting Round#0
2024.07.23-23:10:47.556 info  [caliper] [caliper-worker]        Worker #1 starting workload loop
2024.07.23-23:10:47.556 info  [caliper] [caliper-worker]        Worker #0 starting workload loop
2024.07.23-23:10:47.559 info  [caliper] [caliper-worker]        Worker #2 starting workload loop
Worker 0: Deleting asset 0_0
Worker 1: Deleting asset 1_0
Worker 2: Deleting asset 2_0
2024.07.23-23:10:52.569 info  [caliper] [default-observer]      Resetting txCount indicator count
Worker 2: Deleting asset 2_1
Worker 0: Deleting asset 0_1
Worker 1: Deleting asset 1_1
Worker 0: Deleting asset 0_2
Worker 2: Deleting asset 2_2
Worker 1: Deleting asset 1_2
Worker 1: Deleting asset 1_3
Worker 0: Deleting asset 0_3
Worker 2: Deleting asset 2_3
2024.07.23-23:10:57.557 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_4
Worker 2: Deleting asset 2_4
Worker 1: Deleting asset 1_4
Worker 2: Deleting asset 2_5
Worker 0: Deleting asset 0_5
Worker 1: Deleting asset 1_5
2024.07.23-23:11:02.558 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_6
Worker 2: Deleting asset 2_6
Worker 1: Deleting asset 1_6
Worker 2: Deleting asset 2_7
Worker 1: Deleting asset 1_7
Worker 0: Deleting asset 0_7
Worker 2: Deleting asset 2_8
Worker 1: Deleting asset 1_8
Worker 0: Deleting asset 0_8
2024.07.23-23:11:07.562 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_9
Worker 1: Deleting asset 1_9
Worker 2: Deleting asset 2_9
Worker 0: Deleting asset 0_10
Worker 1: Deleting asset 1_10
Worker 2: Deleting asset 2_10
2024.07.23-23:11:12.566 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 2: Deleting asset 2_11
Worker 1: Deleting asset 1_11
Worker 0: Deleting asset 0_11
Worker 2: Deleting asset 2_12
Worker 1: Deleting asset 1_12
Worker 0: Deleting asset 0_12
Worker 2: Deleting asset 2_13
Worker 1: Deleting asset 1_13
Worker 0: Deleting asset 0_13
2024.07.23-23:11:17.571 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 2: Deleting asset 2_14
Worker 0: Deleting asset 0_14
Worker 1: Deleting asset 1_14
Worker 1: Deleting asset 1_15
Worker 2: Deleting asset 2_15
Worker 0: Deleting asset 0_15
2024.07.23-23:11:22.576 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 2: Deleting asset 2_16
Worker 0: Deleting asset 0_16
Worker 1: Deleting asset 1_16
Worker 2: Deleting asset 2_17
Worker 1: Deleting asset 1_17
Worker 0: Deleting asset 0_17
Worker 1: Deleting asset 1_18
Worker 0: Deleting asset 0_18
Worker 2: Deleting asset 2_18
2024.07.23-23:11:27.581 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 2: Deleting asset 2_19
Worker 1: Deleting asset 1_19
Worker 0: Deleting asset 0_19
Worker 1: Deleting asset 1_20
Worker 2: Deleting asset 2_20
Worker 0: Deleting asset 0_20
2024.07.23-23:11:32.586 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_21
Worker 2: Deleting asset 2_21
Worker 0: Deleting asset 0_21
Worker 1: Deleting asset 1_22
Worker 2: Deleting asset 2_22
Worker 0: Deleting asset 0_22
Worker 2: Deleting asset 2_23
Worker 1: Deleting asset 1_23
Worker 0: Deleting asset 0_23
2024.07.23-23:11:37.590 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 2: Deleting asset 2_24
Worker 1: Deleting asset 1_24
Worker 0: Deleting asset 0_24
Worker 1: Deleting asset 1_25
Worker 0: Deleting asset 0_25
Worker 2: Deleting asset 2_25
2024.07.23-23:11:42.595 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_26
Worker 1: Deleting asset 1_26
Worker 2: Deleting asset 2_26
Worker 0: Deleting asset 0_27
Worker 1: Deleting asset 1_27
Worker 2: Deleting asset 2_27
Worker 1: Deleting asset 1_28
Worker 2: Deleting asset 2_28
Worker 0: Deleting asset 0_28
2024.07.23-23:11:47.598 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_29
Worker 1: Deleting asset 1_29
Worker 2: Deleting asset 2_29
Worker 0: Deleting asset 0_30
Worker 2: Deleting asset 2_30
Worker 1: Deleting asset 1_30
2024.07.23-23:11:52.602 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 2: Deleting asset 2_31
Worker 0: Deleting asset 0_31
Worker 1: Deleting asset 1_31
Worker 0: Deleting asset 0_32
Worker 1: Deleting asset 1_32
Worker 2: Deleting asset 2_32
Worker 2: Deleting asset 2_33
Worker 1: Deleting asset 1_33
Worker 0: Deleting asset 0_33
2024.07.23-23:11:57.606 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_34
Worker 2: Deleting asset 2_34
Worker 1: Deleting asset 1_34
Worker 2: Deleting asset 2_35
Worker 0: Deleting asset 0_35
Worker 1: Deleting asset 1_35
2024.07.23-23:12:02.611 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 2: Deleting asset 2_36
Worker 1: Deleting asset 1_36
Worker 0: Deleting asset 0_36
Worker 1: Deleting asset 1_37
Worker 0: Deleting asset 0_37
Worker 2: Deleting asset 2_37
Worker 2: Deleting asset 2_38
Worker 1: Deleting asset 1_38
Worker 0: Deleting asset 0_38
2024.07.23-23:12:07.616 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_39
Worker 1: Deleting asset 1_39
Worker 2: Deleting asset 2_39
2024.07.23-23:12:11.418 info  [caliper] [connectors/v2/FabricGateway]   disconnecting gateway for user User1
2024.07.23-23:12:11.418 info  [caliper] [connectors/v2/FabricGateway]   disconnecting gateway for user User1
2024.07.23-23:12:11.418 info  [caliper] [connectors/v2/FabricGateway]   disconnecting gateway for user User1
2024.07.23-23:12:11.421 info  [caliper] [worker-message-handler]        Worker#2 finished Round#0
2024.07.23-23:12:11.422 info  [caliper] [worker-message-handler]        Worker#1 finished Round#0
2024.07.23-23:12:11.422 info  [caliper] [worker-message-handler]        Worker#0 finished Round#0
2024.07.23-23:12:16.430 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
2024.07.23-23:12:16.433 info  [caliper] [report-builder]        ### Test result ###
2024.07.23-23:12:16.441 info  [caliper] [report-builder] 
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+
| Name      | Succ | Fail | Send Rate (TPS) | Max Latency (s) | Min Latency (s) | Avg Latency (s) | Throughput (TPS) |
|-----------|------|------|-----------------|-----------------|-----------------|-----------------|------------------|
| readAsset | 300  | 0    | 224.4           | 0.02            | 0.00            | 0.01            | 223.7            |
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+

2024.07.23-23:12:16.442 info  [caliper] [round-orchestrator]    Finished round 1 (readAsset) in 2.047 seconds
2024.07.23-23:12:16.442 info  [caliper] [monitor.js]    Stopping all monitors
2024.07.23-23:12:16.442 info  [caliper] [report-builder]        ### All test results ###
2024.07.23-23:12:16.443 info  [caliper] [report-builder] 
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+
| Name      | Succ | Fail | Send Rate (TPS) | Max Latency (s) | Min Latency (s) | Avg Latency (s) | Throughput (TPS) |
|-----------|------|------|-----------------|-----------------|-----------------|-----------------|------------------|
| readAsset | 300  | 0    | 224.4           | 0.02            | 0.00            | 0.01            | 223.7            |
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+

2024.07.23-23:12:16.458 info  [caliper] [report-builder]        Generated report with path /home/ubuntu/caliper/caliper-workspace/report.html
2024.07.23-23:12:16.459 info  [caliper] [monitor.js]    Stopping all monitors
2024.07.23-23:12:16.459 info  [caliper] [worker-orchestrator]   Sending exit message to connected workers
2024.07.23-23:12:16.460 info  [caliper] [worker-message-handler]        Worker#0 is exiting
2024.07.23-23:12:16.462 info  [caliper] [worker-message-handler]        Worker#1 is exiting
2024.07.23-23:12:16.462 info  [caliper] [worker-message-handler]        Worker#2 is exiting
2024.07.23-23:12:16.463 info  [caliper] [round-orchestrator]    Benchmark finished in 170.248 seconds. Total rounds: 1. Successful rounds: 1. Failed rounds: 0.
2024.07.23-23:12:16.463 info  [caliper] [caliper-engine]        Skipping end command due to benchmark flow conditioning
2024.07.23-23:12:16.463 info  [caliper] [cli-launch-manager]    Benchmark successfully finished

ubuntu@ubuntu:~/caliper/caliper-workspace$ cp benchmarks/myAssetBenchmarkFast.yaml benchmarks/myAssetBenchmarkFastDos.yaml
ubuntu@ubuntu:~/caliper/caliper-workspace$ npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmarkFastDos.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled
2024.07.23-23:15:16.553 info  [caliper] [cli-launch-manager]    Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:15:16.554 info  [caliper] [cli-launch-manager]    Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmarkFastDos.yaml
2024.07.23-23:15:16.554 info  [caliper] [cli-launch-manager]    Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:15:16.554 info  [caliper] [cli-launch-manager]    Set SUT type: fabric
2024.07.23-23:15:16.587 info  [caliper] [benchmark-validator]   No observer specified, will default to `none`
2024.07.23-23:15:16.587 info  [caliper] [caliper-engine]        Starting benchmark flow
2024.07.23-23:15:17.064 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:15:17.084 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:15:17.085 info  [caliper] [caliper-engine]        Skipping start commands due to benchmark flow conditioning
2024.07.23-23:15:17.085 info  [caliper] [caliper-engine]        Skipping initialization phase due to benchmark flow conditioning
2024.07.23-23:15:17.085 info  [caliper] [caliper-engine]        Skipping install smart contract phase due to benchmark flow conditioning
2024.07.23-23:15:17.087 info  [caliper] [monitor.js]    No resource monitors specified
2024.07.23-23:15:17.088 info  [caliper] [default-observer]      Observer interval set to 5000 seconds
2024.07.23-23:15:17.091 info  [caliper] [round-orchestrator]    Preparing worker connections
2024.07.23-23:15:17.091 info  [caliper] [worker-orchestrator]   Launching worker 1 of 2
2024.07.23-23:15:17.097 info  [caliper] [worker-orchestrator]   Launching worker 2 of 2
2024.07.23-23:15:17.102 info  [caliper] [worker-orchestrator]   Messenger not configured, entering configure phase...
2024.07.23-23:15:17.103 info  [caliper] [worker-orchestrator]   No existing workers detected, entering worker launch phase...
2024.07.23-23:15:17.103 info  [caliper] [worker-orchestrator]   Waiting for 2 workers to be connected...
2024.07.23-23:15:17.421 info  [caliper] [cli-launch-worker]     Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:15:17.422 info  [caliper] [cli-launch-worker]     Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmarkFastDos.yaml
2024.07.23-23:15:17.423 info  [caliper] [cli-launch-worker]     Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:15:17.423 info  [caliper] [cli-launch-worker]     Set SUT type: fabric
2024.07.23-23:15:17.456 info  [caliper] [cli-launch-worker]     Set workspace path: /home/ubuntu/caliper/caliper-workspace
2024.07.23-23:15:17.458 info  [caliper] [cli-launch-worker]     Set benchmark configuration path: /home/ubuntu/caliper/caliper-workspace/benchmarks/myAssetBenchmarkFastDos.yaml
2024.07.23-23:15:17.458 info  [caliper] [cli-launch-worker]     Set network configuration path: /home/ubuntu/caliper/caliper-workspace/networks/networkConfig.yaml
2024.07.23-23:15:17.459 info  [caliper] [cli-launch-worker]     Set SUT type: fabric
2024.07.23-23:15:17.546 info  [caliper] [worker-orchestrator]   2 workers connected, progressing to worker assignment phase.
2024.07.23-23:15:17.546 info  [caliper] [worker-orchestrator]   Workers currently unassigned, awaiting index assignment...
2024.07.23-23:15:17.547 info  [caliper] [worker-orchestrator]   Waiting for 2 workers to be assigned...
2024.07.23-23:15:17.577 info  [caliper] [worker-orchestrator]   2 workers assigned, progressing to worker initialization phase.
2024.07.23-23:15:17.578 info  [caliper] [worker-orchestrator]   Waiting for 2 workers to be ready...
2024.07.23-23:15:18.126 info  [caliper] [worker-message-handler]        Initializing Worker#0...
2024.07.23-23:15:18.126 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:15:18.127 info  [caliper] [worker-message-handler]        Initializing Worker#1...
2024.07.23-23:15:18.127 info  [caliper] [fabric-connector]      Initializing gateway connector compatible with installed SDK: 2.2.3
2024.07.23-23:15:18.127 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:15:18.127 info  [caliper] [worker-message-handler]        Worker#1 initialized
2024.07.23-23:15:18.128 info  [caliper] [IdentityManager]       Adding User1 (admin=false) as User1 for organization Org1MSP
2024.07.23-23:15:18.130 info  [caliper] [worker-message-handler]        Worker#0 initialized
2024.07.23-23:15:18.131 info  [caliper] [worker-orchestrator]   2 workers ready, progressing to test preparation phase.
2024.07.23-23:15:18.131 info  [caliper] [round-orchestrator]    Started round 1 (readAsset)
2024.07.23-23:15:18.132 info  [caliper] [worker-message-handler]        Preparing Worker#0 for Round#0
2024.07.23-23:15:18.132 info  [caliper] [worker-message-handler]        Preparing Worker#1 for Round#0
2024.07.23-23:15:18.136 info  [caliper] [connectors/v2/FabricGateway]   Connecting user with identity User1 to a Network Gateway
2024.07.23-23:15:18.136 info  [caliper] [connectors/v2/FabricGateway]   Connecting user with identity User1 to a Network Gateway
2024.07.23-23:15:18.304 info  [caliper] [connectors/v2/FabricGateway]   Successfully connected user with identity User1 to a Network Gateway
2024.07.23-23:15:18.304 info  [caliper] [connectors/v2/FabricGateway]   Generating contract map for user User1
2024.07.23-23:15:18.316 info  [caliper] [connectors/v2/FabricGateway]   Successfully connected user with identity User1 to a Network Gateway
2024.07.23-23:15:18.317 info  [caliper] [connectors/v2/FabricGateway]   Generating contract map for user User1
2024.07.23-23:15:18.356 info  [caliper] [caliper-worker]        Info: worker 1 prepare test phase for round 0 is starting...
Worker 1: Creating asset 1_0
2024.07.23-23:15:18.366 info  [caliper] [caliper-worker]        Info: worker 0 prepare test phase for round 0 is starting...
Worker 0: Creating asset 0_0
Worker 0: Creating asset 0_1
Worker 1: Creating asset 1_1
Worker 0: Creating asset 0_2
Worker 1: Creating asset 1_2
Worker 1: Creating asset 1_3
Worker 0: Creating asset 0_3
Worker 1: Creating asset 1_4
Worker 0: Creating asset 0_4
Worker 0: Creating asset 0_5
Worker 1: Creating asset 1_5
Worker 0: Creating asset 0_6
Worker 1: Creating asset 1_6
Worker 1: Creating asset 1_7
Worker 0: Creating asset 0_7
Worker 1: Creating asset 1_8
Worker 0: Creating asset 0_8
Worker 1: Creating asset 1_9
Worker 0: Creating asset 0_9
Worker 1: Creating asset 1_10
Worker 0: Creating asset 0_10
Worker 1: Creating asset 1_11
Worker 0: Creating asset 0_11
Worker 1: Creating asset 1_12
Worker 0: Creating asset 0_12
Worker 0: Creating asset 0_13
Worker 1: Creating asset 1_13
Worker 1: Creating asset 1_14
Worker 0: Creating asset 0_14
Worker 0: Creating asset 0_15
Worker 1: Creating asset 1_15
Worker 1: Creating asset 1_16
Worker 0: Creating asset 0_16
Worker 0: Creating asset 0_17
Worker 1: Creating asset 1_17
Worker 1: Creating asset 1_18
Worker 0: Creating asset 0_18
Worker 1: Creating asset 1_19
Worker 0: Creating asset 0_19
Worker 0: Creating asset 0_20
Worker 1: Creating asset 1_20
Worker 1: Creating asset 1_21
Worker 0: Creating asset 0_21
Worker 0: Creating asset 0_22
Worker 1: Creating asset 1_22
Worker 0: Creating asset 0_23
Worker 1: Creating asset 1_23
Worker 0: Creating asset 0_24
Worker 1: Creating asset 1_24
Worker 0: Creating asset 0_25
Worker 1: Creating asset 1_25
Worker 1: Creating asset 1_26
Worker 0: Creating asset 0_26
Worker 1: Creating asset 1_27
Worker 0: Creating asset 0_27
Worker 1: Creating asset 1_28
Worker 0: Creating asset 0_28
Worker 1: Creating asset 1_29
Worker 0: Creating asset 0_29
Worker 1: Creating asset 1_30
Worker 0: Creating asset 0_30
Worker 0: Creating asset 0_31
Worker 1: Creating asset 1_31
Worker 1: Creating asset 1_32
Worker 0: Creating asset 0_32
Worker 1: Creating asset 1_33
Worker 0: Creating asset 0_33
Worker 1: Creating asset 1_34
Worker 0: Creating asset 0_34
Worker 1: Creating asset 1_35
Worker 0: Creating asset 0_35
Worker 1: Creating asset 1_36
Worker 0: Creating asset 0_36
Worker 1: Creating asset 1_37
Worker 0: Creating asset 0_37
Worker 1: Creating asset 1_38
Worker 0: Creating asset 0_38
Worker 1: Creating asset 1_39
Worker 0: Creating asset 0_39
2024.07.23-23:16:39.384 info  [caliper] [caliper-worker]        Info: worker 1 prepare test phase for round 0 is completed
2024.07.23-23:16:39.384 info  [caliper] [caliper-worker]        Info: worker 0 prepare test phase for round 0 is completed
2024.07.23-23:16:39.384 info  [caliper] [worker-message-handler]        Worker#0 prepared for Round#0
2024.07.23-23:16:39.384 info  [caliper] [worker-message-handler]        Worker#1 prepared for Round#0
2024.07.23-23:16:39.387 info  [caliper] [worker-orchestrator]   2 workers prepared, progressing to test phase.
2024.07.23-23:16:39.388 info  [caliper] [round-orchestrator]    Monitors successfully started
2024.07.23-23:16:39.389 info  [caliper] [worker-message-handler]        Worker#0 is starting Round#0
2024.07.23-23:16:39.390 info  [caliper] [worker-message-handler]        Worker#1 is starting Round#0
2024.07.23-23:16:39.391 info  [caliper] [caliper-worker]        Worker #0 starting workload loop
2024.07.23-23:16:39.392 info  [caliper] [caliper-worker]        Worker #1 starting workload loop
2024.07.23-23:16:44.401 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 1074 Succ: 1072 Fail:0 Unfinished:2
2024.07.23-23:16:49.390 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 3000 Succ: 3000 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_0
Worker 0: Deleting asset 0_0
Worker 0: Deleting asset 0_1
Worker 1: Deleting asset 1_1
Worker 1: Deleting asset 1_2
Worker 0: Deleting asset 0_2
2024.07.23-23:16:54.394 info  [caliper] [default-observer]      Resetting txCount indicator count
Worker 1: Deleting asset 1_3
Worker 0: Deleting asset 0_3
Worker 0: Deleting asset 0_4
Worker 1: Deleting asset 1_4
2024.07.23-23:16:59.399 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_5
Worker 0: Deleting asset 0_5
Worker 0: Deleting asset 0_6
Worker 1: Deleting asset 1_6
Worker 0: Deleting asset 0_7
Worker 1: Deleting asset 1_7
2024.07.23-23:17:04.404 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_8
Worker 0: Deleting asset 0_8
Worker 1: Deleting asset 1_9
Worker 0: Deleting asset 0_9
2024.07.23-23:17:09.406 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_10
Worker 0: Deleting asset 0_10
Worker 1: Deleting asset 1_11
Worker 0: Deleting asset 0_11
Worker 0: Deleting asset 0_12
Worker 1: Deleting asset 1_12
2024.07.23-23:17:14.411 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_13
Worker 0: Deleting asset 0_13
Worker 0: Deleting asset 0_14
Worker 1: Deleting asset 1_14
2024.07.23-23:17:19.414 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_15
Worker 1: Deleting asset 1_15
Worker 1: Deleting asset 1_16
Worker 0: Deleting asset 0_16
Worker 0: Deleting asset 0_17
Worker 1: Deleting asset 1_17
2024.07.23-23:17:24.420 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_18
Worker 0: Deleting asset 0_18
Worker 1: Deleting asset 1_19
Worker 0: Deleting asset 0_19
2024.07.23-23:17:29.422 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_20
Worker 1: Deleting asset 1_20
Worker 0: Deleting asset 0_21
Worker 1: Deleting asset 1_21
Worker 0: Deleting asset 0_22
Worker 1: Deleting asset 1_22
2024.07.23-23:17:34.426 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_23
Worker 1: Deleting asset 1_23
Worker 0: Deleting asset 0_24
Worker 1: Deleting asset 1_24
2024.07.23-23:17:39.430 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_25
Worker 1: Deleting asset 1_25
Worker 0: Deleting asset 0_26
Worker 1: Deleting asset 1_26
Worker 0: Deleting asset 0_27
Worker 1: Deleting asset 1_27
2024.07.23-23:17:44.434 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_28
Worker 0: Deleting asset 0_28
Worker 0: Deleting asset 0_29
Worker 1: Deleting asset 1_29
2024.07.23-23:17:49.439 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 0: Deleting asset 0_30
Worker 1: Deleting asset 1_30
Worker 1: Deleting asset 1_31
Worker 0: Deleting asset 0_31
Worker 1: Deleting asset 1_32
Worker 0: Deleting asset 0_32
2024.07.23-23:17:54.444 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_33
Worker 0: Deleting asset 0_33
Worker 1: Deleting asset 1_34
Worker 0: Deleting asset 0_34
2024.07.23-23:17:59.446 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_35
Worker 0: Deleting asset 0_35
Worker 1: Deleting asset 1_36
Worker 0: Deleting asset 0_36
Worker 1: Deleting asset 1_37
Worker 0: Deleting asset 0_37
2024.07.23-23:18:04.450 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
Worker 1: Deleting asset 1_38
Worker 0: Deleting asset 0_38
Worker 1: Deleting asset 1_39
Worker 0: Deleting asset 0_39
2024.07.23-23:18:09.455 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
2024.07.23-23:18:10.508 info  [caliper] [connectors/v2/FabricGateway]   disconnecting gateway for user User1
2024.07.23-23:18:10.508 info  [caliper] [connectors/v2/FabricGateway]   disconnecting gateway for user User1
2024.07.23-23:18:10.511 info  [caliper] [worker-message-handler]        Worker#0 finished Round#0
2024.07.23-23:18:10.512 info  [caliper] [worker-message-handler]        Worker#1 finished Round#0
2024.07.23-23:18:15.515 info  [caliper] [default-observer]      [readAsset Round 0 Transaction Info] - Submitted: 0 Succ: 0 Fail:0 Unfinished:0
2024.07.23-23:18:15.519 info  [caliper] [report-builder]        ### Test result ###
2024.07.23-23:18:15.525 info  [caliper] [report-builder] 
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+
| Name      | Succ | Fail | Send Rate (TPS) | Max Latency (s) | Min Latency (s) | Avg Latency (s) | Throughput (TPS) |
|-----------|------|------|-----------------|-----------------|-----------------|-----------------|------------------|
| readAsset | 3000 | 0    | 330.2           | 0.01            | 0.00            | 0.01            | 330.1            |
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+

2024.07.23-23:18:15.526 info  [caliper] [round-orchestrator]    Finished round 1 (readAsset) in 9.595 seconds
2024.07.23-23:18:15.526 info  [caliper] [monitor.js]    Stopping all monitors
2024.07.23-23:18:15.527 info  [caliper] [report-builder]        ### All test results ###
2024.07.23-23:18:15.527 info  [caliper] [report-builder] 
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+
| Name      | Succ | Fail | Send Rate (TPS) | Max Latency (s) | Min Latency (s) | Avg Latency (s) | Throughput (TPS) |
|-----------|------|------|-----------------|-----------------|-----------------|-----------------|------------------|
| readAsset | 3000 | 0    | 330.2           | 0.01            | 0.00            | 0.01            | 330.1            |
+-----------+------+------+-----------------+-----------------+-----------------+-----------------+------------------+

2024.07.23-23:18:15.538 info  [caliper] [report-builder]        Generated report with path /home/ubuntu/caliper/caliper-workspace/report.html
2024.07.23-23:18:15.538 info  [caliper] [monitor.js]    Stopping all monitors
2024.07.23-23:18:15.538 info  [caliper] [worker-orchestrator]   Sending exit message to connected workers
2024.07.23-23:18:15.539 info  [caliper] [round-orchestrator]    Benchmark finished in 177.408 seconds. Total rounds: 1. Successful rounds: 1. Failed rounds: 0.
2024.07.23-23:18:15.539 info  [caliper] [caliper-engine]        Skipping end command due to benchmark flow conditioning
2024.07.23-23:18:15.539 info  [caliper] [cli-launch-manager]    Benchmark successfully finished
2024.07.23-23:18:15.540 info  [caliper] [worker-message-handler]        Worker#1 is exiting
2024.07.23-23:18:15.540 info  [caliper] [worker-message-handler]        Worker#0 is exiting
``` 









