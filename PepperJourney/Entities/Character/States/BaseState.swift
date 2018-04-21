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
    
    public weak var scene: SCNScene?
    public weak var character:Character?
    
    public func setupState(scene: SCNScene, character: Character) {
        self.scene = scene
        self.character = character
    }
    
}
