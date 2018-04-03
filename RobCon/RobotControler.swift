//
//  RobotControler.swift
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
import WatchConnectivity

// Main page class (hlavní třída stránky s ovládáním mouse droidu)
class RobotController: UIViewController, BleSerialDelegate, MPMediaPickerControllerDelegate{
    //Definování přehrávače
     let player = MPMusicPlayerController.applicationMusicPlayer
    
    // ** Definování a načtení stránky **
    
    // Definování labelu pro nazev prave hrající skladby
    @IBOutlet weak var nowPlaying: UILabel!
    // Vypis komunikace s zařízením
    @IBOutlet weak var textViewComunicaton: UITextView!
    // Proměnné pro přístup k tlačítkum přeočení
    @IBOutlet var backButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    
    // Pomocné promené pro odevření a naslednou prácí s vnitřní hudební knihovnou zařízení
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    
    // Pomocná promená pro pause/play
    ///false - pause
    ///true - play
    var stopStart = false
    
    let session = WCSession.default
    
    var con = false
    
    // Když je page načtená
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inicalizace serial jako třídy pro komunikaci
        Bserial.Bdelegate = self
        session.delegate = self
        
        // Přejmenování z duvodu nemožnosti přejmenování v streydoardu
        nowPlaying.text = "Nothing play"
        
        // Nastavení a aktivace komunikace s watch
        if WCSession.isSupported() {
            session.activate()
        }
    }
    
    // V případě problému s pamětí
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // ** Práce s BLE **
    
    // Když BLE přijme zprávu od zařízení
    func serialDidReceiveString(_ message: String) {
        // Přidej zprávu do textView
        textViewComunicaton.text! += message+"\n"
        
        let range = NSMakeRange(textViewComunicaton.text.count - 1, 0)
        textViewComunicaton.scrollRangeToVisible(range)
        
    }
    // Když je v prubehu vypnut BLE nebo BLE v prubehu odpojeno
    func serialStoped() {
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
        picker.allowsPickingMultipleItems = true
        // Volání funkce zobrazení prohlížeče hudby
        present(picker, animated: true, completion: nil)
    }
    
    // Hraj pozastav hudbu
    @IBAction func stopStart(_ sender: Any) {
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
        dismiss(animated: false, completion: nil)
        // Přiřazení stopy do přehravače
        player.setQueue(with: mediaItemCollection)
        
        // V případě vybrání kolekce (vyplé)
        player.prepareToPlay()
        if(player.isPreparedToPlay)
        {
            // Spuštení definované stopy
            player.play()
            // Pomocná proměná pro pause/play
            stopStart = true
            
            // Funkce pro výpis názvu přehrávané skladby
            getName()
            
            // Povolení tlačítek
            backButton.isEnabled = true
            forwardButton.isEnabled = true
        }
        
    }
    
    @IBAction func moveBack(_ sender: Any) {
        player.skipToPreviousItem()
        // Funkce pro výpis názvu přehrávané skladby
        DispatchQueue.main.asyncAfter(deadline: .now() + 100.0, execute: {
            self.getName()
        })
    }

    @IBAction func moveForward(_ sender: Any) {
        player.skipToNextItem()

        sleep(1)
        // Funkce pro výpis názvu přehrávané skladby
        getName()
        
    }
    
    
    func getName() {
        // Výpis názvu přehrávané skladby
        var name                                                                                                                                             = player.nowPlayingItem?.title
        // Když je definován název
        if name == nil{
            // Vypiš "Nic nehraje"
            self.nowPlaying.text="Without name"
        }else{
            // Vypiš název skladby
            self.nowPlaying.text = name
        }
        print(player.nowPlayingItem?.title)
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
    
    // Levý motor dopředu
    @IBAction func Left_front(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_front)
    }
    @IBAction func Left_front_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_front + Config.invers_prefix)
    }
    
    // Levý motor dozadu
    @IBAction func Left_back(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_back)
    }
    @IBAction func Left_back_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Left_back + Config.invers_prefix)
    }
    
    // Pravý motor dopředu
    @IBAction func Right_front(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_front)
    }
    @IBAction func Right_front_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_front + Config.invers_prefix)
    }
    
    // Pravý motor dozadu
    @IBAction func Right_back(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_back)
    }
    @IBAction func Right_back_up(_ sender: Any) {
        Bserial.sendMessageToDevice(Config.Right_back + Config.invers_prefix)
    }
    
    //Funkce vypsání hlášky
    func  Alert(title: String, text: String) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
    }
    
    

}

// ** Přeposlání příkazu z watch (RobConWE)

extension RobotController: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message received: ",message)
        print("State", con)

        if(con == true){
       
            // Vrací data na základě hlavičky
            let value = message["Message"] as? String

            // Výpis přijatého příkazu na obrazovku
            DispatchQueue.main.async { () -> Void in
                if self.textViewComunicaton.text.isEmpty {
                    self.textViewComunicaton.text = "From Watch: " + value! + "\n"
                }else{
                    self.textViewComunicaton.text = self.textViewComunicaton.text! + "From Watch: " + value! + "\n"
                }
                
                switch value {
                case "lf"?:
                    Bserial.sendMessageToDevice(Config.Left_front)
                    break
                case "lb"?:
                    Bserial.sendMessageToDevice(Config.Left_back)
                    break
                case "rf"?:
                    Bserial.sendMessageToDevice(Config.Right_front)
                    break
                case "rb"?:
                    Bserial.sendMessageToDevice(Config.Right_back)
                    break
                    
                case "blf"?:
                    Bserial.sendMessageToDevice(Config.Left_front + Config.invers_prefix)
                    break
                case "blb"?:
                    Bserial.sendMessageToDevice(Config.Left_back + Config.invers_prefix)
                    break
                case "brf"?:
                    Bserial.sendMessageToDevice(Config.Right_front + Config.invers_prefix)
                    break
                case "brb"?:
                    Bserial.sendMessageToDevice(Config.Right_back + Config.invers_prefix)
                    break
                    
                    
                case "li"?:
                    Bserial.sendMessageToDevice(Config.Light)
                    break
                case "la"?:
                    Bserial.sendMessageToDevice(Config.Lamp)
                    break
                case .none:
                    break
                case .some(_):
                    break
                }
            }
        }
        
        let connected = message["State"] as? String
        if(connected == "true" || connected == nil){
            con = true
   
            sendMessage(messageToSend:"true",label: "State")
        }
        else{
            con = false
        }
    
    }
    
    func sendMessage(messageToSend: String, label: String = "Message") {
        if WCSession.isSupported() {
            print("WCSession supported")
            if session.isReachable {
                session.sendMessage([label:messageToSend], replyHandler: nil, errorHandler: { error in
                    print("Error sending message",error)
                })
            }
        }
    }
    
    // Funkce nutné k připojení Watch
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        con = false
        DispatchQueue.main.async { () -> Void in
            self.textViewComunicaton.text = "Watch DISCONECT\n"
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async { () -> Void in
            self.textViewComunicaton.text = "Watch CONECT\n"
        
        }    }
}
