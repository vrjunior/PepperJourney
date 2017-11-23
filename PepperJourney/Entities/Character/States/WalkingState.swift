//
//  WalkingState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 20/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

class WalkingState: BaseState {
    
    // MARK: GK Overrides
    override func didEnter(from previousState: GKState?) {
        self.character.playAnimation(type: .walking)
    }
    
    override func willExit(to nextState: GKState) {
        self.character.stopAnimation(type: .walking)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == WalkingState.self {
            return false
        }
        
        return true
    }
    
}

