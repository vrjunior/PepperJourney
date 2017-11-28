//
//  trigonometryLib.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 25/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import CoreGraphics
import simd

class TrigonometryLib
{
    static func getAngle(p1:CGPoint, p2:CGPoint) -> CGFloat
    {
        let deltaY = p2.y - p1.y
        let deltaX = p2.x - p1.x
        
        let angle = Float(atan2(deltaY, deltaX))
        
        return CGFloat(angle * (180.0 / Float.pi))
    }
    static func getAxisComponents(rad: Float) -> vector_float2 {
        
        var finalRad: Float
        if (rad < 0)
        {
            finalRad = rad + (2 * Float.pi)
        }
        else
        {
            finalRad = rad
        }
        let angle = finalRad * 180 / Float.pi
        
        var components = vector_float2()
        components.x = cos(rad)
        components.y = sin(rad)
        
        print("rad: \(angle) | \(components)")
        return components
    }
}
