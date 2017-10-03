//
//  CircleGestureRecognizer.swift
//  SpicyHero
//
//  Created by Valmir Junior on 03/10/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class CircleGestureRecognizer : UIGestureRecognizer {
    
    private var touchedPoints = [CGPoint]()
    var fitResult = CircleResult() // information about how circle-like is the path
    var tolerance: CGFloat = 0.2 // circle wiggle room
    var isCircle = false
    
    var path = CGMutablePath()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if(touches.count != 1) {
            state = .failed
        }
        
        if let loc = touches.first?.location(in: self.view) {
            path.move(to: loc) // start the path
        }
        
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        //here we check if the gesture already failed
        //apple recommends it, because this could occur
        //Touch events are buffered and processed serially in the event queue. If a the user moves the touch fast enough, there could be touches pending and processed after the gesture has already failed.
        if state == .failed {
            return
        }
        
        let view = self.view
        if let loc = touches.first?.location(in: view) {
            
            touchedPoints.append(loc)
            
            path.addLine(to: loc) //add line
            
            state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        // now that the user has stopped touching, figure out if the path was a circle
        self.fitResult = fitCircle(points: self.touchedPoints)
        
        isCircle = fitResult.error <= tolerance
        
        state = isCircle ? .ended : .failed
    }
    
    override func reset() {
        super.reset()
        touchedPoints.removeAll(keepingCapacity: true)
        path = CGMutablePath()
        isCircle = false
        state = .possible
    }
    
}

