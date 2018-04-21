//
//  StandingState.swift
//  SpicyHero
//
//  Created by Valmir Junior on 15/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit

class StandingState: BaseState {

    var timer:Timer = Timer()
    var standingType: AnimationType? = nil
    
    // MARK: GK Overrides
    override func didEnter(from previousState: GKState?) {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(StandingState.runStadingAnimation), userInfo: nil, repeats: true)
    }
    
    @objc func runStadingAnimation() {
        
        //get a random value 0 or 1
        let standing = Int(arc4random_uniform(2))
    
        if(standing == 0) {
            standingType = .standing1
        }
        else {
            standingType = .standing2
        }
        
        character?.playAnimationOnce(type: standingType!)
    }
    
    override func willExit(to nextState: GKState) {
        //invalidate all shedule timers
        timer.invalidate()
        
        if let standingType = self.standingType {
            character?.stopAnimation(type: standingType)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass == StandingState.self {
            return false
        }
        
        return true
    }
    
}
