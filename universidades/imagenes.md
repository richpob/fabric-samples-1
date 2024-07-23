# Evidencias del despliegue
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











