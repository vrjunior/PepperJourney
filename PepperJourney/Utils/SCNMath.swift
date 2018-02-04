//
//  SCNMath.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 03/02/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

class SCNMath {
    static func getDistance(point1: SCNVector3, point2: SCNVector3) -> Float {
        let deltaX = point1.x - point2.x
        let deltaY = point1.y - point2.y
        let deltaZ = point1.z - point2.z
        
        return sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
    }
}

