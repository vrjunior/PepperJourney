//
//  MissionController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 15/01/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

protocol PrisonerDelegate {
    func prisionerReleased()
}

protocol MissionDelegate {
    func showNewMission()
    func updateMissionCounter(hide: Bool, label: String?)
}

enum MissionState {
    case beforeBoxOne, openedBox1, openedBox2, openedBox3, openedBox4, openedBox5
}
class MissionController: PrisonerDelegate {
    var openBoxCounter: Int = 0
    var currentState: MissionState = MissionState.beforeBoxOne
    var missionDelegate: MissionDelegate!
    private var prisonerBoxes = [PrisonerBox]()
    
    init(scene: SCNScene, pepperNode: SCNNode, missionDelegate: MissionDelegate) {
        self.addPrisonerBoxes(scene: scene, pepperNode: pepperNode)
        self.missionDelegate = missionDelegate
    }
    
    func breakBox(boxNode: SCNNode) {
        for prisonerBox in self.prisonerBoxes {
            if let modelNode = prisonerBox.box.component(ofType: ModelComponent.self)?.modelNode {
                if modelNode == boxNode {
                    prisonerBox.breakBox()
                }
            }
        }
    }
    
    func prisionerReleased() {
        if self.openBoxCounter == 0 {
            self.missionDelegate.showNewMission()
        }
        
        self.openBoxCounter += 1
        let text = "\(self.openBoxCounter) / 5"
        self.missionDelegate.updateMissionCounter(hide: false, label: text)
        
    }
    
    public func resetMission() {
        self.openBoxCounter = 0
        // Reset all the prisoner boxes for the new play
        for prisonerBox in self.prisonerBoxes {
            prisonerBox.resetPrisonerBox()
        }
        
        self.missionDelegate.updateMissionCounter(hide: true, label: nil)
    }
    
    func addPrisonerBoxes(scene: SCNScene, pepperNode: SCNNode) {
        guard let prisonerBoxesNode = scene.rootNode.childNode(withName: "prisonerBoxes", recursively: false) else {
            fatalError("Error getting prisonerBoxes node")
        }
        let prisonerBoxesNodePosition = prisonerBoxesNode.presentation.position
        
        let boxNodes = prisonerBoxesNode.childNodes
        
        for boxNode in boxNodes {
            
            // box position relative at the scene world
            let initialPoint = SCNNode()
            initialPoint.position.x =  prisonerBoxesNodePosition.x + boxNode.presentation.position.x
            initialPoint.position.y =  prisonerBoxesNodePosition.y + boxNode.presentation.position.y
            initialPoint.position.z =  prisonerBoxesNodePosition.z + boxNode.presentation.position.z
            
            // Character final position
            guard let destinationPoint = boxNode.childNode(withName: "destinationPoint", recursively: false) else {
                fatalError("Error getting destinationPoint node to PrisonerBox")
            }
            // Final position relative at the scene world
            let finalPoint = SCNNode()
            finalPoint.position.x = initialPoint.position.x + destinationPoint.position.x
            finalPoint.position.y = initialPoint.position.y + destinationPoint.position.y
            finalPoint.position.z = initialPoint.position.z + destinationPoint.position.z
            
            let characters: [PrisonerType] = [.Avocado, .Tomato, .Tomato]
            
            var boxName = ""
            if boxNode.name != nil {
                boxName = boxNode.name!
            }
            // create a box with prisoners
            let box = PrisonerBox(boxName: boxName,
                                 scene: scene,
                                 initialPoint: initialPoint,
                                 finalPoint: finalPoint,
                                 characterTypeArray: characters,
                                 pepperNode: pepperNode,
                                 talkTime: 0,
                                 talkAudioName: "PrisonerSound",
                                 prisonerDelegate: self)
    
            self.prisonerBoxes.append(box)
        }
    }
    
    public func update() {
        
    }
}
