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


enum CategoryMaskType: Int {
    case character  = 0b1       // 1
    case floor      = 0b10      // 2
    case potato     = 0b100     // 4
    case obstacle   = 0b1000    // 8
}

class GameController: NSObject, SCNSceneRendererDelegate {
    
    var entityManager: EntityManager!
    var character: Character!
    var characterStateMachine: GKStateMachine!
    var gameStateMachine: GKStateMachine!
    
    private var scnView: SCNView!
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
        
        characterStateMachine = GKStateMachine(states: [
            StandingState(scene: scene, character: character),
            WalkingState(scene: scene, character: character),
            RunningState(scene: scene, character: character),
            JumpingState(scene: scene, character: character),
            JumpingMoveState(scene: scene, character: character)
            ])
        
    }
    
    func setupCamera() {
        self.cameraNode = self.scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        guard let characterNode = self.character.node else {
            print("Error with the target of the follow camera")
            return
        }
        let lookAtConstraint = SCNLookAtConstraint(target: self.character.visualTarget)
        lookAtConstraint.isGimbalLockEnabled = true
        //lookAtConstraint.influenceFactor = 0.5
        
        let distanceConstraint = SCNDistanceConstraint(target: characterNode)
        
        distanceConstraint.minimumDistance = 20
        distanceConstraint.maximumDistance = 30
        
        let keepAltitude = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { (node: SCNNode, position: SCNVector3) -> SCNVector3 in
            var position = float3(position)
            position.y = self.character.node.presentation.position.y + 15
            return SCNVector3(position)
        }
        
        self.cameraNode.constraints = [lookAtConstraint, distanceConstraint, keepAltitude]
    }
    
    func setupGame() {
        gameStateMachine = GKStateMachine(states: [
            PauseState(scene: scene),
            PlayState(scene: scene) ])
    }
    
    // MARK: Initializer
    init(scnView: SCNView) {
        super.init()
        
        //set scnView
        self.scnView = scnView
        
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
                
        //load the main scene
		self.scene = SCNScene(named: "Game.scnassets/Fase1Runner.scn")
        
        //setup game state machine
        self.setupGame()
        
        //load the character
        self.setupCharacter()
        
        self.setupCamera()
        
        self.scene.physicsWorld.contactDelegate = self
    
        scnView.scene = scene
        
        // Create the entity manager system
        self.entityManager = EntityManager(scene: self.scene, character: self.character)
        
        //setup tap to start
        self.setupTapToStart()
		
    }
    
    func initializeTheGame () {
//        guard let node = character.component(ofType: ModelComponent.self)?.modelNode else
//        {
//            fatalError("Character node not found")
//        }
        
        // Show de character
        self.character.node.isHidden = false

        self.entityManager.setupGameInitialization()
        
        self.character.node.position = SCNVector3(Character.initialPosition)
        self.character.node.eulerAngles = SCNVector3(0,0,0)
    }
   
    func setupTapToStart() {
        let tapOverlay = SKScene(fileNamed: "StartOverlay.sks") as! StartOverlay
        tapOverlay.tapDelegate = self
        tapOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = tapOverlay
        
        self.gameStateMachine.enter(PauseState.self)

    }
    
    func setupGameOver() {
       
        entityManager.killAllPotatoes()
        self.character.node.isHidden = true
        let gameOverOverlay = SKScene(fileNamed: "GameOverOverlay.sks") as! GameOverOverlay
        gameOverOverlay.gameOverDelegate = self
        gameOverOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = gameOverOverlay
        
        self.gameStateMachine.enter(PauseState.self)
        
    }
    
    func startGame() {
        // Inittialize the game with the defaults settings.
        self.initializeTheGame()
        
        let overlay = SKScene(fileNamed: "ControlsOverlay.sks") as! Overlay
        overlay.padDelegate = self
        overlay.controlsDelegate = self
        overlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = overlay
        
        self.gameStateMachine.enter(PlayState.self)
        
        characterStateMachine.enter(StandingState.self)
    }
    
    // MARK: - Update
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // update characters
        character!.update(atTime: time, with: renderer)
        
        self.entityManager.update(deltaTime: time)
    }
}

extension GameController : PadOverlayDelegate {
    
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay)
    {
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

extension GameController : Controls {
    func jump() {
        self.characterStateMachine.enter(JumpingState.self)
    }
    
    func attack() {
        
    }
    
    func pause() {
        print("pause pressed")
        //self.gameStateMachine.enter(PauseState.self)
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
		
        var characterNode: SCNNode?
        var anotherNode: SCNNode?
        
        if contact.nodeA == self.character.node {
            
            characterNode = contact.nodeA
            anotherNode = contact.nodeB
        
        } else if contact.nodeB == self.character.node {
            characterNode = contact.nodeB
            anotherNode = contact.nodeA
		}
    
        if characterNode != nil {
            if anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.potato.rawValue {
                
                DispatchQueue.main.async { [unowned self] in
                    self.setupGameOver()
                }
        
            }
        
            else if(self.character.isJumping && anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.floor.rawValue) {
        
            //stop impulse animation
            self.character.stopAnimation(type: .jumpingImpulse)
        
            //play landing animation
            self.character.playAnimationOnce(type: .jumpingLanding)
        
            //set the jumping flag to false
            self.character.isJumping = false
        
            //go to standing state mode
            self.characterStateMachine.enter(StandingState.self)
            }
        }
    }
}

extension GameController : TapToStartDelegate {
    func didTap() {
        self.startGame()
    }
}

extension GameController : GameOverDelegate {
    func didTapToRestart() {
        self.startGame()
    }
}
