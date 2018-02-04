//
//  FinalFightController.swift
//  PepperJourney
//
//  Created by Marcelo Martimiano Junior on 19/01/18.
//  Copyright © 2018 Valmir Junior. All rights reserved.
//

import Foundation
import SceneKit

class OverPotatoSceneController {
    
    var bigBridgeNode = [SCNNode]()
    var overPotatoSceneNode: SCNNode!
    
    var cameras = [SCNNode]()
    var camera1StartPosition: SCNVector3!
    var troopStartPosition: SCNVector3!
    public var troopNode: SCNNode!
    
    private var actionsScene: SCNScene!

    private weak var scnView: SCNView?
    private var action: SCNAction!
    private var potatoesNode: SCNNode!
    private var drumPotatoes: SCNNode!
    private var generalNode: SCNNode!
    
    init(scnView: SCNView, scene: SCNScene) {
        self.scnView = scnView
        
        self.getNodes(scene: scene)
   
        // Reset of the scene
        self.resetSceneState()
    }
    
    public func lowerTheBigBridge() {
        self.bigBridgeNode[0].physicsBody?.categoryBitMask = CategoryMaskType.solidSurface.rawValue
        self.bigBridgeNode[1].physicsBody?.categoryBitMask = CategoryMaskType.solidSurface.rawValue
        
        self.bigBridgeNode[0].runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 3))
        self.bigBridgeNode[1].runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 3))
    }
    
    func resetBridge() {
        
        self.bigBridgeNode[0].physicsBody?.categoryBitMask = CategoryMaskType.obstacle.rawValue
        self.bigBridgeNode[1].physicsBody?.categoryBitMask = CategoryMaskType.obstacle.rawValue
        
        self.bigBridgeNode[0].eulerAngles.x = -Float.pi / 4
        self.bigBridgeNode[1].eulerAngles.x = Float.pi / 4
    }
    
    func resetSceneState() {
        self.resetBridge()
        
        // Clean all actions
        self.cleanActions()
        
        // hide Potatoes
        self.potatoesNode.isHidden = true
        
    }
    
    func cleanActions() {
        
        // clean cameras actions
        for camera in self.cameras {
            camera.removeAllActions()
        }
        
        // clean army action
        self.troopNode.removeAllActions()
        
    }
    
   
    
    func runActionScene(completition: @escaping () -> Void) {
        let nextCamera = self.scnView?.pointOfView
        guard self.cameras.count == 4 else {
            print("Error finding the 4 cameras")
            return
        }
        
        // clean all the actions
        self.cleanActions()
        
         let sequence = [
            self.resetCameraAction(),
           
            SCNAction.run { _ in
                // show Potatoes
                self.potatoesNode.isHidden = false
            },
            
            self.resetCameraAction(),
            
            // Change to the camera 1
            SCNAction.run { _ in
                self.changeToCamera(cameraName: "camera1")

                // play the drum sound
                SoundController.sharedInstance.playSoundEffect(soundName: "drumWar", loops: true, node: self.cameras[0])
            },


            // Run camera1 actions
            self.getNodeActionsFromBase(nodeName: "camera1"),

            // Part 2
            SCNAction.run { _ in

                // Stop the drums
                SoundController.sharedInstance.stopSoundsFromNode(node: self.cameras[0])

                // Change to the camera 2
                self.changeToCamera(cameraName: "camera2")

                SoundController.sharedInstance.playSoundEffect(soundName: "generalSpeech", loops: false, node: self.cameras[1])

            },

            // wait the speech
            SCNAction.wait(duration: 5),
            
            SCNAction.run{ _ in

                // Change to the camera 3
                self.changeToCamera(cameraName: "camera3")

                self.lowerTheBigBridge()
                SoundController.sharedInstance.playSoundEffect(soundName: "Drawbridge", loops: false, node: self.cameras[2])
            },
            
            // wait the bridge
            SCNAction.wait(duration: 3.25),
            
            SCNAction.run{ _ in
                // run shaking camera
                self.cameras[2].runAction(self.getNodeActionsFromBase(nodeName: "camera3"))
            },
            
            // wait the shake camera
            SCNAction.wait(duration: 0.75),
            
            SCNAction.run{ _ in
                
                // Attack order
                SoundController.sharedInstance.playSoundEffect(soundName: "attackOrder", loops: false, node: self.cameras[2])
            },
            
            // wait the attack order
            SCNAction.wait(duration: 2.5),
            
            // run march army action
            SCNAction.run{ _ in
                
                // Change to the camera 4
                self.changeToCamera(cameraName: "camera4")
                
                // run marching action
                self.troopNode.runAction(self.getNodeActionsFromBase(nodeName: "army"))
                
                // play the marching sound
                SoundController.sharedInstance.playSoundEffect(soundName: "marching", loops: false, node: self.cameras[3])
                
                // run shaking camera
                self.cameras[3].runAction(self.getNodeActionsFromBase(nodeName: "camera4"))
                
                // Change to the camera 4
                self.changeToCamera(cameraName: "camera4")
               
            },
            
            // wait the march
            SCNAction.wait(duration: 8.77),
            
            SCNAction.run{ _ in
                // stop shaking camera
                self.cameras[3].removeAllActions()

            },
            
            // wait the visualization of the army
            SCNAction.wait(duration: 1),

            // Level controller handle with the scene
            SCNAction.run { _ in

                completition()
                self.drumPotatoes.isHidden = true
                self.generalNode.isHidden = true
            },

            //Restore the original camera
            SCNAction.run { _ in

            self.scnView?.pointOfView = nextCamera
            }
        ]
        
        cameras[0].runAction(SCNAction.sequence(sequence))
    
    }
    
    func resetCameraAction() -> SCNAction {
        
        let resetCameraAction = SCNAction.run({ (cameraPivot) in

            cameraPivot.runAction(SCNAction.move(to: self.camera1StartPosition, duration: 0))
            cameraPivot.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0))
            
            self.resetBridge()
        })
        
        
        return resetCameraAction
    }
    
    func getNodeActionsFromBase(nodeName: String) -> SCNAction {
        
        guard let actionNode = self.actionsScene.rootNode.childNode(withName: nodeName, recursively: false) else {
                fatalError("Error getting \(nodeName) node from actionsScene")
        }
        
        let actionKey = actionNode.actionKeys[0]
        
        guard let action = actionNode.action(forKey: actionKey) else {
            fatalError("Error getting action level 2")
        }
        
        return action
    }
        
    func getNodes(scene: SCNScene) {
        
        // scene with the actions
        guard let actionsScene = SCNScene(named: "Game.scnassets/actions/actionsBase.scn") else {
            fatalError("Error getting actions base scene")
        }
        self.actionsScene = actionsScene
        
        guard let map = scene.rootNode.childNode(withName: "map", recursively: false),
            let bridges = map.childNode(withName: "bridges", recursively: false),
            let bigBridge = bridges.childNode(withName: "bigBridge", recursively: false),
            let halfBigBridge1 = bigBridge.childNode(withName: "halfBigBridge1", recursively: false),
            let halfBigBridge2 = bigBridge.childNode(withName: "halfBigBridge2", recursively: false) else {
                fatalError("Error getting big bridge")
        }
        self.bigBridgeNode = [halfBigBridge1, halfBigBridge2]
        
        // Camera nodes
        guard let overPotatoSceneNode = scene.rootNode.childNode(withName: "overPotatoScene", recursively: false) else {
            fatalError("Error getting overPotatoSceneNode")
        }
        self.overPotatoSceneNode = overPotatoSceneNode
        
        guard let camerasNode = overPotatoSceneNode.childNode(withName: "cameras", recursively: false),
        let cameraStartPosition = camerasNode.childNode(withName: "camera1StartPosition", recursively: false)?.position,
        let camera1 = camerasNode.childNode(withName: "camera1", recursively: false),
        let camera2 = camerasNode.childNode(withName: "camera2", recursively: false),
        let camera3 = camerasNode.childNode(withName: "camera3", recursively: false),
        let camera4 = camerasNode.childNode(withName: "camera4", recursively: false) else {
                fatalError("Error getting camera or camera or camera start position")
        }
        
        self.camera1StartPosition = cameraStartPosition
        self.cameras = [camera1, camera2, camera3, camera4]
        
        guard let potatoesNode = self.overPotatoSceneNode.childNode(withName: "potatoes", recursively: false),
        let drumPotatoes = potatoesNode.childNode(withName: "drumPotatoes", recursively: false),
        let general = potatoesNode.childNode(withName: "general", recursively: false),
            let potatoesArmy = potatoesNode.childNode(withName: "army", recursively: false) else {
                fatalError("Error getting potatoes in the level 2 over potato scene")
        }
        self.potatoesNode = potatoesNode
        self.generalNode = general
        self.drumPotatoes = drumPotatoes
        self.troopNode = potatoesArmy
    }
    
    func changeToCamera(cameraName: String) {
        
        var cameraNode: SCNNode?
        
        for camera in self.cameras {
            if camera.name == cameraName {
                cameraNode = camera
                break
            }
        }
        if let cameraNode = cameraNode {
            self.scnView?.pointOfView = cameraNode
        }
    }
        

}
