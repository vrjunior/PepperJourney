//
//  JumpingState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 15/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

class JumpingState: BaseState
{
    var isJumping: Bool = false
    
    override func didEnter(from previousState: GKState?) {
        character.playAnimation(type: .jumping)
        for comp in character.components {
            if comp is JumpComponent {
                let jumpComp = comp as! JumpComponent
                jumpComp.jump()
            }
        }
    }
    
    override func willExit(to nextState: GKState) {
        character.stopAnimation(type: .jumping)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == JumpingState.self {
            return false
        }
        
        return true
    }
    
}
