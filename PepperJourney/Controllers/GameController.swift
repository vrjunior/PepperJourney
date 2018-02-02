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
    case box          = 128
    case characters   = 256
    case checkPoint   = 512
}


class GameController: NSObject, SCNSceneRendererDelegate, GameOptions {
    
    var entityManager: EntityManager!
    var character: Character!
    var characterStateMachine: GKStateMachine!
    var gameStateMachine: GKStateMachine!
    var followingCamera: SCNNode!
    var overlayDelegate: UpdateIndicators?
    
    public var scnView: SCNView!
    public var scene: SCNScene!
    private weak var sceneRenderer: SCNSceneRenderer?
    
    //overlays
    open var controlsOverlay: ControlsOverlay?
    open var pauseOverlay: PauseOverlay?
	open var tutorialFase1Overlay: TutorialFase1Overlay?
	
    public weak var cutSceneDelegate: CutSceneDelegate?
    public weak var adVideoDelegate: AdvertisingDelegate?
    
    // Camera and targets
    public var cameraInitialPosition: SCNNode!
    public var followingCameraInitialPosition: SCNNode!
    public var cameraNode: SCNNode!
    public var cameraInitialPresentation: SCNNode!
	
	// Sound Player
    let soundController = SoundController.sharedInstance
    
    var subtitleController = SubtitleController.sharedInstance
    
	// Check point island
    var lastCheckPoint: SCNNode?
    var continueGameEnable: Bool = false
    
    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    
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
    func addNotifications() {
        let nc = NotificationCenter.default
        let pauseNotification = Notification.Name("pauseNotification")
        nc.addObserver(self, selector: #selector(GameController.setPauseByNotification), name: pauseNotification, object: nil)
    }
    
    @objc func setPauseByNotification() {
        self.pause()
    }
    
    func setupCamera() {
        self.followingCamera = self.scene.rootNode.childNode(withName: "followingCamera", recursively: true)
        
        self.cameraNode = self.scene.rootNode.childNode(withName: "camera", recursively: true)
        
        self.followingCameraInitialPosition = self.scene.rootNode.childNode(withName: "followingCameraInitialPosition", recursively: false)
        self.cameraInitialPosition = self.followingCameraInitialPosition.childNode(withName: "cameraInitialPosition", recursively: false)

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
        
//        self.scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
        self.scnView.showsStatistics = true
        
        self.addNotifications()
    }
    
    
    
    func resetCamera() {

        self.cameraNode.constraints = nil
        
        self.followingCamera.position = self.followingCameraInitialPosition.position
        self.followingCamera.eulerAngles = self.followingCameraInitialPosition.eulerAngles
        self.followingCamera.orientation = self.followingCameraInitialPosition.orientation
        
        self.cameraNode.position = self.cameraInitialPosition.position
        self.cameraNode.eulerAngles = self.cameraInitialPosition.eulerAngles
        self.cameraNode.orientation = self.cameraInitialPosition.orientation
        
        self.setupCamera()
        
    }
   
    func setupTapToStart() {
        
        // Do the setup to restart the game
        self.prepereToStartGame()
        
        let tapOverlay = SKScene(fileNamed: "StartOverlay.sks") as! StartOverlay
        tapOverlay.gameOptionsDelegate = self
        tapOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = tapOverlay
        
    }
    func endedAd(wonReward: Bool) {
        if wonReward {
            //reset lifebar
            self.overlayDelegate?.resetLifeIndicator()
            
            //unpause controls
            self.controlsOverlay?.isPausedControl = false
            
            self.continueGameEnable = true
            
            self.startGame()
            
            self.resetCamera()
        }
        // Não ganhou recompensa pq desistiu do video ou houve problema
        else {
            restart()
        }
    }
    
    func prepereToStartGame() {

        self.stopSounds()
        
        entityManager.killAllPotatoes()
        
        self.character.characterNode.isHidden = true
    }
    
    func setupGameOver() {
        
        self.stopSounds()
        
//        self.soundController.playSoundEffect(soundName: "gameOverSound", loops: false, node: self.cameraNode)
        
        let gameOverOverlay = SKScene(fileNamed: "GameOverOverlay.sks") as! GameOverOverlay
        gameOverOverlay.gameOptionsDelegate = self
        gameOverOverlay.scaleMode = .aspectFill
        
        if self.lastCheckPoint == nil {
            gameOverOverlay.setupAds(enableAds: false)
        }
        else {
            gameOverOverlay.setupAds(enableAds: true)
        }
        self.scnView.overlaySKScene = gameOverOverlay
        
        self.gameStateMachine.enter(PauseState.self)
    
    }
    
    func setupFinishLevel() {
        
    }
    
    func initializeTheGame () {
        
        // Show the character
        self.character.characterNode.isHidden = false
        
        // ganhou premio de um ad
        if self.continueGameEnable,
            let checkPoint = self.lastCheckPoint?.parent,
            let potatoesSpawnPosition = checkPoint.childNode(withName: "potatoesPosition", recursively: false)?.worldPosition
        {
            
            let potatoesNumber = self.entityManager.enemyEntities.count
            self.entityManager.killAllPotatoes()
            
            self.character.setupCharacter(initialPosition: checkPoint.worldPosition)
            
            for _ in 0 ..< potatoesNumber {
                entityManager.createEnemy(type: EnemyTypes.potato.rawValue, position: potatoesSpawnPosition, persecutionBehavior: true)
            }
            
        }
        // Usuario nao usou um ad pra continuar
        else {
            self.lastCheckPoint = nil
            // Clean the sounds
            self.stopSounds()
            
            self.character.setupCharacter()
            
            self.entityManager.setupGameInitialization()
        }
        
        // Reset of this flag
        self.continueGameEnable = false
        
        self.resetSounds()
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
    
    
    public func getDeltaTime(updateAtTime: TimeInterval) -> TimeInterval {
        if previousUpdateTime == 0.0 {
            previousUpdateTime = updateAtTime
        }
        
        let deltaTime = updateAtTime - previousUpdateTime
        
        
        self.previousUpdateTime = updateAtTime
        return deltaTime
    }
    // MARK: - Update
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // update characters
        character!.update(atTime: time, with: renderer)
        self.updateFollowingCamera()
        self.entityManager.update(atTime: time)
        
        //TODO: TRATAR ALGUM DIA SE FOR NECESSÁRIO
        if  !self.scene.rootNode.isPaused {
            
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
        
        self.resetCamera()
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

    // Cancela a exibição do Ad
    func cancelAd() {
        self.adVideoDelegate?.cancelAd()
    }
    
    func loadAd(loadedVideoFeedback: @escaping () -> Void) {
        // load and show a rewar ad
        self.adVideoDelegate?.showAd(blockToRunAfter: self.endedAd, loadedVideoFeedback: loadedVideoFeedback)
        
        //Mark:  Use isso para testar sem ter que ver ads
//        self.endedAd(wonReward: true)//apagar delete
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
        
        if !self.character.isJumping {
            self.characterStateMachine.enter(StandingState.self)
        }
    }
    
    
    
    func jump() {
        self.characterStateMachine.enter(JumpingState.self)
    }
    
    func attack() {
        // usado para parar de piscar o botao de attack
        if !(self.controlsOverlay?.tutorialEnded)! {
            self.controlsOverlay?.tutorialEnded = true
            self.cameraNode.removeAllActions()
        }
        
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


