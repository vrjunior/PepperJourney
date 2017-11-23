//
//  PotatoGenerator.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 29/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

class PotatoGenerator
{
    private(set) var distanceToCreate: Float
    private(set) var position: SCNVector3
    
    init(position: SCNVector3, distanceToCreate: Float) {
        self.position = position
        self.distanceToCreate = 100
    }
    
   
    func isReady(characterPosition: SCNVector3) -> Bool
    {
        let distance = self.getDistance(node1: position, node2: characterPosition)
        
        if distance < self.distanceToCreate
        {
            return true
        }
        return false
    }
    func getDistance(node1: SCNVector3, node2: SCNVector3) -> Float
    {
        let deltaX = node2.x - node1.x
        let deltaY = node2.y - node1.y
        let deltaZ = node2.z - node1.z
        return sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ))
    }
}
