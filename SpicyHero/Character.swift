//
//  Character.swift
//  SpicyHero
//
//  Created by Valmir Junior on 06/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import simd


// Returns plane / ray intersection distance from ray origin.
func planeIntersect(planeNormal: float3, planeDist: Float, rayOrigin: float3, rayDirection: float3) -> Float {
    return (planeDist - simd_dot(planeNormal, rayOrigin)) / simd_dot(planeNormal, rayDirection)
}

class Character: NSObject {
    
    static private let speedFactor: CGFloat = 2.0
    static private let collisionMargin = Float(0.04)
    static private let modelOffset = float3(0, -collisionMargin, 0)
    static private let initialPosition = float3(0, 0, 0)
    
    // actions
    var isJump: Bool = false
    var direction = float2()
    var physicsWorld: SCNPhysicsWorld?
    var walkSpeed: CGFloat = 1.0
    var isWalking: Bool = false
    
    // Direction
    private var previousUpdateTime: TimeInterval = 0
    private var controllerDirection = float2()
    
    // Character handle
    private var characterNode: SCNNode! // top level node
    private var characterOrientation: SCNNode! // the node to rotate to orient the character
    private var model: SCNNode! // the model loaded from the character file
    
     private var characterCollisionShape: SCNPhysicsShape?
    
    
    var node: SCNNode! {
        return characterNode
    }
    
    // MARK: - Initialization
    init(scene: SCNScene) {
        super.init()
        
        self.loadCharacter()
        
    }
    
    private func loadCharacter() {
        /// Load character from external file
        let scene = SCNScene( named: "art.scnassets/character/ship.scn")!
        self.model = scene.rootNode.childNode( withName: "shipRootNode", recursively: true)
        self.model.simdPosition = Character.modelOffset
        
        characterNode = SCNNode()
        characterNode.name = "character"
        characterNode.simdPosition = Character.initialPosition
        
        characterOrientation = SCNNode()
        characterNode.addChildNode(characterOrientation)
        characterOrientation.addChildNode(model)
    }
    
    
    // MARK: - Controlling the character
    
    private var directionAngle: CGFloat = 0.0 {
        didSet {
            characterOrientation.runAction(
                SCNAction.rotateTo(x: 0.0, y: directionAngle, z: 0.0, duration: 0.1, usesShortestUnitArc:true))
        }
    }
    
    func update(atTime time: TimeInterval, with renderer: SCNSceneRenderer) {
        var characterVelocity = float3()
        
        let direction = characterDirection(withPointOfView:renderer.pointOfView)
        
        if previousUpdateTime == 0.0 {
            previousUpdateTime = time
        }
        
        let deltaTime = time - previousUpdateTime
        let characterSpeed = CGFloat(deltaTime) * Character.speedFactor * walkSpeed
        //let virtualFrameCount = Int(deltaTime / (1 / 60.0))
        previousUpdateTime = time
        
        // move
        if !direction.isEmpty {
            characterVelocity = direction * Float(characterSpeed)
            var runModifier = Float(1.0)
            #if os(OSX)
                if NSEvent.modifierFlags.contains(.shift) {
                    runModifier = 2.0
                }
            #endif
            walkSpeed = CGFloat(runModifier * simd_length(direction))
            
            // move character
            directionAngle = CGFloat(atan2f(direction.x, direction.z))
            
            self.isWalking = true
        } else {
            self.isWalking = false
        }
        
        if simd_length_squared(characterVelocity) > 10E-4 * 10E-4 {
            let startPosition = characterNode!.presentation.simdWorldPosition
            slideInWorld(fromPosition: startPosition, velocity: characterVelocity)
        }
        
    }
    
    
    func characterDirection(withPointOfView pointOfView: SCNNode?) -> float3 {
        let controllerDir = self.direction
        if controllerDir.isEmpty {
            return float3()
        }
        
        var directionWorld = float3()
        if let pov = pointOfView {
            let p1 = pov.presentation.simdConvertPosition(float3(controllerDir.x, 0.0, controllerDir.y), to: nil)
            let p0 = pov.presentation.simdConvertPosition(float3(), to: nil)
            directionWorld = p1 - p0
            directionWorld.y = 0
            
            if simd_bool(directionWorld != float3()) {
                let minControllerSpeedFactor = Float(0.2)
                let maxControllerSpeedFactor = Float(1.0)
                let speed = simd_length(controllerDir) * (maxControllerSpeedFactor - minControllerSpeedFactor) + minControllerSpeedFactor
                directionWorld = speed * simd_normalize(directionWorld)
            }
        }
        return directionWorld
    }
    
    
    func slideInWorld(fromPosition start: float3, velocity: float3) {
        var stop: Bool = false
        
        var replacementPoint = start
        
        let start = start
        let velocity = velocity
       // let options: [SCNPhysicsWorld.TestOption: Any] = [
        //    SCNPhysicsWorld.TestOption.collisionBitMask: Bitmask.collision.rawValue,
        //    SCNPhysicsWorld.TestOption.searchMode: SCNPhysicsWorld.TestSearchMode.closest]
        while !stop {
            replacementPoint = start + velocity
            stop = true
        }
        characterNode!.simdWorldPosition = replacementPoint
    }
}
