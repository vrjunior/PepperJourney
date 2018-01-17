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
    var missionState: MissionState = MissionState.beforeBoxOne
    var missionDelegate: MissionDelegate!
    private var prisonerBoxes = [PrisonerBox]()
    private var soundController = SoundController.sharedInstance
    
    private var initialBarrier: SCNNode!
    
    init(scene: SCNScene, pepperNode: SCNNode, missionDelegate: MissionDelegate) {
        self.addPrisonerBoxes(scene: scene, pepperNode: pepperNode)
        self.missionDelegate = missionDelegate
        
        self.loadMissionSounds()
        
//         barrier reference
        guard let missionNode = scene.rootNode.childNode(withName: "mission", recursively: false),
            let barrierNode = missionNode.childNode(withName: "barriers", recursively: false) else {
                print("Error getting barriers node")
                return
        }
        self.initialBarrier = barrierNode
    }
    
    func loadMissionSounds() {
        // Prisioner sounds
        self.soundController.loadSound(fileName: "Prisoner1.wav", soundName: "Prisoner1Sound", volume: 50.0)
        self.soundController.loadSound(fileName: "d", soundName: "Prisoner1Sound", volume: 30.0)
    }
    
    func breakBox(boxNode: SCNNode) {
        for prisonerBox in self.prisonerBoxes {
            if let modelNode = prisonerBox.box.component(ofType: ModelComponent.self)?.modelNode {
                if modelNode == boxNode {
                    self.breakTheRightBox(prisonerBox: prisonerBox)
                }
            }
        }
    }
    
    func breakTheRightBox(prisonerBox: PrisonerBox) {
        let prisoners: [Prisoner]
        
        switch self.missionState {
        case .beforeBoxOne:
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "Prisoner1Sound")
            let prisoner2 = Prisoner(type: .Avocado, talkAudioName: "PrisonerSound")
            let prisoner3 = Prisoner(type: .Avocado, talkAudioName: "PrisonerSound")
            prisoners = [prisoner1, prisoner2, prisoner3]
            self.missionState = .openedBox1
            
        case .openedBox1:
            let prisoner1 = Prisoner(type: .Avocado, talkAudioName: "PrisonerSound")
            let prisoner2 = Prisoner(type: .Avocado, talkAudioName: nil)
            
            prisoners = [prisoner1, prisoner2]
            self.missionState = .openedBox2
         
        case .openedBox2:
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "PrisonerSound")
            let prisoner2 = Prisoner(type: .Avocado, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .Avocado, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            self.missionState = .openedBox3
        
        case .openedBox3:
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "PrisonerSound")
            let prisoner2 = Prisoner(type: .Avocado, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .Avocado, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            self.missionState = .openedBox4
            
        case .openedBox4:
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "PrisonerSound")
            let prisoner2 = Prisoner(type: .Avocado, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .Avocado, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            self.missionState = .openedBox5
            
        default:
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: nil)
            let prisoner2 = Prisoner(type: .Tomato, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .Tomato, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            print("Error mission state")
        }
        prisonerBox.breakBox(prisoners: prisoners)
    }
    func prisionerReleased() {
        if self.openBoxCounter == 0 {
            self.missionDelegate.showNewMission()
        }
        
        self.openBoxCounter += 1
        let text = "\(self.openBoxCounter) / 5"
//        self.missionDelegate.updateMissionCounter(hide: false, label: text)
        
    }
    
    public func resetMission() {
        self.openBoxCounter = 0
        self.missionState = .beforeBoxOne
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
            
            // create a box without prisoners
            let box = PrisonerBox(scene: scene,
                                  initialPoint: initialPoint,
                                  finalPoint: finalPoint,
                                  pepperNode: pepperNode,
                                  prisonerDelegate: self)
            

            self.prisonerBoxes.append(box)
        }
    }
    
    public func update() {
        
    }
}
