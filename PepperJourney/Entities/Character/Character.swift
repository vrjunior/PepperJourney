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
    
    
    // Character velocity
    private(set) var characterVelocity = float3()
    
    // value because it is will be update just in moviment of controlls
    private(set) var lastDirection = float3(0,0,1)
    
    //speed multiplier
    static private let speedFactor: CGFloat = 100
    public var initialPosition = float3(0, 0, 0)

    // Sound
    
    
    // actions
    private let jumpImpulse:Float = 800
    var direction = float2()
    var walkSpeed: CGFloat = 1.0
    var isWalking: Bool = false
    var isJumping: Bool = false
	static let walkRunPercentage: Float = 0.7
    
    // Direction
    private var previousUpdateTime: TimeInterval = 0
    private var controllerDirection = float2()
    
    // Character handle
    private(set) var characterNode: SCNNode!
    
    // Camera
    private(set) var visualTarget: SCNNode!
    
    
    //delegates
    var jumpDelegate: JumpDelegate?
    
    var trackingAgentComponent: GKAgent3D!
    
    // MARK: - Initialization
    init(scene: SCNScene, jumpDelegate: JumpDelegate?, soundController: SoundController) {
        super.init()
        
        self.jumpDelegate = jumpDelegate
        
        self.loadCharacter(scene: scene)
        self.loadAnimations()
        self.loadComponents(scene: scene, soundController: soundController)
    }
    
    func setupCharacter() {
        self.characterNode.position = SCNVector3(self.initialPosition)
        self.directionAngle = 0
        self.lastDirection = float3(0,0,1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func loadCharacter(scene: SCNScene) {
        /// Load character from external file
        self.characterNode = scene.rootNode.childNode(withName: "character", recursively: false)
        self.visualTarget = self.characterNode.childNode(withName: "visualTarget", recursively: false)
		
        self.initialPosition = float3(self.characterNode.position)
    }
    
    //Load all animation in character node
    private func loadAnimations() {
        let animTypes:[AnimationType] = [.walking, .running, .jumpingLanding, .jumpingImpulse, .standing1, .standing2]
        
        for anim in animTypes {
            let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/character/\(anim.rawValue).dae")
            
            animation.stop()
            
            self.characterNode.addAnimationPlayer(animation, forKey: anim.rawValue)
        }
    }
    
    private func loadComponents(scene: SCNScene, soundController: SoundController) {
        let jumpComponent = JumpComponent(character: self.characterNode, impulse: self.jumpImpulse)
        
        //adding delgate to jump
        jumpComponent.delegate = self.jumpDelegate
        self.addComponent(jumpComponent)
        
        trackingAgentComponent = GKAgent3D()
        trackingAgentComponent.position = float3(self.characterNode.presentation.position)
        self.addComponent(trackingAgentComponent)
        
        let sinkComponent = SinkComponent(soundController: soundController, node: self.characterNode, entity: self)
        self.addComponent(sinkComponent)
        
        // Attack component
        let attackComponet = AttackComponent(scene: scene)
        self.addComponent(attackComponet)
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
    
    func playOne(type: AnimationType) {
        let animationPlayer = self.characterNode.animationPlayer(forKey: type.rawValue)
        animationPlayer?.animation.repeatCount = 1
        animationPlayer?.play()
    }
    
    func stopAnimation(type: AnimationType) {
        self.characterNode.animationPlayer(forKey: type.rawValue)?.stop()
    }
    
    
    // MARK: - Controlling the character
    
    private(set) var directionAngle: CGFloat = 0.0 {
        didSet {
            self.characterNode.runAction(
                SCNAction.rotateTo(x: 0.0, y: directionAngle, z: 0.0, duration: 0.1, usesShortestUnitArc:true))// 0.1
       }
    }
    
    var num = 0
    func update(atTime time: TimeInterval, with renderer: SCNSceneRenderer) {
        
        self.characterVelocity = float3()
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
            self.lastDirection = direction
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
            let startPosition = self.characterNode.presentation.simdWorldPosition
            slideInWorld(fromPosition: startPosition, velocity: characterVelocity)
        }
        
        trackingAgentComponent.position = float3(self.characterNode.presentation.position)
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
        self.characterNode.simdWorldPosition = replacementPoint
    }

    func resetCharacterPosition() {
        self.characterNode.simdPosition = self.initialPosition
    }
    
    
}
