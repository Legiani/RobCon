//
//  BleSerial.swift
//  RobCon
//
//  Created by Jakub Bednář on 25.02.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//
// Base on https://github.com/hoiberg/swiftBluetoothSerial

import UIKit
import CoreBluetooth

// Globální přistup k třídě
var Bserial: BleSerial!

protocol BleSerialDelegate {
    
    //** Povinné **
    
    // Vyvolá se když je vypnut Bluetooth, nebo v případě odpojení zařízení
    func serialStoped()
    
    //** Volitelné **
    // -> volitelné se samy doplnují v extensions BleSerialDelegate
    
    // Vyvolá se když je přijat nějaký řetězec (string)
    func serialDidReceiveString(_ message: String)
    
    // Vyvolá se když je přečteno RSSI připojeného zařízení
    func serialDidReadRSSI(_ rssi: NSNumber)
    
    // Vyvolá se když je zažízení nalezeno. Vrací RSSI
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?)
    
    // Vyvolá se když je komunikace připravena
    func serialIsReady(_ peripheral: CBPeripheral)
}

//Dělá některé možnosti delagáta nepovinné
extension BleSerialDelegate{
    func serialDidReadRSSI(_ rssi: NSNumber) {}
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {}
    func serialIsReady(_ peripheral: CBPeripheral) {}
    func serialDidReceiveString(_ message: String) {}
}

final class BleSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // ** Proměnné **
    
    // Když je volán delegát
    var Bdelegate: BleSerialDelegate!
    
    // Obsluha všeho kolem Bluetooth Core
    var centralManager: CBCentralManager!
    
    // Zařízení v průběhu připojování
    var pendingPeripheral: CBPeripheral?
    
    // Zařízení když je připojené
    var connectedPeripheral: CBPeripheral?

    // Charakteriristika zařízení nutná pro pozdější připojení
    weak var writeCharacteristic: CBCharacteristic?
    
    // Nastavení komunikace s odpovědí nebo bez (nastavuje se automaticky)
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    
    // UUID zařízení která se mají vypsat (HM-10)
    var serviceUUID = CBUUID(string: "FFE0")
    
    // UUID charakteristiky -> charakteristiku je možné přirovnat k metadatům
    // FFE1 -> blok s typem komunikace (s nebo bez odpovědi)
    var characteristicUUID = CBUUID(string: "FFE1")
    
    
    // ** Obsluha Bluetooth **
    
    // Když je spojení připraveno
    var conectionActive: Bool {
        get {
            return centralManager.state == .poweredOn &&
                                            connectedPeripheral != nil &&
                                            writeCharacteristic != nil
        }
    }
    
    // Vrací informaci, zda je vyhledávání v chodu
    var isScanning: Bool {
        return centralManager.isScanning
    }
    
    // Vrací true, když je bluetooth zapnutý
    var isPoweredOn: Bool {
        return centralManager.state == .poweredOn
    }
    
    // Inicializace instance
    init(Bdelegate: BleSerialDelegate) {
        super.init()
        self.Bdelegate = Bdelegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Funkce skenování
    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        
        // Skenování s definovaným UUID
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        
        // Porovnání s již nalezenými zařízeními
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
        for peripheral in peripherals {
            Bdelegate.serialDidDiscoverPeripheral(peripheral, RSSI: nil)
        }
    }
    
    // Ukončení skenování
    func stopScan() {
        centralManager.stopScan()
    }
    
    // Připojení k zadanému zařízení
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        pendingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    // Odpojení nebo zrušení připojování v případě, že probíhá komunikace
    func disconnect() {
        if let x = connectedPeripheral {
            centralManager.cancelPeripheralConnection(x)
        } else if let x = pendingPeripheral {
            centralManager.cancelPeripheralConnection(x)
        }
    }
    
    /// Pošle data do zařízení jako String
    func sendMessageToDevice(_ message: String) {
        // Kontrola spojení
        guard conectionActive else { return }
        
        if let data = message.data(using: String.Encoding.utf8) {
            connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
        }
    }
    
    // ** CBCentralManagerDelegate funkce **
    
    // Vyvolá se v případě nalezení zařízení
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Pošle nalezené zařízení do delegáta
        Bdelegate.serialDidDiscoverPeripheral(peripheral, RSSI: RSSI)
    }
    
    // Vyvolá se po připojení
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        
        // Na základě charakteristiky, kterou zařízení odpoví, se nastaví komunikace s odpovědí nebo bez
        peripheral.discoverServices([serviceUUID])
    }
    
    // Vyvolá se když je zařízení odpojeno
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        pendingPeripheral = nil
        
        // Oznámí delegátovi ztrátu zařízení
        Bdelegate.serialStoped()
    }
    
    // Vyvolá se, když nastane chyba při připojování
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        pendingPeripheral = nil
        
        // Oznámí delegátovi ztrátu zařízení
        Bdelegate.serialStoped()
    }
    
    // Vyvolá se při změně stavu zařízení
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Když se ztratí připojení se zařízením, není možné s ním provádět další akce
        connectedPeripheral = nil
        pendingPeripheral = nil
        
        // Oznámí delegátovi ztrátu zařízení
        Bdelegate.serialStoped()
    }
    
    
    // ** CBPeripheralDelegate funkce **
    
    // Vytažení charakteristiky zařízení
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Vyhledání předdefinované charakteristiky 0xFFE1
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    // Automatické nastavení charakteristiky
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Kontrola, zda se jedná o kýženou charakteristiku
        for characteristic in service.characteristics! {
            if characteristic.uuid == characteristicUUID {
                // "Registrace" pro odběr informací v případě datového toku v komunikaci
                peripheral.setNotifyValue(true, for: characteristic)
                
                // Dočasné uložení charakteristiky
                writeCharacteristic = characteristic
                
                // Samotné nastavení komunikace (s odpovedí nebo bez)
                writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
                
                // Oznámení delegátovi o připravenosti komunikace
                Bdelegate.serialIsReady(peripheral)
            }
        }
    }
    
    // Vyvolá se při aktivitě datového toku v komunikaci
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Přijetí dat
        let data = characteristic.value
        guard data != nil else { return }
        
        // Vrací delegátovi přijatý string
        if let str = String(data: data!, encoding: String.Encoding.utf8) {
            Bdelegate.serialDidReceiveString(str)
        }
    }
}
