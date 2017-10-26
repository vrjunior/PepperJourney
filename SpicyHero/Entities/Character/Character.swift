//
//  Character.swift
//  SpicyHero
//
//  Created by Valmir Junior on 06/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameKit
import simd


// Returns plane / ray intersection distance from ray origin.
func planeIntersect(planeNormal: float3, planeDist: Float, rayOrigin: float3, rayDirection: float3) -> Float {
    return (planeDist - simd_dot(planeNormal, rayOrigin)) / simd_dot(planeNormal, rayDirection)
}

class Character: GKEntity {
    
    //speed multiplier
    static private let speedFactor: CGFloat = 30.0
    static private let initialPosition = float3(0, 5, 0)
    
    // actions
    private let jumpImpulse:Float = 200.0
    var direction = float2()
    var walkSpeed: CGFloat = 1.0
    var isWalking: Bool = false
    var isJumping: Bool = false
	static let walkRunPercentage: Float = 0.5
    
    // Direction
    private var previousUpdateTime: TimeInterval = 0
    private var controllerDirection = float2()
    
    // Character handle
    private(set) var node: SCNNode! // top level node
    private(set) var characterNode: SCNNode!
    
    // Camera
    private(set) var visualTarget: SCNNode!
    
    
    //delegates
    var jumpDelegate: JumpDelegate?
    
    // MARK: - Initialization
    init(scene: SCNScene, jumpDelegate: JumpDelegate?) {
        super.init()
        
        self.jumpDelegate = jumpDelegate
        
        self.loadCharacter(scene: scene)
        self.loadAnimations()
        self.loadComponents()
    }
    
    convenience init(scene: SCNScene) {
        self.init(scene: scene, jumpDelegate: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func loadCharacter(scene: SCNScene) {
        /// Load character from external file
        node = scene.rootNode.childNode(withName: "character", recursively: false)
        characterNode = node.childNode(withName: "characterNode", recursively: false)
        self.visualTarget = node.childNode(withName: "visualTarget", recursively: false)
        //characterNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    }
    
    //Load all animation in character node
    private func loadAnimations() {
        let animTypes:[AnimationType] = [.walking, .running, .jumpingImpulse, .jumpingLanding, .standing1, .standing2]
        
        for anim in animTypes {
            let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/character/\(anim.rawValue).dae")
            
            animation.stop()
            
            self.characterNode.addAnimationPlayer(animation, forKey: anim.rawValue)
        }
    }
    
    private func loadComponents() {
        let jumpComponent = JumpComponent(character: self.node, impulse: self.jumpImpulse)
        
        //adding delgate to jump
        jumpComponent.delegate = self.jumpDelegate
        self.addComponent(jumpComponent)
        
        let trackingAgentComponent = GKAgent3D()
        trackingAgentComponent.position = float3(self.node.presentation.position)
        trackingAgentComponent.position.y = 0
        self.addComponent(trackingAgentComponent)
        
    }
    
    // MARK: Animatins Functins
    func playAnimation(type: AnimationType) {
        self.characterNode.animationPlayer(forKey: type.rawValue)?.play()
    }
    
    func playAnimationOnce(type: AnimationType) {
        let animationPlayer = self.characterNode.animationPlayer(forKey: type.rawValue)
        animationPlayer?.play()
        animationPlayer?.stop(withBlendOutDuration: (animationPlayer?.animation.duration)!)
    }
    
    func stopAnimation(type: AnimationType) {
        self.characterNode.animationPlayer(forKey: type.rawValue)?.stop()
    }
    
    
    // MARK: - Controlling the character
    
    private(set) var directionAngle: CGFloat = 0.0 {
        didSet {
            node.runAction(
                SCNAction.rotateTo(x: 0.0, y: directionAngle, z: 0.0, duration: 0.1, usesShortestUnitArc:true))
       }
    }
    
    var num = 0
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
        
        // Move
        if !direction.allZero() {
            characterVelocity = direction * Float(characterSpeed)
            let runModifier = Float(1.0)
            walkSpeed = CGFloat(runModifier * simd_length(direction))
			
            // move character
            directionAngle = CGFloat(atan2f(direction.x, direction.z))
			
			// moving type
			if simd_length(direction) < Character.walkRunPercentage {
				isWalking = true
			}else {
				isWalking = false
			}
		}
        
        if simd_length_squared(characterVelocity) > 10E-4 * 10E-4 {
            let startPosition = node.presentation.simdWorldPosition
            slideInWorld(fromPosition: startPosition, velocity: characterVelocity)
        }
        
        let component = self.component(ofType: GKAgent3D.self)!
        
        component.position.x = self.node.presentation.position.x
        component.position.z = self.node.presentation.position.z
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

        while !stop {
            replacementPoint = start + velocity
            stop = true
        }
        node.simdWorldPosition = replacementPoint
    }

    func resetCharacterPosition() {
        node.simdPosition = Character.initialPosition
    }
    
    
}
