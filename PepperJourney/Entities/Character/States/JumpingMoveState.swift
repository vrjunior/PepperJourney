//
//  JumpingMoveState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 25/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

class JumpingMoveState : BaseState {
    
    // MARK: GK Overrides
    override func didEnter(from previousState: GKState?) {

    }
    
    override func willExit(to nextState: GKState) {

    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == JumpingMoveState.self {
            return false
        }
        if stateClass == RunningState.self {
            return false
        }
        
        return true
    }
    
}
