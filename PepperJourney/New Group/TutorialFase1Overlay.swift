//
//  TutorialFase1Overlay.swift
//  PepperJourney
//
//  Created by Richard Vaz da Silva Netto on 12/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit


class TutorialFase1Overlay: SKScene {
	
	var gameOptionsDelegate:GameOptions?
	private var resumeButton: SKButton!
	public var fase1GameController: Fase1GameController?
	
	override func sceneDidLoad() {
		self.resumeButton = self.childNode(withName: "resumeButton") as! SKButton
        self.resumeButton.delegate = self
	}
}

extension TutorialFase1Overlay : SKButtonDelegate {

    func buttonPressed(target: SKButton) {
//        self.gameOptionsDelegate?.skipTutorial()
		self.gameOptionsDelegate?.resume()
        
		self.fase1GameController?.generatePotatoCrowd(markerName: "tutorialSpawnPoint", amount: 10)
        
//		print("Pressed")
    }

}

