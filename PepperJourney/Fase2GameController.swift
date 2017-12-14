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

class Fase2GameController: GameController {
    
    private var prisonerBoxes = [PrisonerBox]()
    
    override func resetSounds()
    {
        // Restart the background music
        self.soundController.playbackgroundMusic(soundName: "backgroundMusic", loops: true, node: self.cameraNode)
        
    }
    
    override func stopSounds()
    {
        // Clean all the sounds
        soundController.stopSoundsFromNode(node: self.cameraNode)
        soundController.stopSoundsFromNode(node: self.character.characterNode)
    }
    override func setupSounds() {
        
        self.soundController.loadSound(fileName: "gameBackground.mp3", soundName: "backgroundMusic", volume: 0.5)
        
        
        self.soundController.loadSound(fileName: "GameOver-Game_over.wav", soundName: "gameOverSound", volume: 1)
        
        // Finish Level sound
        self.soundController.loadSound(fileName: "FinishLevel-jingle-win-00.wav", soundName: "FinishLevelSound", volume: 1)
        // Potato Yell
        self.soundController.loadSound(fileName: "Yell - small-fairy-hit-moan.wav", soundName: "PotatoYell")
        
        //setup character sounds
        self.soundController.loadSound(fileName: "jump.wav", soundName: "jump", volume: 30.0)
        
        // Prisioner sounds
        self.soundController.loadSound(fileName: "F1_3.wav", soundName: "PrisonerSound", volume: 30.0)
        
        // Add the sound points
       // self.addPepperSoundPoints()
        
    }
    
    override func setupGame() {
        gameStateMachine = GKStateMachine(states: [
            PauseState(scene: scene),
            PlayState(scene: scene) ])
        
        self.gameStateMachine.enter(PauseState.self)
    }
    
    
    // MARK: Initializer
    override init(scnView: SCNView) {
        super.init(scnView: scnView)
        
        //load the main scene
        guard let scene = SCNScene(named: "Game.scnassets/fases/fase2.scn") else {
            fatalError("Error loading fase2.scn")
        }
        self.scene = scene
        //setup game state machine
        self.setupGame()
        
        self.scene.physicsWorld.contactDelegate = self
        
        scnView.scene = scene
        
        //self.scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
        //self.scnView.showsStatistics = true
        
        // Create the entity manager system
        self.entityManager = EntityManager(scene: self.scene, gameController: self, soundController: self.soundController)
        
        //load the character
        self.setupCharacter()
        
        self.setupCamera()
        
        //setup tap to start
        self.setupTapToStart()
        
        // Pre-load all the audios of the game in the memory
        self.setupSounds()
        
        // Add all the prisoner boxes
        self.addPrisonerBoxes()
        
        
    }
    
    override func initializeTheGame () {
        //        guard let node = character.component(ofType: ModelComponent.self)?.modelNode else
        //        {
        //            fatalError("Character node not found")
        //        }
        
        // Show de character
        self.character.characterNode.isHidden = false
        
        self.entityManager.setupGameInitialization()
        
        // Reset of all the sounds
        self.resetSounds()
        
        // Reset all the prisoner boxes for the new play
        for prisonerBox in self.prisonerBoxes {
            prisonerBox.resetPrisonerBox()
        }
        
        self.character.setupCharacter()
        
        self.cameraNode.position = self.cameraInitialPosition
        
    }
    
    override func setupTapToStart() {
        
        // Do the setup to restart the game
        self.prepereToStartGame()
        
        let tapOverlay = SKScene(fileNamed: "StartOverlay.sks") as! StartOverlay
        tapOverlay.gameOptionsDelegate = self
        tapOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = tapOverlay
        
    }
    override func prepereToStartGame()
    {
        self.stopSounds()
        
        entityManager.killAllPotatoes()
        
        self.character.characterNode.isHidden = true
    }
    
    override func setupGameOver() {
        
        // Do the setup to restart the game
        self.prepereToStartGame()
        
        self.soundController.playSoundEffect(soundName: "gameOverSound", loops: false, node: self.cameraNode)
        
        let gameOverOverlay = SKScene(fileNamed: "GameOverOverlay.sks") as! GameOverOverlay
        gameOverOverlay.gameOptionsDelegate = self
        gameOverOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = gameOverOverlay
        
        //self.gameStateMachine.enter(PauseState.self)
        
    }
    
    override func setupFinishLevel() {
        self.prepereToStartGame()
        self.soundController.playSoundEffect(soundName: "FinishLevelSound", loops: false, node: self.cameraNode)
        
        let finishLevelOverlay = SKScene(fileNamed: "FinishOverlay.sks") as! FinishOverlay
        finishLevelOverlay.gameOptionsDelegate = self
        finishLevelOverlay.scaleMode = .aspectFill
        self.scnView.overlaySKScene = finishLevelOverlay
        
        self.gameStateMachine.enter(PauseState.self)
        
        self.cutSceneDelegate?.playCutScene(videoPath: "cutscene1.mp4")
    }
    
    override func startGame() {
        super.startGame()
        // Inittialize the game with the defaults settings.
    }
    
    // MARK: - Update
    var lastPowerLeverPorcento: Float = 0
    override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        super.renderer(renderer, updateAtTime: time)
        
        // MELHORAR ISSO, PQ ESTÁ HORRÍVEL
        let powerLevelComponent = character.component(ofType: PowerLevelCompoenent.self)!
        let porcento:Float = powerLevelComponent.currentPowerLevel / powerLevelComponent.MaxPower
        if porcento != lastPowerLeverPorcento {
            lastPowerLeverPorcento = porcento
            
            self.overlayDelegate?.updateAttackIndicator(percentage: lastPowerLeverPorcento)
        }
    }
    
    override func handleWithPhysicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var characterNode: SCNNode?
        var anotherNode: SCNNode?
        var potatoNode: SCNNode?
        
        
        if contact.nodeA == self.character.characterNode {
            
            characterNode = contact.nodeA
            
            anotherNode = contact.nodeB
        }
            
        else if contact.nodeB == self.character.characterNode
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
                    if let lifeComponent = self.character.component(ofType: LifeComponent.self) {
                        if lifeComponent.canReceiveDamage {
                            lifeComponent.receiveDamage(enemyCategory: .potato, waitTime: 0.2)
                            let currentLife = lifeComponent.getLifePercentage()
                            
                            if currentLife <= 0 {
                                self.setupGameOver()
                                return
                            }
                            self.overlayDelegate?.updateLifeIndicator(percentage: currentLife)
                        }
                    }
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
        
        // Found potato
        if contact.nodeA.physicsBody?.categoryBitMask == CategoryMaskType.potato.rawValue
        {
            potatoNode = contact.nodeA
            anotherNode = contact.nodeB
        }
        else if contact.nodeB.physicsBody?.categoryBitMask == CategoryMaskType.potato.rawValue
        {
            potatoNode = contact.nodeB
            anotherNode = contact.nodeA
        }
        
        if let potatoNode = potatoNode, anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.lake.rawValue
        {
            let lakeNode = anotherNode!
            
            if lakeNode.name == "lakeBottom" {
                self.entityManager.killAnEnemy(node: potatoNode)
            }
            else if lakeNode.name == "lakeSurface" {
                // If the potato yet exists it will be found
                if let potatoEntity = self.entityManager.getEnemyEntity(node: potatoNode) {
                    let sinkComponent = self.entityManager.getComponent(entity: potatoEntity, ofType: SinkComponent.self) as! SinkComponent
                    sinkComponent.sinkInWater()
                    potatoEntity.removeComponent(ofType: SeekComponent.self)
                }
            }
            return
        }
        else if let potatoNode = potatoNode, anotherNode?.physicsBody?.categoryBitMask == CategoryMaskType.fireBall.rawValue {
            
            if self.entityManager.killAnEnemy(node: potatoNode) {
                self.soundController.playSoundEffect(soundName: "PotatoYell", loops: false, node: self.cameraNode)
            }
            return
            
        }
        var boxNode: SCNNode?
        if contact.nodeA.physicsBody?.categoryBitMask == CategoryMaskType.box.rawValue {
            boxNode = contact.nodeA
        }
        else if contact.nodeB.physicsBody?.categoryBitMask == CategoryMaskType.box.rawValue {
            boxNode = contact.nodeB
        }
        if let boxNode = boxNode {
            for prisonerBox in self.prisonerBoxes {
                if let modelNode = prisonerBox.box.component(ofType: ModelComponent.self)?.modelNode {
                    if modelNode == boxNode {
                        prisonerBox.breakBox()
                    }
                }
            }
        }
    }
    
    func addPrisonerBoxes() {
        guard let prisonerBoxesNode = self.scene.rootNode.childNode(withName: "prisonerBoxes", recursively: false) else {
            fatalError("Error getting prisonerBoxes node")
        }
        let prisonerBoxesNodePosition = prisonerBoxesNode.presentation.position
        
        let boxNodes = prisonerBoxesNode.childNodes
        
        for boxNode in boxNodes {
            
            // box position relative at the scene world
            let initialPoint = SCNNode()
            initialPoint.position.x =  prisonerBoxesNodePosition.x + boxNode.presentation.position.x
            initialPoint.position.y =  prisonerBoxesNodePosition.y + boxNode.presentation.position.y
            initialPoint.position.z =  prisonerBoxesNodePosition.z + boxNode.presentation.position.z
            
            // Character final position
            guard let destinationPoint = boxNode.childNode(withName: "destinationPoint", recursively: false) else {
                fatalError("Error getting destinationPoint node to PrisonerBox")
            }
            // Final position relative at the scene world
            let finalPoint = SCNNode()
            finalPoint.position.x = initialPoint.position.x + destinationPoint.position.x
            finalPoint.position.y = initialPoint.position.y + destinationPoint.position.y
            finalPoint.position.z = initialPoint.position.z + destinationPoint.position.z
            
            let characters: [PrisonerType] = [.Avocado, .Tomato, .Tomato]
            
            var boxName = ""
            if boxNode.name != nil {
                boxName = boxNode.name!
            }
            // create a box with prisoners
            let box = PrisonerBox(boxName: boxName, scene: self.scene,
                                   entityManager: self.entityManager,
                                   initialPoint: initialPoint,
                                   finalPoint: finalPoint,
                                   characterTypeArray: characters,
                                   visualTarget: self.character.characterNode,
                                   talkTime: 0,
                                   talkAudioName: "PrisonerSound",
                                   soundController: self.soundController)
            self.prisonerBoxes.append(box)
        }
    }
}
