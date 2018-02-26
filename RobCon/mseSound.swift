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

// Sound page class (hlavní třída stránky s vypisem zvuku)
class mseSound: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBAction func back(_ sender: Any) {
        // Zavření aktualní stránky
      dismiss(animated: true, completion: nil)
    }
    
    // Po odevření stránky
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Vrací počet položek v poly s nazvy zvuku
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Config.array.count
    }
    
    // Sestaví všechny cell a nasledně je vypiše
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCell
        // Definování obsahu cell
        cell.myImageView.image = UIImage(named: "loud.png")
        cell.myLabel.text = Config.array[indexPath.row]
        // Vrací hotovou cell
        return cell
    }
    


}
