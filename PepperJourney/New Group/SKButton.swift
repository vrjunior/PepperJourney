//
//  SKButton.swift
//  PepperJourney
//
//  Created by Valmir Junior on 13/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import SpriteKit

protocol SKButtonDelegate {
    func buttonPressed(target: SKButton)
}

class SKButton : SKSpriteNode {
    
    public var delegate : SKButtonDelegate?
	
	var isPausedControls: Bool = false {
		didSet {
			if isPausedControls {
				self.isHidden = true
			}
			else {
				self.isHidden = false
			}
		}
	}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.buttonPressed(target: self)
    }
    
}

