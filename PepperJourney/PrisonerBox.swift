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

enum PrisonerType {
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
    var characterTypeArray: [PrisonerType]
    weak var entityManager: EntityManager?
    // Sound
    weak var soundController: SoundController!
    var talkAudioName: String!
    var boxName: String

    init (boxName: String, scene: SCNScene, entityManager: EntityManager, initialPoint: SCNNode, finalPoint:SCNNode, characterTypeArray: [PrisonerType], visualTarget: SCNNode, talkTime: TimeInterval, talkAudioName: String, soundController: SoundController)  {
        
        self.scene = scene
        self.entityManager = entityManager
        self.initialPosition = initialPoint.position
        self.boxName = boxName
        self.finalPoint = finalPoint
        self.visualTarget = visualTarget
        self.soundController = soundController
        self.talkAudioName = talkAudioName
        self.characterTypeArray = characterTypeArray
        
        // Create all the entities to this box
        for _ in self.characterTypeArray {
            self.characters.append(GKEntity())
        }
        
        //  Destination point (GKAgent3D
        self.destinationPoint.position = float3(self.finalPoint.position)
        
        // Add the box where the characters will be arrested
        self.loadBox()
        
        // Add the components responsable by cleaning the entity
        self.addEntityCleaners()
        
    }
    func addEntityCleaners() {
        for character in characters {
            guard let entityManager = self.entityManager else { fatalError() }
            let entityCleanerComponent = EntityCleanerComponent(entityManager: entityManager)
            character.addComponent(entityCleanerComponent)
            self.entityManager?.loadEntityCleanerComponent(component: entityCleanerComponent)
        }
    }
 
    func getCharecterScene(type: PrisonerType) -> String {
        var characterScene: String
        
        switch type {
        case PrisonerType.Avocado:
            characterScene = "Game.scnassets/characters/avocado/avocado.scn"
        case PrisonerType.Tomato:
            characterScene = "Game.scnassets/characters/tomato/tomato.scn"
        }
        return characterScene
    }

    func loadCharacter(characterIndex: Int, typeCharacter: PrisonerType, visualTarget: SCNNode)
    {
        // Add the captive character
        let path = self.getCharecterScene(type: typeCharacter)
        
        // Create a model component
        let modelComponent = ModelComponent(modelPath: path, scene: scene, position: self.initialPosition)
        
        // get the node
        guard let modelNode = modelComponent.modelNode else {
            return
        }
        modelNode.name = self.boxName + "CharacterModelNode"
        self.characters[characterIndex].addComponent(modelComponent)
        
        // Add look at constraint
        self.setLookAtConstraint(visualTarget: visualTarget, nodeToApply: modelNode)
        
        // Load animations
        self.loadAnimations(characterIndex: characterIndex)
        
    }
 
    func setLookAtConstraint(visualTarget: SCNNode, nodeToApply: SCNNode) {

        let lookAtConstraint = SCNLookAtConstraint(target: visualTarget)
        lookAtConstraint.isGimbalLockEnabled = true
        lookAtConstraint.influenceFactor = 1
        
        nodeToApply.constraints = [lookAtConstraint]
    }
    
    func loadBox() {
        let path = "Game.scnassets/scenario/box/box.scn"
        let modelComponent = ModelComponent(modelPath: path, scene: self.scene, position: self.initialPosition)
        modelComponent.modelNode.name = self.boxName + "ModelNode"
        
        self.box.addComponent(modelComponent)
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
        
        // Spawn the characters looking to the Pepper in the beggining
        for index in 0 ..< self.characters.count {
            loadCharacter(characterIndex: index, typeCharacter: self.characterTypeArray[index], visualTarget: self.visualTarget)
        }
        // Update the flag
        self.isBoxOpen = true
        
        // Run the conversation
        let characterNode = getModelComponent(entity: self.characters[0]).modelNode
        
        // Run audio conversation and after run charactersEcape function
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
        
        // Reset all components
        for character in self.characters {
            
            // Remove the character
            let modelComponent = character.component(ofType: ModelComponent.self)
            if modelComponent != nil {
                // Remove node of scene
                modelComponent!.removeModel()
                // Remove component from box entity
                character.removeComponent(ofType: ModelComponent.self)
            }
            // Remove de seek component
            let seekComponet = character.component(ofType: SeekComponent.self)
            if seekComponet != nil {
                self.entityManager?.removeSeekComponent(entity: character)
                character.removeComponent(ofType: SeekComponent.self)
            }
            // Remove distanceAlarmComponent
            let distanceAlarmComponent = character.component(ofType: DistanceAlarmComponent.self)
            if distanceAlarmComponent != nil {
                self.entityManager?.removeDistanceAlarm(entity: character)
                character.removeComponent(ofType: DistanceAlarmComponent.self)
            }
        }
        
        // Add the box
        self.loadBox()
        
        // Reset the flag
        self.isBoxOpen = false
    }
    
    func charactersEcape() {
        var characterIndex: Int = 0
        for character in characters {
            
            // Add seek component
            let seekComponent = SeekComponent(target: self.destinationPoint, maxSpeed: 50, maxAcceleration: 5)
            character.addComponent(seekComponent)
            self.entityManager?.loadSeekComponent(component: seekComponent)

            // Setup the new look at constraint
            let modelComponent = self.getModelComponent(entity: character)
            self.setLookAtConstraint(visualTarget: self.finalPoint, nodeToApply: modelComponent.modelNode)
            
            // Play animation
            self.playAnimation(type: .running, characterIndex: characterIndex)
            
            guard self.entityManager != nil else {fatalError()}
            let distanceAlarm = DistanceAlarmComponent(targetPosition: self.finalPoint.position, alarmTriggerRadius: 5, entityManager: self.entityManager!)
            character.addComponent(distanceAlarm)
            self.entityManager?.loadDistanceAlarmComponent(component: distanceAlarm)
            characterIndex += 1
        }
    }
    
    //Load all animation of the Character
    private func loadAnimations(characterIndex: Int)
    {
        let animations:[AnimationType] = [.running]
        
        for anim in animations {
            let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/characters/tomato/\(anim.rawValue).dae")
            
            animation.stop()
            guard let modelNode = getModelComponent(entity: self.characters[characterIndex]).modelNode else { return }
            modelNode.addAnimationPlayer(animation, forKey: anim.rawValue)
        }
    }
    
    func playAnimation(type: AnimationType, characterIndex: Int) {
        guard let modelNode = getModelComponent(entity: self.characters[characterIndex]).modelNode else { return }
        modelNode.animationPlayer(forKey: type.rawValue)?.play()
    }
    
    func stopAnimation(type: AnimationType, characterIndex: Int) {
         guard let modelNode = getModelComponent(entity: self.characters[characterIndex]).modelNode else { return }
        modelNode.animationPlayer(forKey: type.rawValue)?.stop()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
