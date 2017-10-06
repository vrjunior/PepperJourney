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


class GameController: NSObject, SCNSceneRendererDelegate {
    
    var character: Character?
    
    private var scene: SCNScene?
    private weak var sceneRenderer: SCNSceneRenderer?
    private var overlay: Overlay?
    
    // Camera and targets
    private var cameraNode = SCNNode()
    
    
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
        
        // keep a pointer to the physicsWorld from the character because we will need it when updating the character's position
        character!.physicsWorld = scene!.physicsWorld
        scene!.rootNode.addChildNode(character!.node)
    }
    
    func setupCamera() {
        self.cameraNode.camera = SCNCamera()
        self.scene?.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
    }
    
    // MARK: Initializer
    init(scnView: SCNView) {
        super.init()
        
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
        
        // Uncomment to show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        // setup overlay
        overlay = Overlay(size: scnView.bounds.size, controller: self)
        scnView.overlaySKScene = overlay
        
        //load the main scene
        self.scene = SCNScene(named: "art.scnassets/level1.scn")
        
        //load the character
        self.setupCharacter()
        
        self.setupCamera()
        

        //select the point of view to use
        sceneRenderer!.pointOfView = self.cameraNode
        
        //register ourself as the physics contact delegate to receive contact notifications
        //sceneRenderer!.scene!.physicsWorld.contactDelegate = self
    }
    
    
}

extension GameController : PadOverlayDelegate {
    
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay) {
        
    }
    
    
    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay) {
        
    }
    
    
    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay) {
        
    }
    
}

extension GameController : SCNPhysicsContactDelegate {
    
}
