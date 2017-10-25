//
//  RunningState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 15/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

class RunningState: BaseState {
    
    // MARK: GK Overrides
    override func didEnter(from previousState: GKState?) {
        self.character.playAnimation(type: .running)
    }
    
    override func willExit(to nextState: GKState) {
        self.character.stopAnimation(type: .running)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == RunningState.self {
            return false
        }
        
        return true 
    }
    
}

