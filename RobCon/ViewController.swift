//
//  ViewController.swift
//  RobCon
//
//  Created by Jakub Bednář on 01.10.17.
//  Copyright © 2017 Jakub Bednář. All rights reserved.
//
// Base on https://github.com/hoiberg/swiftBluetoothSerial
// and https://github.com/hoiberg/HM10-BluetoothSerial-iOS/blob/master/HM10%20Serial/SerialViewController.swift
// and https://github.com/PTEz/PTEHorizontalTableView

//import knihoven
import UIKit
import CoreBluetooth



//main page class (hlavní třída page s vyberem kontroleru)
final class ViewController: UIViewController, BluetoothSerialDelegate1, UICollectionViewDelegate, UICollectionViewDataSource{
    
    // Pole všech BLE razeních dle RSSI
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    // propojení s cell
    @IBOutlet weak var colectionView: UICollectionView!
    
    //inicalizace BluetoothSerial
    var delegate: BluetoothSerialDelegate1!

    // Tlačítko pro vyvolání noveho hledání BLE
    @IBOutlet weak var reScan: UIBarButtonItem!
    
    // Nazev stránky -> vypis aktualního procesu
    @IBOutlet var header: UINavigationItem!

    // když je page načtena
    override func viewDidLoad() {
        //načtení grafiky
        super.viewDidLoad()

        // inicalizace serial jako třídy pro komunikaci
       serial = BluetoothSerial(delegate1: self)
        
        // v zakladu je tlačítko re-scan disable
        reScan.isEnabled = true
    
        //funkce pro kontrolu zda je zapnutí BLE
        alert()
    }
    
    //kontrola když se v pruběhu vypne BLE
    func serialDidChangeState() {
        //funkce pro kontrolu zda je zapnutí BLE
        alert()
    }
    
    func alert(){
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
    
    //tlačítko reScan
    @IBAction func reScan(_ sender: Any) {
        // vyprazdnit pole pro nalezená zařízení
        peripherals = []
        // diable re-load button
        reScan.isEnabled = false
        // změna nazvu na skenuji
        header.title = "Scanning ..."
        // začít hledat zařízení
        serial.startScan()
    }
    
    //************ Práce s BLE ************
    
    //když je zařízení odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //v hlavičce se oběví odpojeno
        header.title = "Disconect"
    }
    
    //když najde zařízení tak ho přidá do "theRSSI"
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // kontrola duplicity zařízení v peripherals
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // přidání do seznamu zařízení a nasledné seřazení
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        
        //v hlavičce se oběví vyberte zařízení
        header.title = "Chose Device"
        //konec skenovaní
        serial.stopScan()
        //reScan je enable
        reScan.isEnabled = true
        
        //znovu načti data v colectionView
        colectionView.reloadData()
    }
    
    //************ Práce s Colection View ************
    
    //připrava colectionView -> kolik tam bude položek
    ///vrací počet položek v peripherals
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    //samotné nastavení colectionView
    ///vrací vytvořenou cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //definování promene cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceCell", for: indexPath) as! deviceViewCell
        
        //přidání parametru vytvářené cell
        ///nadpis cell
        cell.devLabel.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        //obrázek cell
        switch peripherals[(indexPath as NSIndexPath).row].peripheral.name {
        case Config.mse?:
            cell.devImage.image = #imageLiteral(resourceName: "mouse.png")
            break
        case Config.r2?:
            cell.devImage.image = #imageLiteral(resourceName: "r2.png")
            break
        default:
            cell.devImage.image = #imageLiteral(resourceName: "console.png")
            break
        }
        return cell
    }
    
    //přesmerování na stranku s ovladačem del nazvu BLE
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //definice selectedPeripheral vybraným zařízením
        
        if(peripherals.count >= 1){
            selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        }
        //vymazaní pole zařízení
        peripherals = []
        //připojení k zařízení
        serial.connectToPeripheral(selectedPeripheral!)
        
        //přesmerování na stránku de nazvu zařízení
        switch selectedPeripheral?.name {
        case Config.mse?:
            performSegue(withIdentifier: Config.mse_page, sender: (Any).self)
            break
        case Config.r2?:
            performSegue(withIdentifier: Config.r2_page, sender: Any?.self)
            break
        default:
            performSegue(withIdentifier: Config.def_page, sender: Any?.self)
        }
    }
    
    
}

