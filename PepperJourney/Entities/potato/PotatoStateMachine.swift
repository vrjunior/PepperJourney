//
//  BaseState.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 31/01/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

class PotatoStateMachine: GKStateMachine {
    
    init(states: [PotatoState], potato: PotatoEntity) {
        for state in states {
            state.setPotatoEntity(potato: potato)
        }
        super.init(states: states)   
    }
}

class PotatoState: GKState {
    weak var potato: PotatoEntity?
    var animation: AnimationType!
    
    init(animation: AnimationType) {
        self.animation = animation
    }
    
    public func setPotatoEntity(potato: PotatoEntity) {
        self.potato = potato
    }
    
    override func didEnter(from previousState: GKState?) {
        self.potato?.playAnimation(type: animation)
    }
    
    override func willExit(to nextState: GKState) {
        self.potato?.stopAnimation(type: animation)
    }
}

class RunningPotatoState: PotatoState {
    
}

class AttackPotatoState: PotatoState {
    
}

class BeatingSpearPotatoState: PotatoState {
    
}
