//
//  CGPoint+FromUIView.swift
//  PepperJourney
//
//  Created by Valmir Junior on 28/11/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit

extension CGPoint {
    func fromUiView(height: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: height - self.y)
    }
}
