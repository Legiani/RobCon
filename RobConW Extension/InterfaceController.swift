//
//  InterfaceController.swift
//  RobConW Extension
//
//  Created by Jakub Bednář on 07.03.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//

import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController{
    
    @IBOutlet var console: WKInterfaceLabel!
    
    var lf = true
    var lb = true
    var rf = true
    var rb = true
    
    let session = WCSession.default
    
    var con = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        //presentAlert(withTitle: "Conect Robot in iPhone", message: "Yous of this app is posible yous with iPhone conect Robot.", preferredStyle: .actionSheet, actions: [])
        print("awake")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if(con == false && session.isReachable == false){
            let act = WKAlertAction(title: "Conect", style: .default){self.sendMessage(messageToSend:"true",label: "State")}
            let can = WKAlertAction(title: "", style: .cancel) {}
            presentAlert(withTitle: "Conect Robot in iPhone", message: "Yous of this app is posible yous with iPhone conect Robot.", preferredStyle: .actionSheet, actions: [act, can])
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func left_front() {
        if(lf){
            sendMessage(messageToSend: "lf")
        }else{
            sendMessage(messageToSend: "blf")
        }
        lf = !lf
    }
    
    @IBAction func left_back() {
        if(lb){
            sendMessage(messageToSend: "lb")
        }else{
            sendMessage(messageToSend: "blb")
        }
        lb = !lb
    }
    
    @IBAction func right_front() {
        if(rf){
            sendMessage(messageToSend: "rf")
        }else{
            sendMessage(messageToSend: "brf")
        }
        rf = !rf
    }
    
    @IBAction func right_back() {
        if(rb){
            sendMessage(messageToSend: "rb")
        }else{
            sendMessage(messageToSend: "brb")
        }
        rf = !rf
    }
    
    @IBAction func light() {
        sendMessage(messageToSend: "li")
    }
    
    @IBAction func lamp() {
        sendMessage(messageToSend: "la")        
    }
    
    
    
    func sendMessage(messageToSend: String, label: String = "Message") {
        if WCSession.isSupported() {
            print("WCSession supported")
            session.delegate = self
            session.activate()
            if session.isReachable {
                session.sendMessage([label:messageToSend], replyHandler: nil, errorHandler: { error in
                    print("Error sending message",error)
                    self.console.setText("Error sending command")
                })
            }
        }
    }
    
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        if let command = message["Message"] as? String {
            self.console.setText(command + "\n")
        }
        
        if let connected = message["State"] as? String {
            self.console.setText(connected)
            if(connected == "true"){
                con = true
            }
            else{
                con = false
            }
            
        }
    }
}


