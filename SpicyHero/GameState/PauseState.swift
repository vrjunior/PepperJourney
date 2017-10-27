//
//  PauseState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 27/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

class PauseState: GameBaseState {
    
    override func didEnter(from previousState: GKState?) {
        self.scene.isPaused = true
    }
    
}
