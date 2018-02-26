//
//  Config.swift
//  RobCon
//
//  Created by Jakub Bednář on 12.02.18.
//  Copyright © 2018 Jakub Bednář. All rights reserved.
//

import Foundation

struct Config {
    // Nazev zařízení
    static let mse = "MSE-6"
    // Nazev přepoje který se vyvolá po rozkliknutí
    static let mse_page = "msePage"
    // Nazev zařízení
    static let r2 = "R2-D2"
    // Nazev přepoje který se vyvolá po rozkliknutí
    static let r2_page = "rPage"
 
    // Vychozí stránku pro zařízení s nedefinovaným názvem
    static let def_page = "consolePage"
    
    // Příkazy odesílané po kliknutí na přislušnou ikonu
    // přikazi bez prefixu si zařízení drží seple do dalšího přijetí stejneho příkazu
    static let Lamp = "a"
    static let Light = "s"
    static let Action = "u"
    
    // Příkazi s prefixem
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
    
    // Pole nazvu zvuku které budou vypsány
    static let array:[String] = ["aust-paul__whatever",
                          "screamstudio__robot",
                          "fullmetaljedi__r2d2-sad",
                          "owlstorm__retro",
                          "urupin__robot",
                          "wubitog__space-beam"]
}
