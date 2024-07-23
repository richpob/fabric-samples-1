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
