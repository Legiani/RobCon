//
//  ViewController.swift
//  RobCon
//
//  Created by Jakub Bednář on 01.10.17.
//  Copyright © 2017 Jakub Bednář. All rights reserved.
//
// and https://github.com/hoiberg/HM10-BluetoothSerial-iOS/blob/master/HM10%20Serial/SerialViewController.swift
// and https://github.com/PTEz/PTEHorizontalTableView

// Import knihoven
import UIKit
import CoreBluetooth

// Main page class (hlavní třída page s vyberem kontroleru)
final class ViewController: UIViewController, BleSerialDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    // Pole všech BLE řazených dle RSSI
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    // Propojení s cell
    @IBOutlet weak var colectionView: UICollectionView!
    
    // Inicalizace BluetoothSerial
    var delegate: BleSerialDelegate!

    // Tlačítko pro vyvolání noveho hledání BLE
    @IBOutlet weak var reScan: UIBarButtonItem!
    
    // Nazev stránky -> výpis aktuálního procesu
    @IBOutlet var header: UINavigationItem!

    // Alert Controler
    var alertController: UIAlertController?
    
    // Když je page načtena
    override func viewDidLoad() {
        // Načtení grafiky
        super.viewDidLoad()

        // Inicializace serial jako třídy pro komunikaci
        Bserial = BleSerial(Bdelegate: self)
        
        // V základu je tlačítko "re-scan" disable
        reScan.isEnabled = true
    
        // Funkce pro kontrolu zda je zapnutí BLE
        alert()
    }
    
    // V případě vypnutí aplikace či bluetooth
    func serialStoped() {
        alert()
    }
    
    func alert(){
        // Kontrola zda je BLE zapnutý
        if (Bserial.centralManager.state != .poweredOn) {
            // Když je vypnutý bluetooth, vyvolá se alert, který odkazuje na ovládání bluetooth v nastavení
            // Definování alertu
            alertController = UIAlertController(title: "Bluetooth is off", message: "Set Bluetooth on in options.", preferredStyle: UIAlertControllerStyle.alert)
            alertController?.addAction(UIAlertAction(title: "Options", style: .default, handler: { (action: UIAlertAction!) in
                // Když je novější než iOS 10, otevře rovnou nastavení BLE, jinak jenom nastavení (starší iOS funkci nepodporovaly)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:"App-prefs:root=Bluetooth")!, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.openURL(NSURL(string: "prefs:root=Settings")! as URL)
                }
            }))
            // Vyvolání alertu
            self.presentedViewController?.present(alertController!, animated: true, completion: nil)
            return
        }
    }
    
    // Tlačítko reScan
    @IBAction func reScan(_ sender: Any) {
        // Vyprázdnit pole pro nalezená zařízení
        peripherals = []
        // Diable re-load button
        reScan.isEnabled = false
        // Změna názvu na "skenuji"
        header.title = "Scanning ..."
        // Začít hledat zařízení
        Bserial.startScan()
    }
    
    // ** Práce s BLE **
    
    // Když najde zařízení, tak ho přidá do "theRSSI"
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // Kontrola duplicity zařízení v peripherals
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // Přidání do seznamu zařízení a následné seřazení
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        
        // V hlavičce se objeví "vyberte zařízení"
        header.title = "Chose Device"
        // Konec skenování
        Bserial.stopScan()
        // reScan je enable
        reScan.isEnabled = true
        
        // Znovu načti data v colectionView
        colectionView.reloadData()
    }
    
    // ** Práce s Colection View **
    
    // Připrava colectionView -> kolik tam bude položek
    ///vrací počet položek v peripherals
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    // Samotné nastavení colectionView
    ///vrací vytvořenou cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Definování proměnné cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceCellscreen", for: indexPath) as! deviceCell
        
        // Přidání parametru vytvářené cell
        ///nadpis cell
        cell.devLabel.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        // Obrázek cell
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
    
    // Přesměrování na stránku s ovladačem dle názvu BLE
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Definice selectedPeripheral vybraného zařízení
        
        if(peripherals.count >= 1){
            selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        }
        // Vymazání pole zařízení
        peripherals = []
        // Připojení k zařízení
        Bserial.connectToPeripheral(selectedPeripheral!)
        
        // Přesměrování na stránku dle názvu zařízení
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

