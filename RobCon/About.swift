//
//  about.swift
//  RobCon
//
//  Created by Jakub Bednář on 06.03.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//

import Foundation
import UIKit

class About: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = NSURL (string: "http://robcon.kubabednar.cz");
        let request = NSURLRequest(url: url! as URL);
        webView.loadRequest(request as URLRequest);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        // Volání funkce zavření aktuální stránky
        dismiss(animated: true, completion: nil)
    }
}
