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

class EntityManager {
    // colocar aqui os components system
	var soundRandomComponentSystem = GKComponentSystem(componentClass: SoundRandomComponent.self)
	var soundDistanceComponentSystem = GKComponentSystem(componentClass: SoundDistanceComponent.self)
    var distanceAlarmComponentSystem = GKComponentSystem(componentClass: DistanceAlarmComponent.self)
    var entityCleanerComponentSystem = GKComponentSystem(componentClass: EntityCleanerComponent.self)

    

    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    
    // Level 2
    public var tutorialEnemyGeneration: EnemyGeneratorSystem?
    // Private init of the Singleton
    private init() {
        
    }
    /***************************************************************************************************/
    /********************************************************************************************************/
    
    // Game entities
    public var character: Character!
    private(set) var potatoGeneratorSystem: EnemyGeneratorSystem!
    
    private(set) var potatoes = [PotatoEntity]()
    var componentSystems = [GKComponentSystem]()
    private weak var soundController: SoundController!
    private var chasedTargetAgent: GKAgent3D!
    
    public static var sharedInstance = EntityManager()
    private var scene: SCNScene!
    
    public func createComponentSystems(componentSystems: [GKComponentSystem<GKComponent>]) {
        self.componentSystems = componentSystems
    }
    
    // Load a component of any type to the right component system
    // Must create the component system previously
    public func loadToComponentSystem(component: GKComponent) {
        
        for componentSystem in self.componentSystems {
            if component.classForCoder == componentSystem.componentClass {
                componentSystem.addComponent(component)
            }
        }
    }
    
    public func removeOfComponentSystem(component: GKComponent) {
        for componentSystem in self.componentSystems {
            if component.classForCoder == componentSystem.componentClass {
                componentSystem.removeComponent(component)
            }
        }
    }
    
    public func getComponentSystem(ofType: GKComponent.Type) -> GKComponentSystem<GKComponent> {
        
        // Component Systems
        for componentSystem in self.componentSystems {
            if ofType == componentSystem.componentClass {
                return componentSystem
            }
        }
        fatalError("Error getting componentSystem")
    }
    
    func getPotatoesNumber() -> Int {
        return self.potatoes.count
    }
    
    // Creates a potato chasing Pepper
    func createEnemy(potatoType: PotatoType, position: SCNVector3, persecutionBehavior: Bool, maxSpeed: Float? = nil, maxAcceleration: Float? = nil, tag: String? = nil)
    {
        
        var animations: [AnimationType]
        var states: [PotatoState]
        
        if potatoType == PotatoType.spear {
            animations =  [.running]
            
            let runningState = RunningPotatoState(animation: .running)
            //            let attackState = AttackingPotatoState(animation: .attack)
            //            let beatingSpearState = BeatingSpearPotatoState(animation: .beatingSpear)
            //            let marchingState = MarchingPotatoState(animation: .marching)
            
            states = [runningState]
            
        }
        else {
            animations =  [.running]
            
            let runningState = RunningPotatoState(animation: .running)
            
            states = [runningState]
        }
        
        let potato = PotatoEntity(type: potatoType, scene: self.scene, position: position, animations: animations,  potatoStates: states, tag: tag)
        
        if persecutionBehavior {
            potato.setPersecutionBehavior(persecutedTarget: self.chasedTargetAgent, maxSpeed: maxSpeed, maxAcceleration: maxAcceleration)
            potato.stateMachine.enter(RunningPotatoState.self)
        }
        
        potato.setSinkBehavior()
        
        
        // Add the potato entity to array of potatoes
        self.potatoes.append(potato)
    }
    
    func getPotatoEntity(wantedTag: String) -> [PotatoEntity] {
        
        var foundPotatoes = [PotatoEntity]()
        for potato in self.potatoes {
            if let tag = potato.tag,
            tag == wantedTag {
                foundPotatoes.append(potato)
            }
        }
        return foundPotatoes
    }
    

    /***************************************************************************************************/
    
    func setPotatoesSpeed(speed: Float, acceleration: Float) {
        for potato in self.potatoes {
            potato.component(ofType: PursueComponent.self)?.speed = speed
            potato.component(ofType: PursueComponent.self)?.maxAcceleration = acceleration
        }
        
    }
    
    func initEntityManager (scene: SCNScene, gameController: GameController, soundController: SoundController)
    {
        self.scene = scene
        self.soundController = soundController
        
        // Add the componentSystems
        let componentSystem = GKComponentSystem(componentClass: AttackLimiterComponent.self)
        self.componentSystems.append(componentSystem)
        
        self.chasedTargetAgent = character.component(ofType: GKAgent3D.self)
        guard self.chasedTargetAgent != nil else { return }
        
        // Create a Entity that coordinate the potato creation
        self.potatoGeneratorSystem = EnemyGeneratorSystem(scene: self.scene, characterNode: self.character.characterNode)
    }

    /* ESSA FUNÇAO DEVE SER UNICA PRA CADA FASE */
    // Use this function ever in game initialization or restart
    func setupGameInitialization()
    {
        self.killAllPotatoes()
        
        // Configuration of the potato generator system
        self.potatoGeneratorSystem.setupPotatoGeneratorSystem()
        
        // SystemCompent of SinkComponent
        let sinkComponentSystem = self.getComponentSystem(ofType: SinkComponent.self)
        for sinkComponent in sinkComponentSystem.components {
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
    
    func removeDistanceAlarm(entity: GKEntity) {
        self.distanceAlarmComponentSystem.removeComponent(foundIn: entity)
    }
    
    func loadDistanceAlarmComponent(component: DistanceAlarmComponent) {
        self.distanceAlarmComponentSystem.addComponent(component)
    }
    func loadEntityCleanerComponent(component: EntityCleanerComponent) {
        self.entityCleanerComponentSystem.addComponent(component)
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
            self.createEnemy(potatoType: .disarmad, position: enemy.position, persecutionBehavior: true)
        }
        
        // tutorial potato generation
        if let tutorialEnemyGeneration = self.tutorialEnemyGeneration {
            tutorialEnemyGeneration.update(deltaTime: deltaTime)
            // Create points that are needed.
            
            let readyEnemies = tutorialEnemyGeneration.getReadyPotatoes()
            for enemy in readyEnemies
            {
                self.createEnemy(potatoType: .disarmad, position: enemy.position, persecutionBehavior: true, maxSpeed: 30, maxAcceleration: 3)
            }
        }
        
        
        self.previousUpdateTime = time
        
        /* Character update */
        if let attackComponent = self.character.component(ofType: AttackComponent.self) {
            attackComponent.update(deltaTime: deltaTime)
        }
        
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
        for potato in self.potatoes {
            // Prepare to kill the potato
            potato.killPotato()
        }

        self.potatoes.removeAll()
    }

    func getPotatoEntity(node: SCNNode) -> PotatoEntity? {
        
        for index in 0 ..< self.potatoes.count {
            let enemy = self.potatoes[index]
            
            let enemyNode = enemy.getEnemyNode()
            
            if node == enemyNode {
                return self.potatoes[index]
            }
            
        }
        return nil
    }

    func killAnEnemy(node: SCNNode) -> Bool {
        
        var enemyToBeRemoved: Int?
        
        for index in 0 ..< self.potatoes.count {
            let enemy = self.potatoes[index]
            let enemyNode = enemy.getEnemyNode()

            if node == enemyNode {
                enemyToBeRemoved = index
                break
            }
        }

        if let index = enemyToBeRemoved, index < potatoes.count {
            let enemy = self.potatoes[index]

            enemy.killPotato()
            
            potatoes.remove(at: index)
            return true
        }
        else {
            print("Deu ruim em killAnEnemy. enemyToBeRemoved index: \(enemyToBeRemoved) e enemyEntities.count: \(potatoes.count)")
        }

        return false
    }

	// Sounds
    public func addPepperSoundPoints(distanceComponentArray: [SoundDistanceComponent]) {
        
		for component in distanceComponentArray {
			self.character?.addComponent(component)
			soundDistanceComponentSystem.addComponent(component)
		}
	}
}
