//
//  ViewController.swift
//  HelloFirebase
//
//  Created by Duncan on 2016/4/1.
//  Copyright © 2016年 Duncan. All rights reserved.
//

import UIKit
import CoreBluetooth

let fbase = Firebase(url: "https://sweltering-inferno-2150.firebaseio.com/")
var nickName = "Unknow User"
var superCentralManager = CBCentralManager()
var peripheralArray = [CBPeripheral]()
var serviceArray = [CBService]()
var characteristicArray = [CBCharacteristic]()
let serviceUUIDString = "E8008802-4143-5453-5162-6C696E6B73EC"
let characteristicUUIDString = "E8009A03-4143-5453-5162-6C696E6B73EC"


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var textInput: UITextField!
    
    @IBAction func sendButton(sender: UIButton) {
        if textInput.text != ""{
        nickName = textInput.text!        
        performSegueWithIdentifier("chatView", sender: nil)
        }else{
            //彈警告視窗
            showAlertMessage("請輸入暱稱")
        }
        characteristicArray[0].setValue("YES", forKey: "notifying")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        superCentralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showAlertMessage(message: String!) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }

    //以下藍芽通訊部分
    
    
    @IBAction func connectButton(sender: AnyObject) {
        peripheralArray[0].discoverServices([CBUUID(string: serviceUUIDString)])
        /*
        print(peripheralArray[0].services)
        serviceArray = peripheralArray[0].services!
        peripheralArray[0].discoverCharacteristics([CBUUID(string: characteristicUUIDString)], forService: serviceArray[0])
        print(serviceArray[0].characteristics)
        if serviceArray[0].characteristics != nil{
            characteristicArray = serviceArray[0].characteristics!
         }
        */
    }
    
    
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch (central.state) {
        case .PoweredOff:   print("CoreBluetooth BLE hardware is powered off")
        case .PoweredOn:    print("CoreBluetooth BLE hardware is powered on and ready")
        case .Resetting:    print("CoreBluetooth BLE hardware is resetting")
        case .Unauthorized: print("CoreBluetooth BLE state is unauthorized")
        case .Unknown:      print("CoreBluetooth BLE state is unknown")
        case .Unsupported:  print("CoreBluetooth BLE hardware is unsupported on this platform")
        }
        
        superCentralManager.scanForPeripheralsWithServices(nil, options: nil)

    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if peripheral.name != nil{
            //showAlertMessage("Find Devices" + "【" + peripheral.name! + "】")
            print("Find Devices")
            print("\(peripheral)")
            print("\(advertisementData)")
            peripheralArray.append(peripheral)
            superCentralManager.stopScan()
            superCentralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        print("【" + peripheral.name! + "】" + "connected")
        //peripheral.discoverServices([CBUUID(string: serviceUUIDString)])
        //print(peripheral.services)

    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("【" + peripheral.name! + "】" + "connecting fail")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("【" + peripheral.name! + "】" + "disconnected")
    }

    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Modified Services \(invalidatedServices)")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Found Service!")
        print(peripheralArray[0].services)
        serviceArray = peripheralArray[0].services!
        for service in serviceArray{
            peripheral.discoverCharacteristics([CBUUID(string: characteristicUUIDString)], forService: service)
        }
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("Found Characteristics !")
        if service.characteristics != nil{
            characteristicArray = service.characteristics!
            for characteristic in characteristicArray{
                print(characteristic)
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                peripheral.readValueForCharacteristic(characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
            if let data = characteristic.value{
                print(data)
                if "\(data)" != "<00>"{
                textInput.text = "\(data)"
                }
            }
        
    }
    
}

