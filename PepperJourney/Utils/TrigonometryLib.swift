//
//  trigonometryLib.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 25/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import CoreGraphics

class TrigonometryLib
{
    static func getAngle(p1:CGPoint, p2:CGPoint) -> CGFloat
    {
        let deltaY = p2.y - p1.y
        let deltaX = p2.x - p1.x
        
        let angle = Float(atan2(deltaY, deltaX))
        
        return CGFloat(angle * (180.0 / Float.pi))
    }
}
