//
//  consoleControler.swift
//  RobCon
//
//  Created by Jakub Bednář on 31.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//
// Base on https://github.com/hoiberg/swiftBluetoothSerial and https://github.com/hoiberg/HM10-BluetoothSerial-iOS/blob/master/HM10%20Serial/SerialViewController.swift

//import knihoven
import UIKit
import CoreBluetooth
import QuartzCore

//class pro ovladání stránky controleru
final class consoleController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate1 {

    //definování vstupu textu od uživatele
    @IBOutlet var comandInput: UITextField!
    //vypis I/O hlášek
    @IBOutlet var comandShow: UITextView!
    
    // když je page načtena
    override func viewDidLoad() {
        //načtení grefiky
        super.viewDidLoad()
        
        // inicalizace serial jako třídy pro komunikaci
        serial.delegate1 = self
        
        // zobrazení klavesnice
        comandInput.becomeFirstResponder()
    }
    
    //************ Definování tlačítek ************

    //odeslání říkazu zařízení a přidání do konzole (odžádkování)
    @IBAction func sendCommand(_ sender: Any) {
        serial.sendMessageToDevice(comandInput.text!)
        comandShow.text! += comandInput.text!
        comandShow.text! += "\n"
        comandInput.text = ""
        
        let range = NSMakeRange(comandShow.text.characters.count - 1, 0)
        comandShow.scrollRangeToVisible(range)
    }
    
    //tlačítko "Back"
    @IBAction func back(_ sender: Any) {
        //volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    //************ Definování BLE ************
    
    // když BLE přijme zprávu od zařízení
    func serialDidReceiveString(_ message: String) {
        //přidej zprávu do textView
        comandShow.text! += message
        
        let range = NSMakeRange(comandShow.text.characters.count - 1, 0)
        comandShow.scrollRangeToVisible(range)
    }

    //když je v prubehu vypnut BLE
    func serialDidChangeState() {
        //volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    // když je BLE v prubehu odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
}
