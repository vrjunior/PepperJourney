//
//  EscapeComponent.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 04/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

enum CaptiveType {
    case Avocado
    case Tomato
}
// melhorar nome da classe
class PrisonerBox {
    var scene: SCNScene!
    var initialPosition: SCNVector3!
    var finalPoint: SCNNode!
    var isBoxOpen: Bool = false
    var characters = [GKEntity]()
    var visualTarget: SCNNode!
    var box = GKEntity()
    var destinationPoint = GKAgent3D()
    var characterTypeArray: [CaptiveType]
    weak var entityManager: EntityManager?
    // Sound
    weak var soundController: SoundController!
    var talkAudioName: String!

    init (scene: SCNScene, entityManager: EntityManager, initialPoint: SCNNode, finalPoint:SCNNode, characterTypeArray: [CaptiveType], visualTarget: SCNNode, talkTime: TimeInterval, talkAudioName: String, soundController: SoundController)  {
        
        self.scene = scene
        self.entityManager = entityManager
        self.initialPosition = initialPoint.position
        self.finalPoint = finalPoint
        self.visualTarget = visualTarget
        self.soundController = soundController
        self.talkAudioName = talkAudioName
        self.characterTypeArray = characterTypeArray
        
        //  Destination point (GKAgent3D
        self.destinationPoint.position = float3(self.finalPoint.position)
        
        // Add the box where the characters will be arrested
        self.loadBox()
    }
 
    func getCharecterScene(type: CaptiveType) -> String {
        var characterScene: String
        
        switch type {
        case CaptiveType.Avocado:
            characterScene = "Game.scnassets/characters/avocado/avocado.scn"
        case CaptiveType.Tomato:
            characterScene = "Game.scnassets/characters/tomato/tomato.scn"
        }
        return characterScene
    }

    func loadCharacter(typeCharacter: CaptiveType, visualTarget: SCNNode) -> GKEntity
    {
        let entity = GKEntity()
        
        // Add the captive character
        let path = self.getCharecterScene(type: typeCharacter)
        
        let modelComponent = ModelComponent(modelPath: path, scene: scene, position: self.initialPosition)
        
        // Add look at constraint
        self.setLookAtConstraint(visualTarget: visualTarget, node: modelComponent.modelNode)
        
        entity.addComponent(modelComponent)
        
        return entity
    }
    
    func loadBox() {
        let path = "Game.scnassets/scenario/box.scn"
        let modelComponent = ModelComponent(modelPath: path, scene: self.scene, position: self.initialPosition)
        self.box.addComponent(modelComponent)
    }
    
    
    func setLookAtConstraint(visualTarget: SCNNode, node: SCNNode) {
        let lookAtConstraint = SCNLookAtConstraint(target: visualTarget)
        lookAtConstraint.isGimbalLockEnabled = true
        lookAtConstraint.influenceFactor = 1
        
        node.constraints = [lookAtConstraint]
    }
    
    func breakBox()
    {
        // verifica se a caixa já foi aberta
        if self.isBoxOpen { return }
        
        // Remove the box
        let boxModelComponent = self.getModelComponent(entity: self.box)
        // Remove node of scene
        boxModelComponent.removeModel()
        // Remove component from box entity
        self.box.removeComponent(ofType: ModelComponent.self)
        
        // Spawn the characters
        for captiveType in characterTypeArray {
            self.characters.append(loadCharacter(typeCharacter: captiveType, visualTarget: self.visualTarget))
        }
        // Update the flag
        self.isBoxOpen = true
        
        // Run the conversation
        let characterNode = getModelComponent(entity: self.characters[0]).modelNode
        
        self.soundController.playSoundEffect(soundName: self.talkAudioName, loops: false, node: characterNode!, block: self.charactersEcape)
    }
    
    func getModelComponent(entity: GKEntity) -> ModelComponent {
        
        guard let modelComponent = entity.component(ofType: ModelComponent.self) else {
            fatalError("Error getting ModelComponent from \(entity.description) in CaptiveCharacters class")
        }
        return modelComponent
    }
    
    func resetPrisonerBox() {
        // If the box is not open
        if !self.isBoxOpen { return }
        
        // Reset all characters position
        for character in self.characters {
            
            // Remove the character
            let modelComponent = self.getModelComponent(entity: character)
            // Remove node of scene
            modelComponent.removeModel()
            // Remove component from box entity
            character.removeComponent(ofType: ModelComponent.self)
        }
        self.characters.removeAll()
        
        // Add the box
        self.loadBox()
        
        // Reset the flag
        self.isBoxOpen = false
    }
    
    func charactersEcape() {
        for character in characters {
            // Add seek component
            let seekComponent = SeekComponent(target: self.destinationPoint, maxSpeed: 150, maxAcceleration: 50)
            character.addComponent(seekComponent)
            self.entityManager?.loadInComponentSystem(component: seekComponent)
            
            // Remove look at constraint
            let modelComponent = self.getModelComponent(entity: character)
            
            // Add new look at constraint
            self.setLookAtConstraint(visualTarget: self.finalPoint, node: modelComponent.modelNode!)
        }
    }
    
//    //Load all animation of the Potato
//    private func loadAnimations()
//    {
//        let animations:[AnimationType] = [.running]
//        
//        for anim in animations {
//            let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/characters/potato/\(anim.rawValue).dae")
//            
//            animation.stop()
//            self.potatoModel.modelNode.addAnimationPlayer(animation, forKey: anim.rawValue)
//        }
//    }
//    
//    func playAnimation(type: AnimationType) {
//        self.potatoModel.modelNode.animationPlayer(forKey: type.rawValue)?.play()
//    }
//    
//    func stopAnimation(type: AnimationType) {
//        self.potatoModel.modelNode.animationPlayer(forKey: type.rawValue)?.stop()
//    }
// 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
