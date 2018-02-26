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
// Base serial comunication on https://github.com/hoiberg/HM10-BluetoothSerial-iOS/blob/master/HM10%20Serial/SerialViewController.swift

// Import knihoven
import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import CoreBluetooth
import QuartzCore

// Main page class (hlavní třída stránky s ovládáním mouse droidu)
class mseController: UIViewController, BleSerialDelegate, MPMediaPickerControllerDelegate{
    func serialStoped() {
        // Volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    
    // Definování labelu pro nazev prave hrající skladby
    @IBOutlet weak var nowPlayingLabel: UILabel!
    //vypis komunikace s zařízením
    @IBOutlet weak var textViewComunicaton: UITextView!
    
    // Pomocné promené pro odevření a naslednou prácí s vnitřní hudební knihovnou zařízení
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    
    // Pomocná promená pro pause/play
    ///false - pause
    ///true - play
    var stopStart = false
    
    // Když je page načtená
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inicalizace serial jako třídy pro komunikaci
        Bserial.Bdelegate = self
    }
    
    // V případě problému s pamětí
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // ** Práce s BLE **
    
    // Když BLE přijme zprávu od zařízení
    func serialDidReceiveString(_ message: String) {
        // Přidej zprávu do textView
        textViewComunicaton.text! += message
        
        let range = NSMakeRange(textViewComunicaton.text.characters.count - 1, 0)
        textViewComunicaton.scrollRangeToVisible(range) }
    
    // Když je BLE v prubehu odpojeno
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        // Volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    // Když je v prubehu vypnut BLE
    func serialDidChangeState() {
        // Volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    // ** Práce s hudbou **
    
    // Odevření knihovny hudby
    @IBAction func openItunesLibraryTapped(_ sender: Any) {
        // Výběr všechnu hudbu v zařízení
        let picker = MPMediaPickerController(mediaTypes: .anyAudio)
        // Nastavení prohlížeče hudby
        picker.delegate = self
        picker.prompt = "Přehrát na pozadí"
        // Volání funkce zobrazení prohlížeče hudby
        present(picker, animated: true, completion: nil)
    }
    
    // Hraj pozastav hudbu
    @IBAction func stopStart(_ sender: Any) {
        // Připojení k přehrávači
        let player = MPMusicPlayerController.applicationMusicPlayer
        // Porovnání pomocné proměné pro pauze/play hudby
        if stopStart == true {
            // Pauza
            player.pause()
            stopStart = false
        }else{
            // Hraj
            player.play()
            stopStart = true
        }
    }
    
    // Zavření prohlížeče hudby po zmačknutí "Zavřít"
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // Volání funkce zavření aktualní stránky
        dismiss(animated: true, completion: nil)
    }
    
    // Zavření prohlížeče hudby a nasledné spuštení vybrané hudby
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // Po vybrání stopy volání funkce zavření prohlížeče hudby
        dismiss(animated: true, completion: nil)
        // Přiřazení stopy do přehravače
        let player = MPMusicPlayerController.applicationMusicPlayer
        print(player.nowPlayingItem?.title ?? "Nill")
        // V případě vybrání kolekce (vyplé)
        player.setQueue(with: mediaItemCollection)
        
        // Spuštení definované stopy
        player.play()
        // Pomocná proměná pro pause/play
        stopStart = true
        
        // Vípis nazvu přehrávané skladby
        var name = player.nowPlayingItem?.title
        // Když něco hraje
        if name == nil{
            // Vypiš "Nic nehraje"
            self.nowPlayingLabel.text="Nic nehraje"
        }else{
            // Vypiš nazev skladby
            self.nowPlayingLabel.text = name
        }
    }
    
    // ** Definování tlačítek **
    
    // Back
    @IBAction func back(_ sender: Any) {
        Bserial.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
    // Tlačítka akcí
    @IBAction func lamp(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Lamp)
    }
    
    @IBAction func light(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Light)
    }
    
    @IBAction func action(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Action)
    }
    
    
    // Tlačítka motoru
    
    // Levej motor dopredu
    @IBAction func Left_front(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_front)
    }
    @IBAction func Left_front_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_front + Config.invers_prefix)
    }
    
    // Levej motor dozadu
    @IBAction func Left_back(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_back)
    }
    @IBAction func Left_back_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_back + Config.invers_prefix)
    }
    
    // Pravej motor dopredu
    @IBAction func Right_front(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_front)
    }
    @IBAction func Right_front_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_front + Config.invers_prefix)
    }
    
    // Pravej motor dozadu
    @IBAction func Right_back(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_back)
    }
    @IBAction func Right_back_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_back + Config.invers_prefix)
    }
    
    
    
    
}
