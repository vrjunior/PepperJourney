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
    case pepper       = 0b1         // 1
    case solidSurface = 0b10        // 2
    case potato       = 0b100       // 4
    case lake         = 0b1000      // 8
    case obstacle     = 0b10000     // 16
    case finalLevel   = 0b100000    // 32
    case fireBall     = 64
    case box          = 128  // 128
    case characters   = 0b100000000 // 256
}


class GameController: NSObject, SCNSceneRendererDelegate, GameOptions {
    
    var entityManager: EntityManager!
    var character: Character!
    var characterStateMachine: GKStateMachine!
    var gameStateMachine: GKStateMachine!
    var followingCamera: SCNNode!
    var overlayDelegate: UpdateIndicators?
    
    open var scnView: SCNView!
    open var scene: SCNScene!
    private weak var sceneRenderer: SCNSceneRenderer?
    
    //overlays
    open var controlsOverlay: ControlsOverlay?
    open var pauseOverlay: PauseOverlay?
	open var tutorialFase1Overlay: TutorialFase1Overlay?
	
    public weak var cutSceneDelegate: CutSceneDelegate?
    
    // Camera and targets
    open var cameraInitialPosition: SCNVector3!
	open var cameraInitialPresentation: SCNNode!
    open var cameraNode: SCNNode!
    open var pepperNode: SCNNode!
	
	// Sound Player
    open let soundController = SoundController.sharedInstance
    
    var subtitleController = SubtitleController.sharedInstance
	
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
	
    func resetSounds() {
        // Restart the background music
        self.soundController.playbackgroundMusic(soundName: "backgroundMusic", loops: true, node: self.cameraNode)
        
    }
    
    func stopSounds() {
        // Clean all the sounds
        soundController.stopSoundsFromNode(node: self.cameraNode)
        soundController.stopSoundsFromNode(node: self.character.characterNode)
    }
    func setupSounds() {
        
    }
    func setupCharacter() {
        // create the character with your components
        self.character = self.entityManager.character
        self.character.setupCharacter()
        
        characterStateMachine = GKStateMachine(states: [
            StandingState(scene: scene, character: character),
            WalkingState(scene: scene, character: character),
            RunningState(scene: scene, character: character),
            JumpingState(scene: scene, character: character),
            JumpingMoveState(scene: scene, character: character),
            AttackState(scene: scene, character: character)
            ])
        
    }
    
    func setupCamera() {
        self.followingCamera = self.scene.rootNode.childNode(withName: "followingCamera", recursively: true)
        
        self.cameraNode = self.scene.rootNode.childNode(withName: "camera", recursively: true)!
        self.cameraInitialPosition = cameraNode.presentation.position
        
        let lookAtConstraint = SCNLookAtConstraint(target: self.character.visualTarget)
        lookAtConstraint.isGimbalLockEnabled = true
        lookAtConstraint.influenceFactor = 1
        
        let distanceConstraint = SCNDistanceConstraint(target: self.character.characterNode)
        distanceConstraint.minimumDistance = 45
        distanceConstraint.maximumDistance = 45
        
        let keepAltitude = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { (node: SCNNode, position: SCNVector3) -> SCNVector3 in
            var position = float3(position)
            position.y = self.character.characterNode.presentation.position.y + 20
            if position.y < 10
            {
                position.y = 10
            }
            return SCNVector3(position)
        }
        
        self.cameraNode.constraints = [lookAtConstraint, distanceConstraint , keepAltitude]
    }
    
    func setupGame() {
        gameStateMachine = GKStateMachine(states: [
            PauseState(scene: scene),
            PlayState(scene: scene) ])
        
        self.gameStateMachine.enter(PauseState.self)
    }
    
    // MARK: Initializer
    init(scnView: SCNView) {
        super.init()
        
        //set scnView
        self.scnView = scnView
        
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
        
       // self.scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
        self.scnView.showsStatistics = true
        
    }
    
    func initializeTheGame () {
        
        // Show de character
        self.character.characterNode.isHidden = false

        self.entityManager.setupGameInitialization()
        
        // Reset of all the sounds
        self.resetSounds()
        
        self.character.setupCharacter()
        
        self.cameraNode.position = self.cameraInitialPosition
		
    }
   
    func setupTapToStart() {
        
        // Do the setup to restart the game
        self.prepereToStartGame()
        
        let tapOverlay = SKScene(fileNamed: "StartOverlay.sks") as! StartOverlay
        tapOverlay.gameOptionsDelegate = self
        tapOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = tapOverlay
        
    }
    func prepereToStartGame() {
        self.stopSounds()
        
        entityManager.killAllPotatoes()
        
        self.character.characterNode.isHidden = true
    }
    
    func setupGameOver() {
        
        // Do the setup to restart the game
        self.prepereToStartGame()
       
        self.soundController.playSoundEffect(soundName: "gameOverSound", loops: false, node: self.cameraNode)
        
        let gameOverOverlay = SKScene(fileNamed: "GameOverOverlay.sks") as! GameOverOverlay
        gameOverOverlay.gameOptionsDelegate = self
        gameOverOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = gameOverOverlay
        
         //self.gameStateMachine.enter(PauseState.self)
        
    }
    
    func setupFinishLevel() {

    }
    
    func startGame() {
    
        // Inittialize the game with the defaults settings.
        self.initializeTheGame()
        
        if controlsOverlay == nil {
            controlsOverlay = SKScene(fileNamed: "ControlsOverlay.sks") as? ControlsOverlay
            controlsOverlay?.controlsDelegate = self
            controlsOverlay?.gameOptionsDelegate = self
            controlsOverlay?.scaleMode = .aspectFill
            
            //setting updateDelegate
            self.overlayDelegate = controlsOverlay
            
            self.subtitleController.overlayDelegate = controlsOverlay
            
        }
        
        self.scnView.overlaySKScene = controlsOverlay
        
        gameStateMachine.enter(PlayState.self)
        characterStateMachine.enter(StandingState.self)
    }
    
    // MARK: - Update
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // update characters
        character!.update(atTime: time, with: renderer)
        self.updateFollowingCamera()
        if  !self.scene.rootNode.isPaused {
            self.entityManager.update(atTime: time)
            SubtitleController.sharedInstance.update(systemTime: time)
        }
        
    }
    
    func handleWithPhysicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    }
    
    func rotateCamera(byAngle angle: CGFloat, withDuration duration: Double) {
        let rotateAction = SCNAction.rotateBy(x: 0, y: angle, z: 0, duration: duration)
        self.followingCamera.runAction(rotateAction)
    }
    
    func updateFollowingCamera() {
        self.followingCamera.position = self.character.characterNode.presentation.position
    }
    
    //:MARK GAME OPTIONS
    
    func start() {
        self.startGame()
    }
    
    func restart() {
        //reset lifebar
        self.overlayDelegate?.resetLifeIndicator()
        
        // Do the setup to restart the game
        self.prepereToStartGame()
        
        //unpause controls
        self.controlsOverlay?.isPausedControl = false
        
        self.startGame()
    }
    
    func resume() {
        self.gameStateMachine.enter(PlayState.self)
        
        //unpause controls
        self.controlsOverlay?.isPausedControl = false
        
        self.scnView.overlaySKScene = controlsOverlay
    }
    
    func pause() {
        if(!self.scene.isPaused){
            
            if self.pauseOverlay == nil {
                self.pauseOverlay = SKScene(fileNamed: "PauseOverlay.sks") as? PauseOverlay
                self.pauseOverlay?.scaleMode = .aspectFill
                self.pauseOverlay?.gameOptionsDelegate = self
            }
            
            self.scnView.overlaySKScene = self.pauseOverlay
            self.gameStateMachine.enter(PauseState.self)
            
            //pause controls
            self.controlsOverlay?.isPausedControl = true
        }
        
    }
    
	func tutorialFase1(fase1: Fase1GameController) {
        
        if(!self.scene.isPaused){
            if self.tutorialFase1Overlay == nil {
                self.tutorialFase1Overlay = SKScene(fileNamed: "TutorialFase1Overlay.sks") as? TutorialFase1Overlay
                self.tutorialFase1Overlay?.scaleMode = .aspectFill
                self.tutorialFase1Overlay?.gameOptionsDelegate = self
				self.tutorialFase1Overlay?.fase1GameController = fase1
            }
            
            self.scnView.overlaySKScene = self.tutorialFase1Overlay
            self.gameStateMachine.enter(TutorialFase1State.self)
        }
    }
    
//    func skipTutorial() {
//        self.resume()
//    }
}

extension GameController : Controls {
    
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
    
    
    
    func jump() {
        self.characterStateMachine.enter(JumpingState.self)
    }
    
    func attack() {
        self.characterStateMachine.enter(AttackState.self)
    }
    
    func rotateCamera(angle: CGFloat) {
        let duration: Double = 0.1
        self.rotateCamera(byAngle: angle, withDuration: duration)
    }

}


extension GameController : JumpDelegate {
    
    func didJumpBegin(node: SCNNode) {
        if(node == character.characterNode) {
            self.soundController.playSoundEffect(soundName: "jump", loops: false, node: character.characterNode)
            self.character.isJumping = true
        }
    }
}


extension GameController : SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        self.handleWithPhysicsWorld(world, didBegin: contact)
        
    }
}


