//
//  Config.swift
//  RobCon
//
//  Created by Jakub Bednář on 12.02.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//

import Foundation

struct Config {
    // Název zařízení
    static let mse = "MSE-6"
    // Název přepoje, který se vyvolá po rozkliknutí
    static let mse_page = "msePage"
    // Název zařízení
    static let r2 = "R2-D2"
    // Název přepoje, který se vyvolá po rozkliknutí
    static let r2_page = "rPage"
 
    // Výchozí stránku pro zařízení s nedefinovaným názvem
    static let def_page = "consolePage"
    
    // Příkazy odesílané po kliknutí na příslušnou ikonu
    // Příkazy bez prefixu si zařízení drží sepnuté do dalšího přijetí stejného příkazu
    static let Lamp = "a"
    static let Light = "s"
    static let Action = "u"
    
    // Příkazy s prefixem
    // Zařízení dostane příkaz a ten bude vykonávat do přijetí stejneho přikazu s prefixem
    static let invers_prefix = "b"
    
    static let Left_front = "n"
    static let Left_back = "d"
    static let Right_front = "p"
    static let Right_back = "l"
    
    // Pohyb rukou
    static let Arm_up = "x"
    static let Arm_down = "y"
    static let Arm_rotate = "c"
    
    // Pole názvu zvuků, které budou vypsány
    static let voices:[String] = ["aust-paul__whatever",
                          "screamstudio__robot",
                          "fullmetaljedi__r2d2-sad",
                          "owlstorm__retro",
                          "urupin__robot",
                          "wubitog__space-beam"]
    
}
