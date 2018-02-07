//
//  BigBridgeBattleController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 02/02/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

protocol BigBattleDelegate {
    func prepareToTheBattle()
    func runAfterBattle()
    func killPreviousPotatoes()
    func getPepperPosition() -> SCNVector3
    func createPotato(potatoType: PotatoType, position: SCNVector3, persecutionBehavior: Bool, tag: String?)
    func getPotatoesNumber() -> Int
    func getPotato(tag: String) -> [PotatoEntity]
}
/*
 matar todas as outras batatas antes de comecar a gerar essas e colocar tudo no entity manager
 ativar batatas somente quando a pimenta chegar na ilha
 */
enum BattleState {
    case releasingPrisoners, waitingPepper, disarmadPotatoesFight, actionSCene, spearPotatoesFight, finishedBattle
}


class BigBridgeBattleController {
    weak var scnView: SCNView!
    var battleState: BattleState = .releasingPrisoners
    
    var potatoesToCreate: Float = 0
    let totalPotatoNumber:Float = 15
    
    var generationPoints = [SCNVector3]()
    
    var actionSceneController: OverPotatoSceneController!
    var bigBattleDelegate: BigBattleDelegate!
    var bigBattleNode: SCNNode!
    
    var trapPoint:SCNVector3!
    var trapBridge: SCNNode!
    var generationTime: TimeInterval = 0
    var timeCounter: TimeInterval = 0
    var currentBattalion = 1
    var lastPotatoNumber = 0
    weak var persecutedTarget: GKAgent3D!
    var barrier: SCNNode!
    
    init(scnView: SCNView, scene: SCNScene, delegate: BigBattleDelegate, persecutedTarget: GKAgent3D) {
        self.bigBattleDelegate = delegate
        self.scnView = scnView
        self.persecutedTarget = persecutedTarget
        self.actionSceneController = OverPotatoSceneController(scnView: scnView, scene: scene)
        
        guard let markersNode = scene.rootNode.childNode(withName: "markers", recursively: false),
        let bigBattle = markersNode.childNode(withName: "bigBattle", recursively: false),
        let trapPoint = bigBattle.childNode(withName: "trapPoint", recursively: false)?.position,
        let barrier = bigBattle.childNode(withName: "barrier", recursively: false),
        let generationPoints = bigBattle.childNode(withName: "generationPoints", recursively: false)?.childNodes else {
                fatalError("Error getting nodes in big battle")
        }
        
        for generationPoint in generationPoints {
            let position = generationPoint.worldPosition
            self.generationPoints.append(position)
        }
        
        self.bigBattleNode = bigBattle
        self.trapPoint = trapPoint
        self.barrier = barrier
        
        
        guard let map = scene.rootNode.childNode(withName: "map", recursively: false),
        let trapBridge = map.childNode(withName: "trapBridge", recursively: false) else {
            fatalError("Error getting trapBridge")
        }
        
        self.trapBridge = trapBridge
    }
    
    public func resetBattle() {
        self.battleState = .releasingPrisoners
        self.actionSceneController.resetSceneState()
        self.potatoesToCreate = self.totalPotatoNumber
        self.timeCounter = 0
        self.generationTime = self.getNewGenerationTime()
        self.trapBridge.isHidden = false
        self.currentBattalion = 0
        // enable the barrier
        self.barrier.isHidden = false
    }
    
    public func startBigBattle() {
        self.battleState = .waitingPepper
    }
    
    func update(deltaTime: TimeInterval) {
        
        if self.battleState == .releasingPrisoners {
            return
        }
        
        if self.battleState == .waitingPepper {
            let peperPosition = self.bigBattleDelegate.getPepperPosition()
            
            let deltaX = peperPosition.x - self.trapPoint.x
            let deltaZ = peperPosition.z - self.trapPoint.z
            
            let distance = sqrt(deltaX * deltaX + deltaZ * deltaZ)
            
            if distance < 200 {
                self.trapBridge.isHidden = true
//                let angle = CGFloat(20 * Float.pi / 180)
//                self.trapBridge.runAction(SCNAction.rotateTo(x: angle , y: 0, z: 0, duration: 2))
                
                SoundController.sharedInstance.playSoundEffect(soundName: "F2_Potato_1", loops: false, node: self.scnView.pointOfView!)
                SubtitleController.sharedInstance.setupSubtitle(subName: "F2_Potato_1")
                
                self.bigBattleDelegate.killPreviousPotatoes()
                
                self.battleState = .disarmadPotatoesFight
            }
            return
        }
        
        let alivePotatoesNumber = self.bigBattleDelegate.getPotatoesNumber()
        
        if self.battleState == .disarmadPotatoesFight {
            if alivePotatoesNumber == 0 && self.potatoesToCreate == 0 {
                self.battleState = .actionSCene
                self.bigBattleDelegate.prepareToTheBattle()
                
                // run action scene
                self.actionSceneController.runActionScene(completition: {
                    
                    self.bigBattleDelegate.runAfterBattle()
                    
                    
                    self.createSpearPotatoTroop()
                    
                    self.battleState = .spearPotatoesFight
                    self.lastPotatoNumber = self.bigBattleDelegate.getPotatoesNumber()
                    
                })
                return
            }
            
            let minPotatoNumber = Int((self.totalPotatoNumber - self.potatoesToCreate) / 5)  + 1
            
            if alivePotatoesNumber <  minPotatoNumber && self.potatoesToCreate > 0 {
                
                self.timeCounter += deltaTime
                
                if timeCounter >= self.generationTime {
                    self.generationTime = self.getNewGenerationTime()
                    self.timeCounter = 0
                    
                    let position = self.getRandoPosition()
                    self.bigBattleDelegate.createPotato(potatoType: .disarmad, position: position, persecutionBehavior: true, tag: nil)
                    
                    self.potatoesToCreate -= 1
                }
            }
        }
        
        if self.battleState == .spearPotatoesFight {
            if alivePotatoesNumber == 25 - (currentBattalion * 5) {
                if currentBattalion < 5 {
                    self.currentBattalion += 1
                    
                    let battalionName = "battalion" + String(self.currentBattalion)
                    let potatoes = self.bigBattleDelegate.getPotato(tag: battalionName)
                    
                    for potato in potatoes {
                        potato.setPersecutionBehavior(persecutedTarget: self.persecutedTarget)
                        potato.playAnimation(type: .running)
                    }
                    self.lastPotatoNumber = self.bigBattleDelegate.getPotatoesNumber()
                }
                else {
                    battleState = .finishedBattle
                    
                    // relaese the barrier
                    self.barrier.isHidden = true
                }
            }
        }
    }
    func getRandoPosition() -> SCNVector3 {
        
        let maxNumber = UInt32(self.generationPoints.count - 1)
        
        let randomNumber: Int = Int(arc4random_uniform(maxNumber))
        return self.generationPoints[randomNumber]
    }
    
    func getNewGenerationTime() -> TimeInterval {
        let min: TimeInterval = 0.5
        let maxInterval = UInt32(1.5)
        
        let randomTime = TimeInterval(arc4random_uniform(maxInterval))
        
        return min + randomTime
    }
    

    func createSpearPotatoTroop() {
        guard let battalions = self.actionSceneController.battalions else {
            print("Error getting battalions from action scene")
            return
        }
        
        for battalion in battalions {
            
            let potatoes = battalion.childNodes
            for potato in potatoes {
                guard let name = battalion.name else {
                    print("Error getting battalion name")
                    return
                    
                }
                self.bigBattleDelegate.createPotato(potatoType: .disarmad, position: potato.presentation.worldPosition, persecutionBehavior: false, tag: name)
            }
            
        }
      
    }
    
}





























