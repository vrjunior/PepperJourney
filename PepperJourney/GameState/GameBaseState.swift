//
//  GameBaseState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 27/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

class GameBaseState: GKState {
    var scene:SCNScene!
    
    init(scene: SCNScene) {
        self.scene = scene
    }
}
