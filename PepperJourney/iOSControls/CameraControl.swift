//
//  CameraControl.swift
//  PepperJourney
//
//  Created by Valmir Junior on 04/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import SpriteKit

class CameraControl: SKSpriteNode {
    
    public var delegate: Controls?
    public var isPausedControl = false {
        didSet {
            if isPausedControl == true {
                self.destroyControl()
            }
            else {
                self.line?.alpha = 1
                self.mark?.alpha = 1
            }
        }
    }
    private var lineSize: CGSize!
    private var lineColor: UIColor!
    private var line: SKSpriteNode?
    private var mark: SKSpriteNode?
    private var markSize: CGSize!
    private var trackingTouch: UITouch?
    private var initialPosition: CGPoint = CGPoint()
    private var previousRotation: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
       
        self.line = self.childNode(withName: "line") as? SKSpriteNode
        self.lineSize = self.line?.size
        
        self.mark = self.childNode(withName: "mark") as? SKSpriteNode
        self.markSize = self.mark?.size
        
        self.destroyControl()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 {
            return
        }
        
        if !isPausedControl {
            self.trackingTouch = touches.first
            self.initialPosition = trackingTouch!.location(in: self)
            
            self.buildControl()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 {
            return
        }
        
        self.destroyControl()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 {
            return
        }
        
        let currentPosition = touches.first!.location(in: self)
        
        if !isPausedControl {
            var distance = currentPosition.x - self.initialPosition.x
            distance = distance > self.lineSize.width / 2 ? (self.lineSize.width / 2) : distance
            distance = distance < -(self.lineSize.width / 2) ? -(self.lineSize.width / 2) : distance
            
            let newPosition = CGPoint(x: self.initialPosition.x + distance, y: self.initialPosition.y)
            
            //update marker on line
            self.updateLineMark(position: newPosition)
            
            //call the delegate method
            let angleToRotate = self.getAngle(byDistance: distance) - previousRotation
            self.delegate?.rotateCamera(angle: angleToRotate)
            
            //set previousRotation
            previousRotation += angleToRotate
            
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.destroyControl()
    }
    
    private func buildControl() {
        self.line?.position = initialPosition
        self.mark?.position = initialPosition
        
        self.line?.alpha = 1
        self.mark?.alpha = 1
    }
    
    private func destroyControl() {
        self.previousRotation = 0
        
        self.line?.alpha = 0
        self.mark?.alpha = 0
    }
    
    
    private func updateLineMark(position: CGPoint) {
        self.mark?.position = position
    }
    
    private func getAngle(byDistance distance: CGFloat) -> CGFloat {
        let maxX: CGFloat = self.lineSize.width / 2
        let minX: CGFloat = -(self.lineSize.width / 2)
        
        //TO get the entire circle is 2 pi
        let a: CGFloat = -(CGFloat.pi / 2)
        let b: CGFloat = CGFloat.pi / 2
        
        let result = (b - a) * ((distance - minX) / (maxX - minX)) + a
        
        return -result
    }
    
}
