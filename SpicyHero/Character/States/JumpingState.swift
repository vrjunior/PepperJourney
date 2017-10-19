//
//  JumpingState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 15/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

class JumpingState: BaseState {
    
    override func didEnter(from previousState: GKState?) {
        character.playJumpingAnimation()
        character.jump()
    }
    
    override func willExit(to nextState: GKState) {
        character.stopJumpingAnimation()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == JumpingState.self {
            return false
        }
        
        return true
    }
    
}
