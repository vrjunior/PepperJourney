//
//  GameController.swift
//  SpicyHero
//
//  Created by Valmir Junior on 06/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameController
import SceneKit
import SpriteKit
import GameplayKit


enum ContactType: Int {
    case floor = 0b1 // 1
}

class GameController: NSObject, SCNSceneRendererDelegate {
    
    var character: Character!
    var characterStateMachine: GKStateMachine!
    var potato: PotatoEntity!
    
    private var scene: SCNScene!
    private weak var sceneRenderer: SCNSceneRenderer?
    private var overlay: Overlay?
    
    // Camera and targets
    private var cameraNode: SCNNode!
    private var pepperNode: SCNNode!
    
    // MARK: - Controling the character
    
    var characterDirection: vector_float2 {
        get {
            return character!.direction
        }
        set {
            var direction = newValue
            let l = simd_length(direction)
            if l > 1.0 {
                direction *= 1 / l
            }
            character!.direction = direction
        }
    }
    
    
    func setupCharacter() {
        character = Character(scene: scene!, jumpDelegate: self)
        character.node.physicsBody?.categoryBitMask = 0b1
        
        characterStateMachine = GKStateMachine(states: [
            StandingState(scene: scene, character: character),
            WalkingState(scene: scene, character: character),
            RunningState(scene: scene, character: character),
            JumpingState(scene: scene, character: character),
            JumpingMoveState(scene: scene, character: character)
            ])
        
        characterStateMachine.enter(StandingState.self)
    }
    
    func setupCamera() {
        self.cameraNode = self.scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        guard let characterNode = self.character.node else
        {
            print("Error with the target of the follow camera")
            return
        }
        let lookAtConstraint = SCNLookAtConstraint(target: self.character.visualTarget)
        lookAtConstraint.isGimbalLockEnabled = true
        //lookAtConstraint.influenceFactor = 0.5
        
        let distanceConstraint = SCNDistanceConstraint(target: characterNode)
        
        distanceConstraint.minimumDistance = 20
        distanceConstraint.maximumDistance = 20
        
        let keepAltitude = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { (node: SCNNode, position: SCNVector3) -> SCNVector3 in
            var position = float3(position)
            position.y = self.character.node.presentation.position.y + 15
            return SCNVector3(position)
        }
        
        self.cameraNode.constraints = [lookAtConstraint, distanceConstraint, keepAltitude]
    }
    
    // MARK: Initializer
    init(scnView: SCNView)
    {
        super.init()
        
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
        
        // Uncomment to show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        
        //load the main scene
        //
        self.scene = SCNScene(named: "Game.scnassets/level1.scn")
        
        let overlay = SKScene(fileNamed: "overlay.sks") as! Overlay
        overlay.padDelegate = self
        overlay.movesDelegate = self
        overlay.scaleMode = .aspectFill
        scnView.overlaySKScene = overlay
        
        //load the character
        self.setupCharacter()
        
        self.setupCamera()
        
        self.scene.physicsWorld.contactDelegate = self
    
        scnView.scene = scene
        
        //select the point of view to use
        //sceneRenderer!.pointOfView = self.cameraNode
        
        let trackingAgent = character.component(ofType: GKAgent3D.self)!
        
        self.potato  = PotatoEntity(model: .model1, scene: scene, position: SCNVector3(4,0,10), trakingAgent: trackingAgent)
        
    }
    
    
    // MARK: - Update
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        // update characters
        character!.update(atTime: time, with: renderer)
        
        let seekComponent = self.potato.component(ofType: SeekComponent.self)!
        seekComponent.update(deltaTime: time)

    }
    
    
}

extension GameController : PadOverlayDelegate {
    
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay) {
        characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
    }
    
    
    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay) {
        characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
        
        if(self.character.isJumping) {
            self.characterStateMachine.enter(JumpingMoveState.self)
        }
        else {
            if(character.isWalking) {
                self.characterStateMachine.enter(WalkingState.self)
            }
            else {
                self.characterStateMachine.enter(RunningState.self)
            }
        }
        
    }
    
    
    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay) {
        characterDirection = [0, 0]
        
        self.characterStateMachine.enter(StandingState.self)
    }
    
}

extension GameController : CharacterMovesDelegate {
    func jump() {
        self.characterStateMachine.enter(JumpingState.self)
    }
    
    func attack() {
        
    }
}


extension GameController : JumpDelegate {
    
    func didJumpBegin(node: SCNNode) {
        if(node == character.node) {
            self.character.isJumping = true
        }
    }
}

extension GameController : SCNPhysicsContactDelegate {

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA == self.character.node {
            
            if(self.character.isJumping && contact.nodeB.physicsBody?.contactTestBitMask == ContactType.floor.rawValue) {
                
                //play animation
                self.character.playAnimationOnce(type: .jumpingLanding)
                
                //set the jumping flag to false
                self.character.isJumping = false
                
                //go to standing state mode
                self.characterStateMachine.enter(StandingState.self)
            }
        }
    }
}
