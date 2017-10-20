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


class GameController: NSObject, SCNSceneRendererDelegate {
    
    var character: Character!
    var characterStateMachine: GKStateMachine!
    
    private var scene: SCNScene!
    private weak var sceneRenderer: SCNSceneRenderer?
    private var overlay: Overlay?
    
    // Camera and targets
    private var cameraNode = SCNNode()
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
        character = Character(scene: scene!)
        characterStateMachine = GKStateMachine(states: [
            StadingState(scene: scene, character: character),
            RunningState(scene: scene, character: character),
            JumpingState(scene: scene, character: character)
            ])
        
        characterStateMachine.enter(StadingState.self)
    }
    
    func setupCamera() {
        self.cameraNode.camera = SCNCamera()
        self.scene?.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
    }
    
    // MARK: Initializer
    init(scnView: SCNView) {
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
        
        scnView.scene = scene

        //select the point of view to use
        sceneRenderer!.pointOfView = self.cameraNode
        
        var potato1  = PotatoEntity(model: .model1, scene: scene, position: SCNVector3(10,4,0))
        var potato2  = PotatoEntity(model: .model2, scene: scene, position: SCNVector3(3,4,0))
        var potato3  = PotatoEntity(model: .model2, scene: scene, position: SCNVector3(4,5,0))
        
    }
    
    
    // MARK: - Update
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // update characters
        character!.update(atTime: time, with: renderer)
    }
    
    
}

extension GameController : PadOverlayDelegate {
    
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay) {
        characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
    }
    
    
    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay) {
        characterDirection = float2(Float(padNode.stickPosition.x), -Float(padNode.stickPosition.y))
        
        if(character.isWalking) {
            //TODO: enter on walking state
            print("walking")
        }
        else {
            print("running")
        }
        
        self.characterStateMachine.enter(RunningState.self)
        
    }
    
    
    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay) {
        characterDirection = [0, 0]
        
        self.characterStateMachine.enter(StadingState.self)
    }
    
}

extension GameController : CharacterMovesDelegate {
    func jump() {
        self.characterStateMachine.enter(JumpingState.self)
    }
    
    func attack() {
        
    }
}

extension GameController : SCNPhysicsContactDelegate {
    
}
