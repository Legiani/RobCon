//
//  mseSound.swift
//  RobCon
//
//  Created by Jakub Bednář on 28.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//
// Songs is on GPL https://freesound.org/people/Legiani/downloaded_sounds/

// Import knihoven
import UIKit

// Sound page class (hlavní třída stránky s výpisem zvuku)
class RobotSound: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBAction func back(_ sender: Any) {
        // Zavření aktuální stránky
      dismiss(animated: true, completion: nil)
    }
    
    // Po otevření stránky
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Vrací počet položek v poli s názvy zvuku
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Config.voices.count
    }
    
    // Sestaví všechny cell a následně je vypíše
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "soundCell", for: indexPath) as! soundCell
        // Definování obsahu cell
        cell.myImageView.image = UIImage(named: "loud.png")
        cell.myLabel.text = Config.voices[indexPath.row]
        // Vrací hotovou cell
        return cell
    }
    


}
