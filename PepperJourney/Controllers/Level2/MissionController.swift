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
    func updateMissionCounter(label: String)
    func setMissionCouterVisibility(isHidden: Bool)
    func enableBigBridgeBattle()
    func releasedAllPrisoners()
}

enum MissionState {
    case beforeBoxOne, openedBox1, openedBox2, openedBox3, openedBox4, openedBox5
}

class MissionController: PrisonerDelegate {
    public var missionState: MissionState = MissionState.beforeBoxOne
    var missionDelegate: MissionDelegate!
    private var prisonerBoxes = [PrisonerBox]()
    private var soundController = SoundController.sharedInstance
    var missionNode: SCNNode!
    
    private var initialBarrier: SCNNode!
    
    init(scene: SCNScene, pepperNode: SCNNode, missionDelegate: MissionDelegate) {
        
        self.missionDelegate = missionDelegate
        
        // Mission node
        guard let missionNode = scene.rootNode.childNode(withName: "mission", recursively: false) else {
            fatalError("Error getting mission node")
        }
        
        self.missionNode = missionNode
        
        //barrier reference
        guard let barrierNode = self.missionNode.childNode(withName: "barrier", recursively: false) else {
            fatalError("Error getting barriers node")
        }
        self.initialBarrier = barrierNode
        
        guard let visualTarget = pepperNode.childNode(withName: "prisonerVisualTarget", recursively: false) else {
            fatalError("Error getting prisonerVisualTarget")
        }
        // Create the boxes in the scene
        self.addPrisonerBoxes(scene: scene, pepperNode: visualTarget)
        
        self.loadMissionSounds()
        
        
    }
    
    func loadMissionSounds() {
        // Prisioner sounds
        self.soundController.loadSound(fileName: "Prisoner1.wav", soundName: "Prisoner1Sound", volume: 1, isPositional: false)
        self.soundController.loadSound(fileName: "acuteYeah.wav", soundName: "PrisonerSound", volume: 1, isPositional: false)
        self.soundController.loadSound(fileName: "Rumors.wav", soundName: "rumorsAboutBigBox", volume: 1, isPositional: false)
        self.soundController.loadSound(fileName: "WarriorAvocado.wav", soundName: "WarriorAvocado", volume: 1, isPositional: false)
        
        
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
            self.missionState = .openedBox1
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "Prisoner1Sound")
            let prisoner2 = Prisoner(type: .RegularAvocado, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .Tomato, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            
            
        case .openedBox1:
            self.missionState = .openedBox2
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "PrisonerSound")
            let prisoner2 = Prisoner(type: .RegularAvocado, talkAudioName: nil)
            
            prisoners = [prisoner1, prisoner2]
            
         
        case .openedBox2:
            self.missionState = .openedBox3
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "PrisonerSound")
            let prisoner2 = Prisoner(type: .Tomato, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .Tomato, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            
        
        case .openedBox3:
            self.missionState = .openedBox4
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: "rumorsAboutBigBox")
            let prisoner2 = Prisoner(type: .RegularAvocado, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .RegularAvocado, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            self.missionDelegate.enableBigBridgeBattle()
            
            
        case .openedBox4:
            self.missionState = .openedBox5
            let warriorAvocado = Prisoner(type: .WarriorAvocado, talkAudioName: "WarriorAvocado")
            prisoners = [warriorAvocado]
            
            
        default:
            let prisoner1 = Prisoner(type: .Tomato, talkAudioName: nil)
            let prisoner2 = Prisoner(type: .Tomato, talkAudioName: nil)
            let prisoner3 = Prisoner(type: .Tomato, talkAudioName: nil)
            prisoners = [prisoner1, prisoner2, prisoner3]
            print("Error mission state")
        }
        prisonerBox.breakBox(prisoners: prisoners)
        
        // update box counter
        let text = "\(self.missionState.hashValue) / 5"
        self.missionDelegate.updateMissionCounter(label: text)
        
    }
    
    // Executa depois que o prisioneiro foi liberto
    func prisionerReleased() {
        if self.missionState == .openedBox1 {
            self.missionDelegate.showNewMission()
            self.initialBarrier.isHidden = true
            self.missionDelegate.setMissionCouterVisibility(isHidden: false)
        }
        if self.missionState == .openedBox5 {
            self.missionDelegate.releasedAllPrisoners()
        }
    }
    
    public func resetMission() {
        self.missionState = .beforeBoxOne
        self.initialBarrier.isHidden = false
        // Reset all the prisoner boxes for the new play
        for prisonerBox in self.prisonerBoxes {
            prisonerBox.resetPrisonerBox()
        }
        
        self.missionDelegate.setMissionCouterVisibility(isHidden: true)
    }
    
    func addPrisonerBoxes(scene: SCNScene, pepperNode: SCNNode) {
        guard let prisonerBoxesNode = self.missionNode.childNode(withName: "prisonerBoxes", recursively: false) else {
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
            
            var isBigBox = false
            if boxNode.name == "box5" {
                isBigBox = true
            }
            // create a box without prisoners
            let box = PrisonerBox(scene: scene,
                                  initialPoint: initialPoint,
                                  finalPoint: finalPoint,
                                  pepperNode: pepperNode,
                                  prisonerDelegate: self, isBigBox: isBigBox)
            

            self.prisonerBoxes.append(box)
        }
    }
    
    public func update() {
        
    }
}
