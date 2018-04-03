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

// Třída pro ovládání stránky controlleru
final class ConsoleController: UIViewController, UITextFieldDelegate, BleSerialDelegate {
    func serialStoped() {
        dismiss(animated: true, completion: nil)
    }
    

    // Definování vstupu textu od uživatele
    @IBOutlet var comandInput: UITextField!
    // Výpis I/O hlášek
    @IBOutlet var comandShow: UITextView!
    
    // Když je page načtena
    override func viewDidLoad() {
        // Načtení grefiky
        super.viewDidLoad()
        
        // Inicializace serial jako třídy pro komunikaci
        Bserial.Bdelegate = self
        
        // Zobrazení klávesnice
        comandInput.becomeFirstResponder()
    }
    
    // ** Definování tlačítek **

    // Odeslání příkazu zařízení a přidání do konzole (odřádkování)
    @IBAction func sendCommand(_ sender: Any) {
        Bserial.sendMessageToDevice(comandInput.text!)
        comandShow.text! += comandInput.text!
        comandShow.text! += "\n"
        comandInput.text = ""
        
        let bottom = NSMakeRange(comandShow.text.count - 1, 1)
        comandShow.scrollRangeToVisible(bottom)
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
        
        let range = NSMakeRange(comandShow.text.count - 1, 0)
        comandShow.scrollRangeToVisible(range)
    }

    // Když je v průběhu vypnut BLE
    func serialDidChangeState() {
        // Volání funkce zavření aktuální stránky
        dismiss(animated: true, completion: nil)
    }
    
    // Když je BLE v průběhu odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        // Volání funkce zavření aktuální stránky
        dismiss(animated: true, completion: nil)
    }
}
