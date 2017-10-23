//
//  SeekComponent.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 23/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

class SeekComponent: GKAgent3D
{
    init(target: GKAgent3D)
    {
        super.init()
        let goal = GKGoal(toSeekAgent: target)
        self.behavior = GKBehavior(goal: goal, weight: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
