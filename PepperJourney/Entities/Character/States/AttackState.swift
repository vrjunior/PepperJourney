//
//  AttackState.swift
//  PepperJourney
//
//  Created by Valmir Junior on 11/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

class AttackState : BaseState {
    weak var targetNode: SCNNode?
    private var animationType: AnimationType?
    let attackForceModule: Float = 10
    
    
    init(targetNode: SCNNode) {
        super.init()
        self.targetNode = targetNode
        
    }
    override func didEnter(from previousState: GKState?) {
        
        self.shootFireBall()
        
//        if previousState is RunningState {
//            animationType = .runningAttack
//        } else if previousState is StandingState {
//            animationType = .standingAttack
//        } else if previousState is WalkingState {
//            animationType = .walkingAttack
//        }
        
//        if let animationType = animationType {
//            character.playAnimationOnce(type: animationType)
//        }
        
    }
    
    override func willExit(to nextState: GKState) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == JumpDelegate.self {
            return false
        }
        
        if stateClass == JumpingMoveState.self {
            return false
        }
        
        return true
    }
    
    func shootFireBall() {
        guard let attackLimiterComponent = self.character?.component(ofType: AttackLimiterComponent.self),
        let target = self.targetNode else
        {
            fatalError("Error getting attack limiter component")
        }
        
        
        attackLimiterComponent.tryAttack(character: self.character!, forceModule: attackForceModule)
    }
    
}
