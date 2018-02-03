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
    }
    
    // když BLE přijme zprávu od zařízení
    func serialDidReceiveString(_ message: String) {
        //přidej zprávu do textView
        comandShow.text! += message
    }

    //když je v prubehu vypnut BLE
    func serialDidChangeState() {
        // kontrola zda je BLE zapnutí
        if (serial.centralManager.state != .poweredOn) {
            // když je vypnutí bluetooth vyvolá se alert který odkazuje na ovladání bluetooth v nastavení
            //definování alertu
            let refreshAlert = UIAlertController(title: "Bluetooth is off", message: "Set Bluetooth on in options.", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "Options", style: .default, handler: { (action: UIAlertAction!) in
                //když je novější než iOS 10 otevře rovnou nastavení BLE jinak jenom nastavení (starší iOS funkci neměly)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:"App-prefs:root=Bluetooth")!, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(NSURL(string: "prefs:root=Settings")! as URL)
                }
            }))
            //vyvolání alertu
            present(refreshAlert, animated: true, completion: nil)
            return
        }
    }
    
    // když je BLE v prubehu odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //navrat na stránku vyhledávání
        self.navigationController?.popViewController(animated: true);
    }
}
