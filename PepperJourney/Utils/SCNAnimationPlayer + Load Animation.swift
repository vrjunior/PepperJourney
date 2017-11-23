//
//  AnimationUtils.swift
//  SpicyHero
//
//  Created by Valmir Junior on 15/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

extension SCNAnimationPlayer {
    
    // MARK: utils
    
    // Search to first animation in nodes and parse it to animation player
    class func withScene(named: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: named )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }    
}
