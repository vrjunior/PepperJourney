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
    case RegularAvocado
    case WarriorAvocado
    case Tomato
}

struct Prisoner {
    let entity = GKEntity()
    var type: PrisonerType
    var talkAudioName: String?
}

// melhorar nome da classe
class PrisonerBox: DistanceAlarmDelegate {
    var scene: SCNScene!
    var initialPosition: SCNVector3!
    var finalPoint: SCNNode!
    var isBoxOpen: Bool = false
    var pepperNode: SCNNode!
    var box = GKEntity()
    var destinationPoint = GKAgent3D()
    var prisoners = [Prisoner]()
    var entityManager = EntityManager.sharedInstance
    var isBigBox = false
    
    // Sound
    private var soundController = SoundController.sharedInstance
    var prisonerDelegate: PrisonerDelegate!
    
    init (scene: SCNScene, initialPoint: SCNNode, finalPoint:SCNNode,
          pepperNode: SCNNode, prisonerDelegate: PrisonerDelegate, isBigBox: Bool)  {
        
        self.scene = scene
        self.initialPosition = initialPoint.position
        self.finalPoint = finalPoint
        self.pepperNode = pepperNode
        self.prisonerDelegate = prisonerDelegate
        self.isBigBox = isBigBox
        
        //  Destination point (GKAgent3D
        self.destinationPoint.position = float3(self.finalPoint.position)
        
        // Add the box where the characters will be arrested
        self.loadBox()
        
        // Add the components responsable by cleaning the entity
        self.addEntityCleaners()
        
    }
    
    func fireDistanceAlarm(modelComponent: ModelComponent) {
        if let entity = modelComponent.entity,
            let entityCleanerComponent = entity.component(ofType: EntityCleanerComponent.self) {
            
            entityCleanerComponent.prepareToCleanEntity()
        }
    }
    
    func addEntityCleaners() {
        for prisoner in self.prisoners {
            
            let entityCleanerComponent = EntityCleanerComponent(entityManager: EntityManager.sharedInstance)
            prisoner.entity.addComponent(entityCleanerComponent)
            self.entityManager.loadEntityCleanerComponent(component: entityCleanerComponent)
        }
    }
    
    func getPrisonerScene(type: PrisonerType) -> String {
        var characterScene: String
        
        switch type {
        case PrisonerType.WarriorAvocado:
            characterScene = "Game.scnassets/characters/avocado/WarriorAvocado.scn"
            
        case PrisonerType.RegularAvocado:
            characterScene = "Game.scnassets/characters/avocado/avocado.scn"
            
        case PrisonerType.Tomato:
            characterScene = "Game.scnassets/characters/tomato/tomato.scn"
        }
        return characterScene
    }
    
    func loadPrisoner(prisoner: Prisoner)
    {
        // Add the prisoner to the scene
        let path = self.getPrisonerScene(type: prisoner.type)
        
        // Create a model component
        let modelComponent = ModelComponent(modelPath: path, scene: self.scene, position: self.initialPosition)
        
        // get the node
        guard let modelNode = modelComponent.modelNode else {
            return
        }
        
        if prisoner.type == .WarriorAvocado {
            modelNode.geometry?.firstMaterial = modelNode.geometry?.materials[1]
        }
        
        prisoner.entity.addComponent(modelComponent)
        
        // Add look at constraint
        self.setLookAtConstraint(visualTarget: self.pepperNode, nodeToApply: modelNode)
        
        // Load animations
        self.loadAnimations(prisonerModelComponent: modelComponent)
        
    }
    
    func setLookAtConstraint(visualTarget: SCNNode, nodeToApply: SCNNode) {
        
        let lookAtConstraint = SCNLookAtConstraint(target: visualTarget)
        lookAtConstraint.isGimbalLockEnabled = true
        lookAtConstraint.influenceFactor = 1
        
        nodeToApply.constraints = [lookAtConstraint]
    }
    
    func loadBox() {
        
        var path: String
        if self.isBigBox {
            path = "Game.scnassets/scenario/box/bigBox.scn"
        }
            // regular box
        else {
            path = "Game.scnassets/scenario/box/box.scn"
        }
        
        let modelComponent = ModelComponent(modelPath: path, scene: self.scene, position: self.initialPosition)
        
        self.box.addComponent(modelComponent)
    }
    func breakBox(prisoners: [Prisoner])
    {
        self.prisoners = prisoners
        
        // verifica se a caixa já foi aberta
        if self.isBoxOpen { return }
        
        // Remove the box
        let boxModelComponent = self.getModelComponent(entity: self.box)
        // Remove node of scene
        boxModelComponent.removeModel()
        // Remove component from box entity
        self.box.removeComponent(ofType: ModelComponent.self)
        
        // Spawn the characters looking to the Pepper in the beggining
        for prisoner in self.prisoners {
            self.loadPrisoner(prisoner: prisoner)
        }
        // Update the flag
        self.isBoxOpen = true
        
        // Run the conversation
        
        
        // Run audio conversation and after run charactersEcape function
        let prisoner = self.prisoners[0]
        if let soundName = prisoner.talkAudioName,
            let prisonerNode = self.getModelComponent(entity: prisoner.entity).modelNode {
            
            self.soundController.playSoundEffect(soundName: soundName, loops: false, node: prisonerNode, block: self.charactersEcape)
            SubtitleController.sharedInstance.setupSubtitle(subName: soundName)
            
        }
        print(self.pepperNode.presentation.position)
        
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
        for prisoner in self.prisoners {
            
            // Remove the character
            let modelComponent = prisoner.entity.component(ofType: ModelComponent.self)
            if modelComponent != nil {
                // Remove node of scene
                modelComponent!.removeModel()
                // Remove component from box entity
                prisoner.entity.removeComponent(ofType: ModelComponent.self)
            }
            // Remove de seek component
            if let pursueComponent = prisoner.entity.component(ofType: PursueComponent.self) {
                self.entityManager.removeOfComponentSystem(component: pursueComponent)
                prisoner.entity.removeComponent(ofType: PursueComponent.self)
            }
            // Remove distanceAlarmComponent
            let distanceAlarmComponent = prisoner.entity.component(ofType: DistanceAlarmComponent.self)
            if distanceAlarmComponent != nil {
                self.entityManager.removeDistanceAlarm(entity: prisoner.entity)
                prisoner.entity.removeComponent(ofType: DistanceAlarmComponent.self)
            }
        }
        
        // Add the box
        self.loadBox()
        
        // Reset the flag
        self.isBoxOpen = false
    }
    
    func charactersEcape() {
        
        if !self.isBigBox {
            
            for prisoner in self.prisoners {
                
                // Add seek component
                let pursueComponent = PursueComponent(target: self.destinationPoint, maxSpeed: 50, maxAcceleration: 5)
                prisoner.entity.addComponent(pursueComponent)
                self.entityManager.loadToComponentSystem(component: pursueComponent)
                
                // Setup the new look at constraint
                let modelComponent = self.getModelComponent(entity: prisoner.entity)
                self.setLookAtConstraint(visualTarget: self.finalPoint, nodeToApply: modelComponent.modelNode)
                
                // TODO: Arrumar essa animação!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                // Play animation
                //                self.playAnimation(type: .running, prisonerEntity: prisoner.entity)
                
                // Set distance alarm
                let distanceAlarm = DistanceAlarmComponent(targetPosition: self.finalPoint.position, alarmTriggerRadius: 5, distanceAlarmDelegate: self)
                prisoner.entity.addComponent(distanceAlarm)
                self.entityManager.loadDistanceAlarmComponent(component: distanceAlarm)
            }
        }
        // update the status
        self.prisonerDelegate.prisionerReleased()
        
    }
    
    //Load all animation of the Character
    private func loadAnimations(prisonerModelComponent: ModelComponent)
    {
        guard let modelNode = prisonerModelComponent.modelNode else { return }
        
        let animations:[AnimationType] = [.running]
        
        for anim in animations {
            let animation = SCNAnimationPlayer.withScene(named: "Game.scnassets/characters/tomato/\(anim.rawValue).dae")
            
            animation.stop()
            
            modelNode.addAnimationPlayer(animation, forKey: anim.rawValue)
        }
    }
    
    func playAnimation(type: AnimationType, prisonerEntity: GKEntity) {
        guard let modelNode = prisonerEntity.component(ofType: ModelComponent.self)?.modelNode else { return }
        modelNode.animationPlayer(forKey: type.rawValue)?.play()
    }
    
    func stopAnimation(type: AnimationType, prisonerEntity: GKEntity) {
        guard let modelNode = prisonerEntity.component(ofType: ModelComponent.self)?.modelNode else { return }
        modelNode.animationPlayer(forKey: type.rawValue)?.stop()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

