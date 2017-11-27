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
    case character    = 0b1         // 1
    case solidSurface = 0b10        // 2
    case potato       = 0b100       // 4
    case lake         = 0b1000      // 8
    case obstacle     = 0b10000     // 16
    case finalLevel   = 0b100000    // 32
}


class GameController: NSObject, SCNSceneRendererDelegate {
    
    var entityManager: EntityManager!
    var character: Character!
    var characterStateMachine: GKStateMachine!
    var gameStateMachine: GKStateMachine!
    
    private var scnView: SCNView!
    private var scene: SCNScene!
    private weak var sceneRenderer: SCNSceneRenderer?
    
    //overlays
    private var controlsOverlay: ControlsOverlay?
    private var pauseOverlay: PauseOverlay?
    
    // Camera and targets
    private var cameraInitialPosition: SCNVector3!
    private var cameraNode: SCNNode!
    private var pepperNode: SCNNode!
	
	// Sound Player
    let soundController = SoundController.sharedInstance

	
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
	
    func resetSounds()
    {
        // Restart the background music
        self.soundController.playbackgroundMusic(soundName: "backgroundMusic", loops: true, node: self.cameraNode)
        
    }
    
    func stopSounds()
    {
        // Clean all the sounds
        soundController.stopSoundsFromNode(node: self.cameraNode)
        soundController.stopSoundsFromNode(node: self.character.node)
    }
    func setupSounds() {
        
        self.soundController.loadSound(fileName: "gameBackground.mp3", soundName: "backgroundMusic", volume: 0.5)
        
        
        self.soundController.loadSound(fileName: "GameOver-Game_over.wav", soundName: "gameOverSound", volume: 0.5)
        
        // Finish Level sound
        self.soundController.loadSound(fileName: "FinishLevel-jingle-win-00.wav", soundName: "FinishLevelSound", volume: 0.5)
        
        
        //setup character sounds
        self.soundController.loadSound(fileName: "jump.wav", soundName: "jump", volume: 1.0)
        
    }
    func setupCharacter() {
        // create the character with your components
       self.character = self.entityManager.character
        
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
        self.cameraInitialPosition = cameraNode.presentation.position
        
        guard let characterNode = self.character.node else {
            fatalError("Error with the target of the follow camera")
        }
        
        let lookAtConstraint = SCNLookAtConstraint(target: self.character.visualTarget)
        lookAtConstraint.isGimbalLockEnabled = true
        lookAtConstraint.influenceFactor = 1
        
        let distanceConstraint = SCNDistanceConstraint(target: characterNode)
        
        distanceConstraint.minimumDistance = 45
        distanceConstraint.maximumDistance = 45
        
        let keepAltitude = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { (node: SCNNode, position: SCNVector3) -> SCNVector3 in
            var position = float3(position)
            position.y = self.character.node.presentation.position.y + 20
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
		self.scene = SCNScene(named: "Game.scnassets/Fase1.scn")
        
        //setup game state machine
        self.setupGame()
        
       
        
        self.scene.physicsWorld.contactDelegate = self
    
        scnView.scene = scene
        
        //self.scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
//        self.scnView.showsStatistics = true
        
        // Create the entity manager system
        self.entityManager = EntityManager(scene: self.scene, gameController: self, soundController: self.soundController)
        
        //load the character
        self.setupCharacter()
        
         self.setupCamera()
        
        //setup tap to start
        self.setupTapToStart()
        
        // Pre-load all the audios of the game in the memory
        self.setupSounds()
		
    }
    
    func initializeTheGame () {
//        guard let node = character.component(ofType: ModelComponent.self)?.modelNode else
//        {
//            fatalError("Character node not found")
//        }
        
        // Show de character
        self.character.node.isHidden = false

        self.entityManager.setupGameInitialization()
        
        // Reset of all the sounds
        self.resetSounds()
        
        self.character.node.position = SCNVector3(self.character.initialPosition)
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
    func prepereToStartGame()
    {
        self.stopSounds()
        
        entityManager.killAllPotatoes()
        
        self.character.node.isHidden = true
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
        self.prepereToStartGame()
        self.soundController.playSoundEffect(soundName: "FinishLevelSound", loops: false, node: self.cameraNode)
        let finishLevelOverlay = SKScene(fileNamed: "FinishOverlay.sks")
        finishLevelOverlay?.scaleMode = .aspectFill
        self.scnView.overlaySKScene = finishLevelOverlay
        
        //self.gameStateMachine.enter(PauseState.self)
    }
    
    func startGame() {
        // Inittialize the game with the defaults settings.
        self.initializeTheGame()
        
        if controlsOverlay == nil {
            controlsOverlay = SKScene(fileNamed: "ControlsOverlay.sks") as? ControlsOverlay
            controlsOverlay?.padDelegate = self
            controlsOverlay?.controlsDelegate = self
            controlsOverlay?.gameOptionsDelegate = self
            controlsOverlay?.scaleMode = .aspectFill
        }
        
        self.scnView.overlaySKScene = controlsOverlay
        
        gameStateMachine.enter(PlayState.self)
        characterStateMachine.enter(StandingState.self)
    }
    
    // MARK: - Update
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // update characters
        character!.update(atTime: time, with: renderer)
        
        self.entityManager.update(atTime: time)
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
        //self.characterStateMachine.enter(JumpingState.self)
       
        self.attack()
    }
    
    func attack() {
        
        guard let attackComponent = self.character.component(ofType: AttackComponent.self) else
        {
            fatalError("Error getting attack component")
        }
        
        var lauchPosition = self.character.node.presentation.position
        lauchPosition.y = 60
        
        attackComponent.atack(launchPosition: lauchPosition, direction: self.characterDirection)
    }

}


extension GameController : JumpDelegate {
    
    func didJumpBegin(node: SCNNode) {
        if(node == character.node) {
            self.soundController.playSoundEffect(soundName: "jump", loops: false, node: character.node)
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
        }
            
        else if contact.nodeB == self.character.node
        {
            characterNode = contact.nodeB
            
            anotherNode = contact.nodeA
        }
        
        if characterNode != nil
        {
            
                
            if self.character.isJumping && anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.solidSurface.rawValue {
                
                //set the jumping flag to false
                self.character.isJumping = false
                
                //stop impulse animation
                self.character.stopAnimation(type: .jumpingImpulse)
                
                //play landing animation
                self.character.playAnimationOnce(type: .jumpingLanding)
                
                
                //go to standing state mode
                self.characterStateMachine.enter(StandingState.self)
            }
            // foi pego por uma batata
            else if anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.potato.rawValue {
                DispatchQueue.main.async { [unowned self] in
                    self.setupGameOver()
                }
                
            }
                
            else if anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.lake.rawValue {
                
                if anotherNode?.name == "lakeBottom"
                {
                    DispatchQueue.main.async { [unowned self] in
                        self.setupGameOver()
                    }
                }
                // When the character thouches the lake surface
                else if anotherNode?.name == "lakeSurface"
                {
                    let sinkComponent = self.entityManager.getComponent(entity: self.character, ofType: SinkComponent.self) as! SinkComponent
                    sinkComponent.sinkInWater()
                    
                    //pause controls
                    self.controlsOverlay?.isPausedControl = true
                }
            }
            
            // venceu a fase
            else if anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.finalLevel.rawValue {
    
                DispatchQueue.main.async { [unowned self] in
                    self.setupFinishLevel()
                }
                
            }
            // ja resolveu o que tinha que fazer aqui com o character
            return
        }
        var potatoNode: SCNNode?
        var lakeNode: SCNNode?
        
        // batata na agua
        if contact.nodeA.physicsBody?.categoryBitMask == CategoryMaskType.potato.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == CategoryMaskType.lake.rawValue
        {
            potatoNode = contact.nodeA
            lakeNode = contact.nodeB
        }
        else if contact.nodeB.physicsBody?.categoryBitMask == CategoryMaskType.potato.rawValue &&
            contact.nodeA.physicsBody?.categoryBitMask == CategoryMaskType.lake.rawValue
        {
            potatoNode = contact.nodeB
            lakeNode = contact.nodeA
        }
        
        if let potatoNode = potatoNode, let lakeNode = lakeNode
        {
            if lakeNode.name == "lakeBottom"
            {
                self.entityManager.killAPotato(node: potatoNode)
            }
            else if lakeNode.name == "lakeSurface"
            {
                // If the potato yet exists it will be found
                if let potatoEntity = self.entityManager.getPotatoEntity(node: potatoNode) {
                    let sinkComponent = self.entityManager.getComponent(entity: potatoEntity, ofType: SinkComponent.self) as! SinkComponent
                    sinkComponent.sinkInWater()
                    potatoEntity.removeComponent(ofType: SeekComponent.self)
                }
            }
        }
    }
}

extension GameController : GameOptions {
    
    func start() {
        self.startGame()
    }
    
    func restart() {
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
                self.pauseOverlay?.gameOptionsDelegate = self
            }
            
            self.scnView.overlaySKScene = self.pauseOverlay
            self.gameStateMachine.enter(PauseState.self)
            
            //pause controls
           self.controlsOverlay?.isPausedControl = true
        }
        
    }
    
}

