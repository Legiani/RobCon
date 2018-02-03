//
//  myCell.swift
//  RobCon
//
//  Created by Jakub Bednář on 28.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//

//import knihoven
import UIKit
import AVFoundation

//main cell class (hlavní třída cell s vypisem zvuku)
class myCell: UICollectionViewCell {
    
    //definování I/O
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    
    //proměná která obsahuje přehravač/přehrávanou hudbu
    var player: AVAudioPlayer = AVAudioPlayer()
    
    //když je víbrán zvuk
    override var isSelected: Bool{
        //je nastaveno
        didSet{
            //když je zrovna vybrání
            if self.isSelected
            {
                //ochrana
                do {
                    //příkaz pro definování cesty a samotneho souboru
                    try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: self.myLabel.text, ofType: ".mp3")!) as URL)
                    
                } catch {
                    //chyba app zpadne
                 
                }
                //hraj
                player.play()
                //odklikni -> jinak se bude zvuk přehrávat stale dokola
                self.isSelected = false
            }
            //když není nic vybráno
            else
            {
                //obnovení defaultního vzhledu
                self.transform = CGAffineTransform.identity

            }
        }
    }
}
