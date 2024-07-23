package main

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// TollContract contract for handling writing and reading from the world state
type TollContract struct {
	contractapi.Contract
}

// TollRecord defines a toll transaction
type TollRecord struct {
	VehicleID  string `json:"vehicleID"`
	Timestamp  string `json:"timestamp"`
	Amount     int    `json:"amount"`
	Paid       bool   `json:"paid"`
	PaymentTxn string `json:"paymentTxn"`
}

// CaptureToll captures the toll transaction details
func (tc *TollContract) CaptureToll(ctx contractapi.TransactionContextInterface, vehicleID string, amount int) error {
	timestamp := time.Now().Format(time.RFC3339)
	record := TollRecord{
		VehicleID:  vehicleID,
		Timestamp:  timestamp,
		Amount:     amount,
		Paid:       false,
		PaymentTxn: "",
	}

	recordJSON, err := json.Marshal(record)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(vehicleID+"_"+timestamp, recordJSON)
}

// PayToll allows users to pay for the toll using their wallet
func (tc *TollContract) PayToll(ctx contractapi.TransactionContextInterface, vehicleID string, timestamp string, paymentTxn string) error {
	recordKey := vehicleID + "_" + timestamp
	recordJSON, err := ctx.GetStub().GetState(recordKey)
	if err != nil {
		return fmt.Errorf("failed to read from world state: %v", err)
	}
	if recordJSON == nil {
		return fmt.Errorf("the toll record %s does not exist", recordKey)
	}

	var record TollRecord
	err = json.Unmarshal(recordJSON, &record)
	if err != nil {
		return err
	}

	record.Paid = true
	record.PaymentTxn = paymentTxn

	updatedRecordJSON, err := json.Marshal(record)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(recordKey, updatedRecordJSON)
}

// GetTollRecord retrieves a toll record by vehicleID and timestamp
func (tc *TollContract) GetTollRecord(ctx contractapi.TransactionContextInterface, vehicleID string, timestamp string) (*TollRecord, error) {
	recordKey := vehicleID + "_" + timestamp
	recordJSON, err := ctx.GetStub().GetState(recordKey)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if recordJSON == nil {
		return nil, fmt.Errorf("the toll record %s does not exist", recordKey)
	}

	var record TollRecord
	err = json.Unmarshal(recordJSON, &record)
	if err != nil {
		return nil, err
	}

	return &record, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&TollContract{})
	if err != nil {
		fmt.Printf("Error create toll contract chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting toll contract chaincode: %s", err.Error())
	}
}
