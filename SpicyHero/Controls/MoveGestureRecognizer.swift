//
//  MoveGestureRecognizer.swift
//  SpicyHero
//
//  Created by Valmir Junior on 03/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import CoreGraphics

class MoveGestureRecognizer : UIGestureRecognizer {
   
    var center: CGPoint = CGPoint()
    var radius: CGFloat = CGFloat()
    var angle: CGFloat = CGFloat()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        if(touches.count != 1) {
            self.state = .failed
        }
        
        if let loc = touches.first?.location(in: self.view) {
            self.center = loc
            self.state = .began
            print("began: \(self.center)")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if let loc = touches.first?.location(in: self.view) {
            self.radius = self.distance(center, loc)
            self.angle = self.calculateAngle(center: center, finalPosition: loc)
            
            print("moved: \(loc)")
            
            self.state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        state = .ended
    }
    
    //calculate distance between two cgpoints
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func calculateAngle(center: CGPoint, finalPosition: CGPoint) -> CGFloat {
        
        let deltaX = Float(finalPosition.x - center.x)
        let deltaY = Float(finalPosition.y - center.y)
        
        let angle = atan2f(deltaX, deltaY)
        
        return CGFloat(angle) * CGFloat(180.0 / Float.pi)
        
    }
    
}

