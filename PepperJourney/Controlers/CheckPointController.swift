//
//  CheckPointController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 12/01/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

class CheckPointController {
    private var nameOfTheIslands = [String]()
    
    init(islandsNumber: Int) {
        // Define um vetor para saber a que ilha pertence o checkpoint
        for number in 0 ..< islandsNumber {
            let name = "Island" + "\(number)"
            self.nameOfTheIslands.append(name)
        }
    }
}
