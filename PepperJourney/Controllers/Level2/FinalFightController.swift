//
//  FinalFightController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 19/01/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

class FinalFightController {
    var bigBridgeNode = [SCNNode]()
    init(scene: SCNScene) {
        
        guard let map = scene.rootNode.childNode(withName: "map", recursively: false),
        let bridges = map.childNode(withName: "bridges", recursively: false),
        let bigBridge = bridges.childNode(withName: "bigBridge", recursively: false),
        let halfBigBridge1 = bigBridge.childNode(withName: "halfBigBridge1", recursively: false),
        let halfBigBridge2 = bigBridge.childNode(withName: "halfBigBridge2", recursively: false) else {
                fatalError("Error getting big bridge")
        }
        self.bigBridgeNode = [halfBigBridge1, halfBigBridge2]
        
        self.resetFinalFight()
        
    }
    
    public func lowerTheBigBridge() {
        self.bigBridgeNode[0].physicsBody?.categoryBitMask = CategoryMaskType.solidSurface.rawValue
        self.bigBridgeNode[1].physicsBody?.categoryBitMask = CategoryMaskType.solidSurface.rawValue
        
        self.bigBridgeNode[0].runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 3))
        self.bigBridgeNode[1].runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 3))
    }
    
    func resetBridge() {
        
        self.bigBridgeNode[0].physicsBody?.categoryBitMask = CategoryMaskType.obstacle.rawValue
        self.bigBridgeNode[1].physicsBody?.categoryBitMask = CategoryMaskType.obstacle.rawValue
        
        self.bigBridgeNode[0].eulerAngles.x = -Float.pi / 4
        self.bigBridgeNode[1].eulerAngles.x = Float.pi / 4
    }
    
    func resetFinalFight() {
        self.resetBridge()
    }
    
    
}
