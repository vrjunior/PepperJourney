//
//  TutorialFase1Overlay.swift
//  PepperJourney
//
//  Created by Richard Vaz da Silva Netto on 12/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit


class TutorialFase1Overlay: SKScene {
	
	var gameOptionsDelegate:GameOptions?
	private var resumeButton: SKSpriteNode!
	
	override func sceneDidLoad() {
		self.resumeButton = self.childNode(withName: "resumeButton") as! SKSpriteNode
	}
	
	override func didMove(to view: SKView) {
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TutorialFase1Overlay.handleTap(_:)))
		view.addGestureRecognizer(tapGesture)
		
	}
	
	@objc func handleTap(_ gesture: UITapGestureRecognizer) {
		let location = gesture.location(in: self.view).fromUiView(height: self.view!.frame.height)
		
		if resumeButton.contains(location) {
			self.gameOptionsDelegate?.resume()
		}
	}
}

