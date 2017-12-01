//
//  EntityManager.swift
//  SpicyHero
//
//  Created by Marcelo Martimiano Junior on 20/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import GameplayKit
import SceneKit
import Foundation

class EntityManager
{
    private var scene: SCNScene!
    private weak var soundController: SoundController!
    private var chasedTargetAgent: GKAgent3D!


    // colocar aqui os components system
    var seekComponentSystem = GKComponentSystem(componentClass: SeekComponent.self)
	var soundRandomComponentSystem = GKComponentSystem(componentClass: SoundRandomComponent.self)
	var soundDistanceComponentSystem = GKComponentSystem(componentClass: SoundDistanceComponent.self)
    var sinkComponentSystem = GKComponentSystem(componentClass: SinkComponent.self)

    // Game entities
    private(set) var character: Character!
    private(set) var potatoesEntities = [GKEntity]()
    private(set) var potatoGeneratorSystem: PotatoGeneratorSystem!

    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0

    init (scene: SCNScene, gameController: GameController, soundController: SoundController)
    {
        self.scene = scene
        self.soundController = soundController

        // Create the character entity
        self.character = Character(scene: self.scene, jumpDelegate: gameController, soundController: self.soundController)

        // Add the sinkComponent to a component system
        guard let sinkCompnent = self.character.component(ofType: SinkComponent.self) else
        {
            fatalError("Error getting Character sinkComponent")
        }
        self.sinkComponentSystem.addComponent(sinkCompnent)

        self.chasedTargetAgent = character.component(ofType: GKAgent3D.self)
        guard self.chasedTargetAgent != nil else { return }

        // Create a Entity that coordinate the potato creation
        self.potatoGeneratorSystem = PotatoGeneratorSystem(scene: self.scene, characterNode: self.character.characterNode)

    }

    // Use this function ever in game initialization or restart
    func setupGameInitialization()
    {
        // Create new potatoes
        let potatoSpawnPoint = SCNVector3(2,50, 285)
        var i = 10
        while i > 0 {
            self.createChasingPotato(position: potatoSpawnPoint)
            i -= 1
        }

        // Configuration of the potato generator system
        self.potatoGeneratorSystem.setupPotatoGeneratorSystem()

        // SystemCompent of SinkComponent
        for sinkComponent in self.sinkComponentSystem.components {
            let sinkComponent = sinkComponent as! SinkComponent
            sinkComponent.resetComponent()
        }

        // Reset componentSounds
		addPepperSoundPoints()
    }

    // Creates a potato chasing Pepper
    func createChasingPotato(position: SCNVector3)
    {
        // create a new potato entity
        let potato = PotatoEntity(model: PotatoType.model1 , scene: self.scene, position: position, trakingAgent: self.chasedTargetAgent)

        // Create a seek component
        let seekComponent = potato.component(ofType: SeekComponent.self)!
        self.seekComponentSystem.addComponent(seekComponent)

		let soundRandomComponent = potato.component(ofType: SoundRandomComponent.self)!
		self.soundRandomComponentSystem.addComponent(soundRandomComponent)

        // Add the component that enable the potato sink in water
        guard let potatoNode = potato.component(ofType: ModelComponent.self)?.modelNode else {fatalError("Error getting the node")}

        let sinkComponent = SinkComponent(soundController: self.soundController, node: potatoNode, entity: potato)
        potato.addComponent(sinkComponent)

        // add the sinkComponent to ComponentSystem
        self.sinkComponentSystem.addComponent(sinkComponent)

        // Add the potato entity to array of potatoes
        self.potatoesEntities.append(potato)
    }

    func update(atTime time: TimeInterval)
    {
        if previousUpdateTime == 0.0 {
            previousUpdateTime = time
        }

        let deltaTime = time - previousUpdateTime

		//Seek Component
        if seekComponentSystem.components.count > 0
        {
            self.seekComponentSystem.update(deltaTime: deltaTime)
        }

		//Sound Random Comoponent
		if soundRandomComponentSystem.components.count > 0
		{
			self.soundRandomComponentSystem.update(deltaTime: deltaTime)
		}

		//Sound Distance Comoponent
		if soundDistanceComponentSystem.components.count > 0
		{
			self.soundDistanceComponentSystem.update(deltaTime: deltaTime)
		}


        // Verify the potato generator points
        self.potatoGeneratorSystem.update(deltaTime: deltaTime)

        // Create points that are needed.
        let readyPotatoes = self.potatoGeneratorSystem.getReadyPotatoes()
        for potatoPosition in readyPotatoes
        {
            self.createChasingPotato(position: potatoPosition)
        }

        self.previousUpdateTime = time

        /* Character update */
        guard let attackComponent = self.character.component(ofType: AttackComponent.self)else{fatalError()}
        attackComponent.update(deltaTime: deltaTime)

    }

    func getComponent(entity: GKEntity, ofType: GKComponent.Type) -> GKComponent
    {
        guard let component = entity.component(ofType: ofType) else
        {
            fatalError("Error getting component \(ofType)")
        }
        return component
    }

    func killAllPotatoes ()
    {
        for potato in self.potatoesEntities
        {
            let potato = potato as! PotatoEntity

            // remove da memoria o som carregado de queda na agua
            self.soundController.removeSoundFromMemory(soundName: potato.description)
            potato.removeModelNodeFromScene()
        }

        self.potatoesEntities.removeAll()
    }

    func getPotatoEntity(node: SCNNode) -> PotatoEntity?
    {
        for index in 0 ..< self.potatoesEntities.count
        {
            let potato = self.potatoesEntities[index] as! PotatoEntity
            guard let potatoNode = potato.component(ofType: ModelComponent.self)?.modelNode else
            {
                fatalError("Error getting modelComponent from \(potato.description)")
            }

            if node == potatoNode
            {

                let potato = self.potatoesEntities[index] as! PotatoEntity
                return potato
            }

        }
        return nil
    }

    func killAPotato(node: SCNNode) -> Bool
    {
        var potatoToBeRemoved: Int?
        for index in 0 ..< self.potatoesEntities.count
        {
            let potato = self.potatoesEntities[index] as! PotatoEntity
            guard let potatoNode = potato.component(ofType: ModelComponent.self)?.modelNode else
            {
                fatalError("Error getting modelComponent from potato")
            }

            if node == potatoNode
            {
                potatoToBeRemoved = index
                break
            }
        }

        if let index = potatoToBeRemoved {
            let potato = self.potatoesEntities[index] as! PotatoEntity

            
            //remove component before
            potato.component(ofType: SinkComponent.self)?.remove()
            
            potato.removeModelNodeFromScene()
            potatoesEntities.remove(at: index)
            return true
        }

        return false
    }

	//Add sounds here
	public func addPepperSoundPoints()
	{
        let soundPoints = self.scene.rootNode.childNode(withName: "FaseAudioPositions", recursively: false)?.childNodes
		var distanceComponentArray = [SoundDistanceComponent]()
        
        for soundPoint in soundPoints!
        {
            let x = Double(soundPoint.presentation.position.x)
            let z = Double(soundPoint.presentation.position.z)
            
            let point = CGPoint(x: x, y: z)
            
            switch soundPoint.name! {
            case "F1_1":
                // F1 - 1
                distanceComponentArray.append(SoundDistanceComponent(fileName: "F1_1.wav", actionPoint: point, minRadius: 165, entity: self.character!, node: (character?.characterNode)!, soundController: soundController))
            case "F1_2":
                // F1 - 2
                distanceComponentArray.append(SoundDistanceComponent(fileName: "F1_2.wav", actionPoint: point, minRadius: 20, entity: self.character!, node: (character?.characterNode)!, soundController: soundController))
            case "F1_3":
                // F1 - 3
                distanceComponentArray.append(SoundDistanceComponent(fileName: "F1_3.wav", actionPoint: point, minRadius: 20, entity: self.character!, node: (character?.characterNode)!, soundController: soundController))
            case "F1_4":
                // F1 - 4
                distanceComponentArray.append(SoundDistanceComponent(fileName: "F1_4.wav", actionPoint: point, minRadius: 40, entity: self.character!, node: (character?.characterNode)!, soundController: soundController))
            case "F1_5":
                // F1 - 5
                distanceComponentArray.append(SoundDistanceComponent(fileName: "F1_5.wav", actionPoint: point, minRadius: 20, entity: self.character!, node: (character?.characterNode)!, soundController: soundController))
            case "F1_6":
                // F1 - 6
                distanceComponentArray.append(SoundDistanceComponent(fileName: "F1_6.wav", actionPoint: point, minRadius: 50, entity: self.character!, node: (character?.characterNode)!, soundController: soundController))
            case "F1_7":
                // F1 - 6
                distanceComponentArray.append(SoundDistanceComponent(fileName: "F1_7.wav", actionPoint: point, minRadius: 50, entity: self.character!, node: (character?.characterNode)!, soundController: soundController))
            default:
                print("not found")
            }
        }
		for component in distanceComponentArray {
			self.character?.addComponent(component)
			soundDistanceComponentSystem.addComponent(component)
		}
	}
}
