//
//  mseControler.swift
//  RobCon
//
//  Created by Jakub Bednář on 26.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//
// Music ase on https://github.com/mking/hue-ios/blob/master/WelcomeViewController.swift
// and http://www.oodlestechnologies.com/blogs/Open-iTunes-Music-Library-to-Play-Songs-in-Swift
// Icon is on GPL https://icons8.com/icon/new-icons/ios
// Base serial on https://github.com/hoiberg/swiftBluetoothSerial and https://github.com/hoiberg/HM10-BluetoothSerial-iOS/blob/master/HM10%20Serial/SerialViewController.swift

//import knihoven
import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import CoreBluetooth
import QuartzCore

//main page class (hlavní třída stránky s ovládáním mouse droidu)
class mseController: UIViewController, BluetoothSerialDelegate1, MPMediaPickerControllerDelegate{
    
    //definování labelu pro nazev prave hrající skladby
    @IBOutlet weak var nowPlayingLabel: UILabel!
    //vypis komunikace s zařízením
    @IBOutlet weak var textViewComunicaton: UITextView!
    
    //pomocné promené pro odevření a naslednou prácí s vnitřní hudební knihovnou zařízení
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    
    //pomocná promená pro pause/play
    ///false - pause
    ///true - play
    var stopStart = false
    
    //když je page načtená
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // inicalizace serial jako třídy pro komunikaci
        serial.delegate1 = self
    }
    
    //v případě problému s pamětí
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //************ Práce s BLE ************
    
    // když BLE přijme zprávu od zařízení
    func serialDidReceiveString(_ message: String) {
        //přidej zprávu do textView
        textViewComunicaton.text! += message
    }
    
    // když je BLE v prubehu odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //navrat na stránku vyhledávání
        self.navigationController?.popViewController(animated: true);
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
    
    //************ Práce s hudbou ************
    
    //odevření knihovny hudby
    @IBAction func openItunesLibraryTapped(_ sender: Any) {
        //vyber všechnu hudbu v zařízení
        let picker = MPMediaPickerController(mediaTypes: .anyAudio)
        //nastavení prohlížeče hudby
        picker.delegate = self
        picker.prompt = "Přehrát na pozadí"
        //volání funkce zobrazení prohlížeče hudby
        present(picker, animated: true, completion: nil)
    }
    
    //hraj pozastav hudbu
    @IBAction func stopStart(_ sender: Any) {
        //připojení k přehrávači
        let player = MPMusicPlayerController.applicationMusicPlayer
        //porovnání pomocné proměné pro pauze/play hudby
        if stopStart == true {
            //pauza
            player.pause()
            stopStart = false
        }else{
            //hraj
            player.play()
            stopStart = true
        }
    }
    
    //zavření prohlížeče hudby po zmačknutí "Zavřít"
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        //volání funkce zavření prohlížeče hudby
        dismiss(animated: true, completion: nil)
    }
    
    //zavření prohlížeče hudby a nasledné spuštení vybrané hudby
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        //po vybrání stopy volání funkce zavření prohlížeče hudby
        dismiss(animated: true, completion: nil)
        //přiřazení stopy do přehravače
        let player = MPMusicPlayerController.applicationMusicPlayer
        print(player.nowPlayingItem?.title ?? "Nill")
        //v případě vybrání kolekce (vyplé)
        player.setQueue(with: mediaItemCollection)
        
        //spuštení definované stopy
        player.play()
        //pomocná proměná pro pause/play
        stopStart = true
        
        //vípis nazvu přehrávané skladby
        var name = player.nowPlayingItem?.title
        //když něco hraje
        if name == nil{
            //vypiš "Nic nehraje"
            self.nowPlayingLabel.text="Nic nehraje"
        }else{
            //vypiš nazev skladby
            self.nowPlayingLabel.text = name
        }
    }
    
    //************ Definování tlačítek ************
    
    //Tlačítka akcí
    @IBAction func lamp(_ sender: Any) {
        serial.sendMessageToDevice("a")
    }
    
    @IBAction func light(_ sender: Any) {
        serial.sendMessageToDevice("s")
    }
    
    @IBAction func action(_ sender: Any) {
        serial.sendMessageToDevice("u")
        print("send dsdsd")
    }
    

    
    //Tlačítka motoru
    
    //levej motor dopredu
    @IBAction func Left_front(_ sender: Any) {
        serial.sendMessageToDevice("n")
    }
    @IBAction func Left_front_up(_ sender: Any) {
        serial.sendMessageToDevice("nb")
    }
    
    //levej motor dozadu
    @IBAction func Left_back(_ sender: Any) {
        serial.sendMessageToDevice("d")
    }
    @IBAction func Left_back_up(_ sender: Any) {
        serial.sendMessageToDevice("db")
    }
    
    //pravej motor dopredu
    @IBAction func Right_front(_ sender: Any) {
        serial.sendMessageToDevice("p")
    }
    @IBAction func Right_front_up(_ sender: Any) {
        serial.sendMessageToDevice("pb")
    }
    
    //pravej motor dozadu
    @IBAction func Right_back(_ sender: Any) {
        serial.sendMessageToDevice("l")
    }
    @IBAction func Right_back_up(_ sender: Any) {
        serial.sendMessageToDevice("lb")
    }
    
    
    
    
}
