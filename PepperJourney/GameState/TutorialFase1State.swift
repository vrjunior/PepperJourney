//
//  TutorialFase1State.swift
//  PepperJourney
//
//  Created by Richard Vaz da Silva Netto on 12/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

class TutorialFase1State: GameBaseState {
	
	override func didEnter(from previousState: GKState?) {
		self.scene.isPaused = true
		self.scene.rootNode.isPaused = true
	}
	
}
