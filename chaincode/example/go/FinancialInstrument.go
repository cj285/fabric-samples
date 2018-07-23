/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * The sample smart contract for documentation topic:
 * Writing Your First Blockchain Application
 */

package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"encoding/json"
	"fmt"
  "strconv"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}

// Define the car structure, with 4 properties.  Structure tags are used by encoding/json library
type FinancialInstrument struct {
	Payload string `json:"payload"`
}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function =="initLedger" {
    return s.initLedger(APIstub)
  } else if function == "getPayload" {
		return s.getPayload(APIstub, args)
	} else if function == "modifyPayload" {
		return s.modifyPayload(APIstub, args)
	} else if function == "createPayload" {
		return s.createPayload(APIstub, args)
	}
	return shim.Error("Invalid Smart Contract function name.")
}

func (s *SmartContract) createPayload(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

  if len(args) != 2 {
    return shim.Error("Incorrect number of arguments. Expecting 2")
  }

  var fi = FinancialInstrument{Payload : args[1]}

  fiAsBytes, _ := json.Marshal(fi)
  err := APIstub.PutState(args[0], fiAsBytes)
  if err != nil {
    return shim.Error("Something is wrong")
  }
  return shim.Success(nil)
}

func (s *SmartContract) getPayload(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	financialInstrumentAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(financialInstrumentAsBytes)
}


func (s *SmartContract) modifyPayload(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	fiAsBytes, _ := APIstub.GetState(args[0])
	fi := FinancialInstrument{}

	json.Unmarshal(fiAsBytes, &fi)
	fi.Payload = args[1]

	fiAsBytes, _ = json.Marshal(fi)
	APIstub.PutState(args[0], fiAsBytes)
	return shim.Success(nil)
}

func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
  fi := []FinancialInstrument{
    FinancialInstrument {Payload : "t1"},
    FinancialInstrument {Payload : "t2"},
    FinancialInstrument {Payload : "t3"},
    FinancialInstrument {Payload : "t4"},
  }

  i := 0
  for i < len(fi) {
    fmt.Println("i is ", i)
    fiAsBytes, _ := json.Marshal(fi[i])
    APIstub.PutState("FinancialInstrument" + strconv.Itoa(i), fiAsBytes)
    fmt.Println("Added", fi[i])
    i = i + 1
  }
  return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
