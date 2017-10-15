//
//  StandingState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 15/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

class BaseState: GKState {
    
    let scene: SCNScene
    let character:Character
    
    init(scene: SCNScene, character: Character) {
        self.scene = scene
        self.character = character
    }
    
    
    // MARK: GK Overrides
    
    
    
}
