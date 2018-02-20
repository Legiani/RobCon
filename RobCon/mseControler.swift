//
//  mseControler.swift
//  RobCon
//
//  Created by Jakub Bednář on 26.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//
// Music base on https://github.com/mking/hue-ios/blob/master/WelcomeViewController.swift
// and http://www.oodlestechnologies.com/blogs/Open-iTunes-Music-Library-to-Play-Songs-in-Swift
// Icon is on GNU GPL https://icons8.com/icon/new-icons/ios
// Base serial comunication on https://github.com/hoiberg/swiftBluetoothSerial and https://github.com/hoiberg/HM10-BluetoothSerial-iOS/blob/master/HM10%20Serial/SerialViewController.swift

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
        
        let range = NSMakeRange(textViewComunicaton.text.characters.count - 1, 0)
        textViewComunicaton.scrollRangeToVisible(range) }
    
    // když je BLE v prubehu odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        //volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    //když je v prubehu vypnut BLE
    func serialDidChangeState() {
        //volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
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
        //volání funkce zavření aktualní stránky
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
    
    //Back
    @IBAction func back(_ sender: Any) {
        serial.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
    //Tlačítka akcí
    @IBAction func lamp(_ sender: Any) {
        serial.sendMessageToDevice(Config.Lamp)
    }
    
    @IBAction func light(_ sender: Any) {
        serial.sendMessageToDevice(Config.Light)
    }
    
    @IBAction func action(_ sender: Any) {
        serial.sendMessageToDevice(Config.Action)
    }
    
    
    //Tlačítka motoru
    
    //levej motor dopredu
    @IBAction func Left_front(_ sender: Any) {
        serial.sendMessageToDevice(Config.Left_front)
    }
    @IBAction func Left_front_up(_ sender: Any) {
        serial.sendMessageToDevice(Config.Left_front + Config.invers_prefix)
    }
    
    //levej motor dozadu
    @IBAction func Left_back(_ sender: Any) {
        serial.sendMessageToDevice(Config.Left_back)
    }
    @IBAction func Left_back_up(_ sender: Any) {
        serial.sendMessageToDevice(Config.Left_back + Config.invers_prefix)
    }
    
    //pravej motor dopredu
    @IBAction func Right_front(_ sender: Any) {
        serial.sendMessageToDevice(Config.Right_front)
    }
    @IBAction func Right_front_up(_ sender: Any) {
        serial.sendMessageToDevice(Config.Right_front + Config.invers_prefix)
    }
    
    //pravej motor dozadu
    @IBAction func Right_back(_ sender: Any) {
        serial.sendMessageToDevice(Config.Right_back)
    }
    @IBAction func Right_back_up(_ sender: Any) {
        serial.sendMessageToDevice(Config.Right_back + Config.invers_prefix)
    }
    
    
    
    
}
