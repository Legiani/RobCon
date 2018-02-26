//
//  consoleControler.swift
//  RobCon
//
//  Created by Jakub Bednář on 31.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//
// Base on https://github.com/hoiberg/swiftBluetoothSerial and https://github.com/hoiberg/HM10-BluetoothSerial-iOS/blob/master/HM10%20Serial/SerialViewController.swift

// Import knihoven
import UIKit
import CoreBluetooth
import QuartzCore

// Class pro ovladání stránky controleru
final class consoleController: UIViewController, UITextFieldDelegate, BleSerialDelegate {
    func serialStoped() {
        dismiss(animated: true, completion: nil)
    }
    

    // Definování vstupu textu od uživatele
    @IBOutlet var comandInput: UITextField!
    // Vypis I/O hlášek
    @IBOutlet var comandShow: UITextView!
    
    // Když je page načtena
    override func viewDidLoad() {
        // Načtení grefiky
        super.viewDidLoad()
        
        // Inicalizace serial jako třídy pro komunikaci
        Bserial.Bdelegate = self
        
        // Zobrazení klavesnice
        comandInput.becomeFirstResponder()
    }
    
    // ** Definování tlačítek **

    // Odeslání říkazu zařízení a přidání do konzole (odžádkování)
    @IBAction func sendCommand(_ sender: Any) {
        Bserial.sendMessageToDevice(comandInput.text!)
        comandShow.text! += comandInput.text!
        comandShow.text! += "\n"
        comandInput.text = ""
        
        let range = NSMakeRange(comandShow.text.characters.count - 1, 0)
        comandShow.scrollRangeToVisible(range)
    }
    
    // Tlačítko "Back"
    @IBAction func back(_ sender: Any) {
        // Volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    // ** Definování BLE **
    
    // Když BLE přijme zprávu od zařízení
    func serialDidReceiveString(_ message: String) {
        // Přidej zprávu do textView
        comandShow.text! += message
        
        let range = NSMakeRange(comandShow.text.characters.count - 1, 0)
        comandShow.scrollRangeToVisible(range)
    }

    // Když je v prubehu vypnut BLE
    func serialDidChangeState() {
        // Volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    // Když je BLE v prubehu odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        // Volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
}
