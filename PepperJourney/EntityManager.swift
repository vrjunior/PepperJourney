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


enum EnemyTypes : String {
    case potato = "potato"
    case potatoSpear = "potatoSpear"
}

class EntityManager {
    public static var sharedInstance = EntityManager()
    private var scene: SCNScene!
    private weak var soundController: SoundController!
    private var chasedTargetAgent: GKAgent3D!


    // colocar aqui os components system
    public var seekComponentSystem = GKComponentSystem(componentClass: SeekComponent.self)
	var soundRandomComponentSystem = GKComponentSystem(componentClass: SoundRandomComponent.self)
	var soundDistanceComponentSystem = GKComponentSystem(componentClass: SoundDistanceComponent.self)
    var sinkComponentSystem = GKComponentSystem(componentClass: SinkComponent.self)
    var distanceAlarmComponentSystem = GKComponentSystem(componentClass: DistanceAlarmComponent.self)
    var entityCleanerComponentSystem = GKComponentSystem(componentClass: EntityCleanerComponent.self)

    var componentSystems = [GKComponentSystem]()
    // Game entities
    private(set) var character: Character!
    private(set) var enemyEntities = [EnemyEntity]()
    private(set) var potatoGeneratorSystem: EnemyGeneratorSystem!

    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    // Private init of the Singleton
    private init() {
        
    }

    func initEntityManager (scene: SCNScene, gameController: GameController, soundController: SoundController)
    {
        self.scene = scene
        self.soundController = soundController
        
        // Add the componentSystems
        let componentSystem = GKComponentSystem(componentClass: AttackLimiterComponent.self)
        self.componentSystems.append(componentSystem)

        // Create the character entity
        self.character = Character(scene: self.scene, jumpDelegate: gameController, entityManager: self , soundController: self.soundController)

        // Add the sinkComponent to a component system
        guard let sinkCompnent = self.character.component(ofType: SinkComponent.self) else
        {
            fatalError("Error getting Character sinkComponent")
        }
        self.sinkComponentSystem.addComponent(sinkCompnent)

        self.chasedTargetAgent = character.component(ofType: GKAgent3D.self)
        guard self.chasedTargetAgent != nil else { return }

        // Create a Entity that coordinate the potato creation
        self.potatoGeneratorSystem = EnemyGeneratorSystem(scene: self.scene, characterNode: self.character.characterNode)
    }

    /* ESSA FUNÇAO DEVE SER UNICA PRA CADA FASE */
    // Use this function ever in game initialization or restart
    func setupGameInitialization()
    {
        // Configuration of the potato generator system
        self.potatoGeneratorSystem.setupPotatoGeneratorSystem()

        // SystemCompent of SinkComponent
        for sinkComponent in self.sinkComponentSystem.components {
            let sinkComponent = sinkComponent as! SinkComponent
            sinkComponent.resetComponent()
        }
        
        for soundDistanceComponent in soundDistanceComponentSystem.components {
            guard let component = soundDistanceComponent as? SoundDistanceComponent else {
                fatalError("Error getting soundDistanceComponent")
            }
            // clean the played state
            component.resetComponent()
            
        }
    }
    func loadComponentSystem(component: GKComponent) {
        
        for componentSystem in self.componentSystems {
            componentSystem.addComponent(component)
        }
    }
    func removeDistanceAlarm(entity: GKEntity) {
        self.distanceAlarmComponentSystem.removeComponent(foundIn: entity)
    }
    func removeSeekComponent(entity: GKEntity) {
        self.seekComponentSystem.removeComponent(foundIn: entity)
    }
    
    func loadSeekComponent(component: SeekComponent) {
        self.seekComponentSystem.addComponent(component)
    }
    func loadDistanceAlarmComponent(component: DistanceAlarmComponent) {
        self.distanceAlarmComponentSystem.addComponent(component)
    }
    func loadEntityCleanerComponent(component: EntityCleanerComponent) {
        self.entityCleanerComponentSystem.addComponent(component)
    }

    // Creates a potato chasing Pepper
    func createEnemy(type: String, position: SCNVector3, persecutionBehavior: Bool, maxSpeed: Float? = nil, maxAcceleration: Float? = nil)
    {
        var enemy: GKEntity
        
        switch type {
            case EnemyTypes.potato.rawValue :
                enemy = PotatoEntity(model: PotatoType.model1, scene: self.scene, position: position, persecutedTarget: self.chasedTargetAgent, maxSpeed: maxSpeed, maxAcceleration: maxAcceleration,persecutionBehavior: persecutionBehavior)
            
            case EnemyTypes.potatoSpear.rawValue :
                enemy = PotatoSpearEntity(model: PotatoType.model1, scene: self.scene, position: position, trakingAgent: self.chasedTargetAgent)
            
            default:
                 enemy = PotatoEntity(model: PotatoType.model1, scene: self.scene, position: position, persecutedTarget: self.chasedTargetAgent, maxSpeed: maxSpeed, maxAcceleration: maxAcceleration,persecutionBehavior: persecutionBehavior)
        }

        // Add the potato entity to array of potatoes
        if let enemyEnity = enemy as? EnemyEntity {
            self.enemyEntities.append(enemyEnity)
        }
        
    }

    func update(atTime time: TimeInterval)
    {
        if previousUpdateTime == 0.0 {
            previousUpdateTime = time
        }

        let deltaTime = time - previousUpdateTime

        // Component Systems
        for componentSystem in self.componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        //Seek Component
        if seekComponentSystem.components.count > 0
        {
            self.seekComponentSystem.update(deltaTime: deltaTime)
        }

        // distance Alarm Component System
        if self.distanceAlarmComponentSystem.components.count > 0
        {
            self.distanceAlarmComponentSystem.update(deltaTime: deltaTime)
        }

        // Entity cleaner system
        if self.entityCleanerComponentSystem.components.count > 0
        {
            self.entityCleanerComponentSystem.update(deltaTime: deltaTime)
        }
        
		//Sound Random Comoponent
		if soundRandomComponentSystem.components.count > 0
		{
			self.soundRandomComponentSystem.update(deltaTime: time)
		}

		//Sound Distance Comoponent
		if soundDistanceComponentSystem.components.count > 0
		{
			self.soundDistanceComponentSystem.update(deltaTime: deltaTime)
		}


        // Verify the potato generator points
        self.potatoGeneratorSystem.update(deltaTime: deltaTime)

        // Create points that are needed.
        let readyEnemies = self.potatoGeneratorSystem.getReadyPotatoes()
        for enemy in readyEnemies
        {
            let enemyType = enemy.name ?? ""
            self.createEnemy(type: enemyType, position: enemy.position, persecutionBehavior: true)
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

    func killAllPotatoes() {
        for potato in self.enemyEntities {
            // Prepare to kill the potato
            potato.killEnemy()
        }

        self.enemyEntities.removeAll()
    }

    func getEnemyEntity(node: SCNNode) -> GKEntity? {

        for index in 0 ..< self.enemyEntities.count {
            let enemy = self.enemyEntities[index]
            
            let enemyNode = enemy.getEnemyNode()

            if node == enemyNode {

                let enemyEntity = self.enemyEntities[index].getEntity()
                return enemyEntity
            }

        }
        return nil
    }

    func killAnEnemy(node: SCNNode) -> Bool {
        
        var enemyToBeRemoved: Int?
        
        for index in 0 ..< self.enemyEntities.count {
            let enemy = self.enemyEntities[index]
            let enemyNode = enemy.getEnemyNode()

            if node == enemyNode {
                enemyToBeRemoved = index
                break
            }
        }

        if let index = enemyToBeRemoved {
            let enemy = self.enemyEntities[index]

            enemy.killEnemy()
            
            enemyEntities.remove(at: index)
            return true
        }

        return false
    }

	//Add sounds here
	public func addPepperSoundPoints() {
        let soundPoints = self.scene.rootNode.childNode(withName: "levelAudioPoints", recursively: false)?.childNodes
		var distanceComponentArray = [SoundDistanceComponent]()
        
        for soundPoint in soundPoints!
        {
            let x = soundPoint.presentation.position.x
            let z = soundPoint.presentation.position.z
            
            let point = float2(x, z)
            if let soundName = soundPoint.name {
            
                switch soundName {
                    
                case "F1_Pepper_1":
                    
                    let sound = SoundSettings(fileName: "F1_Pepper_1.wav", soundName: soundName, duration: 2.66)
                    distanceComponentArray.append(SoundDistanceComponent(soundSettings: sound, actionPoint: point, minRadius: 165, entity: self.character!, node: (character?.characterNode)!))
                    
                case "F1_Pepper_2":
                    
                    let sound = SoundSettings(fileName: "F1_Pepper_2.wav", soundName: soundName, duration: 3.51)
                    distanceComponentArray.append(SoundDistanceComponent(soundSettings: sound, actionPoint: point, minRadius: 20, entity: self.character!, node: (character?.characterNode)!))
                    
                case "F1_Pepper_3":
                    
                    let sound = SoundSettings(fileName: "F1_Pepper_3.wav", soundName: soundName, duration: 1.56)
                    distanceComponentArray.append(SoundDistanceComponent(soundSettings: sound, actionPoint: point, minRadius: 20, entity: self.character!, node: (character?.characterNode)!))
                    
                case "F1_Pepper_4":
                    
                    let sound = SoundSettings(fileName: "F1_Pepper_4.wav", soundName: soundName, duration: 2.47)
                    distanceComponentArray.append(SoundDistanceComponent(soundSettings: sound, actionPoint: point, minRadius: 40, entity: self.character!, node: (character?.characterNode)!))
                    
                case "F1_Pepper_5":
                    
                    let sound = SoundSettings(fileName: "F1_Pepper_5.wav", soundName: soundName, duration: 2.81)
                    distanceComponentArray.append(SoundDistanceComponent(soundSettings: sound, actionPoint: point, minRadius: 20, entity: self.character!, node: (character?.characterNode)!))
                    
                case "F1_Potato_1":
                    
                    let sound = SoundSettings(fileName: "F1_Potato_1.wav", soundName: soundName, duration: 2.51)
                    distanceComponentArray.append(SoundDistanceComponent(soundSettings: sound, actionPoint: point, minRadius: 50, entity: self.character!, node: (character?.characterNode)!))
                    
                case "F1_Potato_2":
                    
                    let sound = SoundSettings(fileName: "F1_Potato_2.wav", soundName: soundName, duration: 3.17)
                    distanceComponentArray.append(SoundDistanceComponent(soundSettings: sound, actionPoint: point, minRadius: 50, entity: self.character!, node: (character?.characterNode)!))
                default:
                    print("not found")
                }
            }
        }
		for component in distanceComponentArray {
			self.character?.addComponent(component)
			soundDistanceComponentSystem.addComponent(component)
		}
	}
}
