//
//  Overlay.swift
//  SpicyHero
//
//  Created by Valmir Junior on 05/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit

class Overlay: SKScene {
    
    let joystick: TouchJoystick = TouchJoystick()
    
    override func sceneDidLoad() {
        joystick.position = CGPoint(x: 0, y: 0)
        
    }
    
}
