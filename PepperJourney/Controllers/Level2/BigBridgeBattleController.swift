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
    func kiilPreviousPotatoes()
    func getPepperPosition() -> SCNVector3
    func createPotato(position: SCNVector3)
    func getPotatoesNumber() -> Int
}
/*
 matar todas as outras batatas antes de comecar a gerar essas e colocar tudo no entity manager
 ativar batatas somente quando a pimenta chegar na ilha
 */
enum BattleState {
    case releasingPrisoners, waitingPepper, disarmadPotatoesFight, actionSCene,spearPotatoesFight
}

class BigBridgeBattleController {
    weak var scnView: SCNView!
    var battleState: BattleState = .releasingPrisoners
    var spearPotatoes = [PotatoEntity]()
    
    var potatoesToCreate: Float = 0
    let totalPotatoNumber:Float = 2//15
    
    var generationPoints = [SCNVector3]()
    
    var actionSceneController: OverPotatoSceneController!
    var bigBattleDelegate: BigBattleDelegate!
    var bigBattleNode: SCNNode!
    
    var trapPoint:SCNVector3!
    var trapBridge: SCNNode!
    var generationTime: TimeInterval = 0
    var timeCounter: TimeInterval = 0
    
    init(scnView: SCNView, scene: SCNScene, delegate: BigBattleDelegate) {
        self.bigBattleDelegate = delegate
        self.scnView = scnView
        self.actionSceneController = OverPotatoSceneController(scnView: scnView, scene: scene)
        
        guard let markersNode = scene.rootNode.childNode(withName: "markers", recursively: false),
        let bigBattle = markersNode.childNode(withName: "bigBattle", recursively: false),
        let trapPoint = bigBattle.childNode(withName: "trapPoint", recursively: false)?.position,
        let generationPoints = bigBattle.childNode(withName: "generationPoints", recursively: false)?.childNodes else {
                fatalError("Error getting nodes in big battle")
        }
        
        for generationPoint in generationPoints {
            let position = generationPoint.worldPosition
            self.generationPoints.append(position)
        }
        
        self.bigBattleNode = bigBattle
        self.trapPoint = trapPoint
        
        
        guard let map = scene.rootNode.childNode(withName: "map", recursively: false),
        let bridges = map.childNode(withName: "bridges", recursively: false),
        let trapBridge = bridges.childNode(withName: "trapBridge", recursively: false) else {
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
        self.trapBridge.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0))
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
                self.battleState = .disarmadPotatoesFight
                
                let angle = CGFloat(20 * 180 / Float.pi)
                self.trapBridge.runAction(SCNAction.rotateTo(x: angle , y: 0, z: 0, duration: 2))
                SoundController.sharedInstance.playSoundEffect(soundName: "F2_Potato_1", loops: false, node: self.scnView.pointOfView!)
            }
            return
        }
        
        let alivePotatoesNumber = self.bigBattleDelegate.getPotatoesNumber()
        
        if self.battleState == .disarmadPotatoesFight {
            if alivePotatoesNumber == 0 && self.potatoesToCreate == 0 {
                self.battleState = .actionSCene
                self.bigBattleDelegate.prepareToTheBattle()
                self.actionSceneController.runActionScene(completition: {
                    self.bigBattleDelegate.runAfterBattle()
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
                    self.bigBattleDelegate.createPotato(position: position)
                    
                    self.potatoesToCreate -= 1
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
    
}
