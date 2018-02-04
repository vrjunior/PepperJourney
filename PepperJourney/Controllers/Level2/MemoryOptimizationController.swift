//
//  MemoryOptimizationController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 03/02/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

class MemoryOptimizationController {
    weak var scene: SCNScene!
    var islandsNode: SCNNode!
    var bridgesNode: SCNNode!
    let limitDistance: Float = 800
    var time: TimeInterval = 0
    
    init(scene: SCNScene) {
        self.scene = scene
        
        guard let map = self.scene.rootNode.childNode(withName: "map", recursively: false),
        let islands = map.childNode(withName: "islands", recursively: false),
        let bridges = map.childNode(withName: "bridges", recursively: false) else {
            fatalError("Error getting nodes in MemoryOptimizationController")
        }
        self.islandsNode = islands
        self.bridgesNode = bridges
    }
    
    func update(pepperPosition: SCNVector3, deltaTime: TimeInterval) {
        
        self.time += deltaTime
        
        if self.time < 0.1
        {
            return
        }
        self.time = 0
        
        let islands = self.islandsNode.childNodes
        
        for island in islands {
            let distance = SCNMath.getDistance(point1: pepperPosition, point2: island.worldPosition)
            
            if distance < self.limitDistance {
                island.isHidden = false
            }
            else  {
                island.isHidden = true
            }
        }
        
        let bridges = self.bridgesNode.childNodes
        
        for bridge in bridges {
             let distance = SCNMath.getDistance(point1: pepperPosition, point2: bridge.worldPosition)

            if distance < self.limitDistance {
                bridge.isHidden = false
            }
                
            else {
                bridge.isHidden = true
            }
        }
    }
    
}
