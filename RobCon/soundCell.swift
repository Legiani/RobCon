//
//  myCell.swift
//  RobCon
//
//  Created by Jakub Bednář on 28.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//

// Import knihoven
import UIKit
import AVFoundation

// Main cell class (hlavní třída cell s vypisem zvuku)
class soundCell: UICollectionViewCell {
    
    // Definování I/O
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    // Proměnná, která obsahuje přehrávač/přehrávanou hudbu
    var player: AVAudioPlayer = AVAudioPlayer()
    
    // Když je vybrán zvuk
    override var isSelected: Bool{
        // Je nastaveno
        didSet{
            // Když je vybrán konkrétní zvuk
            if self.isSelected
            {
                // Ochrana
                do {
                    // Příkaz pro definování cesty a samotného souboru
                    try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: self.myLabel.text, ofType: ".mp3")!) as URL)
                    
                } catch {
                    return
                }
                // Hraj
                player.play()
                // Odklikni -> jinak se bude zvuk přehrávat stále dokola
                self.isSelected = false
            }
            // Když není nic vybráno
            else
            {
                // Obnovení defaultního vzhledu
                self.transform = CGAffineTransform.identity

            }
        }
    }
}
