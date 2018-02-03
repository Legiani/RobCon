//
//  mseSound.swift
//  RobCon
//
//  Created by Jakub Bednář on 28.01.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//
// Songs is on GPL https://freesound.org/people/Legiani/downloaded_sounds/

//import knihoven
import UIKit

//sound page class (hlavní třída stránky s vypisem zvuku)
class mseSound: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //pole nazvu zvuku které budou vypsány
    let array:[String] = ["aust-paul__whatever",
                          "screamstudio__robot",
                          "fullmetaljedi__r2d2-sad",
                          "owlstorm__retro",
                          "urupin__robot",
                          "wubitog__space-beam"]
    
    //po odevření stránky
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //vrací počet položek v poly s nazvy zvuku
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    //sestaví všechny cell a nasledně je vypiše
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCell
        //definování obsahu cell
        cell.myImageView.image = UIImage(named: "loud.png")
        cell.myLabel.text = array[indexPath.row]
        //vrací hotovou cell
        return cell
    }
    


}
