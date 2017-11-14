/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Exposes D-Pad game controller type functionality with screen-rendered buttons.
*/

import SpriteKit
import UIKit.UIGestureRecognizerSubclass
import simd

protocol PadOverlayDelegate: NSObjectProtocol {
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay)
    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay)
    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay)
}

class PadOverlay: SKSpriteNode {
    // Default 100, 100
    
    public weak var delegate: PadOverlayDelegate?
    
    var padSize = CGSize.zero {
        didSet {
            if padSize != oldValue {
                updateForSizeChange()
            }
        }
    }
    
    // Range [-1, 1]
    var stickPosition = CGPoint.zero {
        didSet {
            if stickPosition != oldValue {
                updateStickPosition()
            }
        }
    }
    
    private var trackingTouch: UITouch?
    private var startLocation = CGPoint.zero
    private var stick: SKSpriteNode!
    
    private var padBackground: SKSpriteNode!
    
    private var lowerXSafeArea: CGFloat!
    private var lowerYSafeArea: CGFloat!
    private var higherXSafeArea: CGFloat!
    private var higherYSafeArea: CGFloat!
    
    
    public var isPausedControl = false {
        didSet {
            if isPausedControl == true {
                self.destroyPad()
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        alpha = 0.7
        isUserInteractionEnabled = true
        
        self.setupPad()
        print("padsize: \(self.padSize)")
    }
    
    func setupPad() {
        self.padBackground = self.childNode(withName: "padBackground") as! SKSpriteNode
        
        self.stick = self.padBackground.childNode(withName: "stick") as! SKSpriteNode
        
        self.padSize = self.padBackground.size
        
        
        self.lowerXSafeArea = self.padSize.width / 2
        self.lowerYSafeArea = self.padSize.height / 2
        self.higherXSafeArea = self.size.width - self.padSize.width
        self.higherYSafeArea = self.size.height - self.padSize.height
        
    }
    
    func buildPad() {
        
        self.padBackground.alpha = 1
        
        self.startLocation = checkSafeArea(position: startLocation)
        
        self.padBackground.position = CGPoint(x: startLocation.x, y: startLocation.y)
        self.stick.position = CGPoint(x: self.startLocation.x, y: self.startLocation.y)
        
        updateStickPosition()
    }
    
    func checkSafeArea(position: CGPoint) -> CGPoint {
        var positionSafe = position
        let margin: CGFloat = 20
        
        if(position.x < self.lowerXSafeArea) {
            positionSafe.x = (self.lowerXSafeArea - self.padSize.width / 2) + margin
        }
        
        if(position.x > self.higherXSafeArea) {
            positionSafe.x = self.higherXSafeArea
        }
        
        if(position.y < self.lowerYSafeArea) {
            positionSafe.y = (self.lowerYSafeArea - self.padSize.height / 2) + margin
        }
        
        if(position.y > self.higherYSafeArea) {
            positionSafe.y = self.higherYSafeArea - margin
        }
        
        return positionSafe
    }
    
    func destroyPad() {
        
        self.padBackground.alpha = 0
        
        self.delegate?.padOverlayVirtualStickInteractionDidEnd(self)
    }
    
    var stickSize: CGSize {
        return CGSize( width: padSize.width / 3.0, height: padSize.height / 3.0)
    }

    func updateForSizeChange() {

        stick.size = self.stickSize

    }

    func updateStickPosition() {
        let stickSize: CGSize = self.stickSize
        let stickX = padSize.width / 2.0 - stickSize.width / 2.0 + padSize.width / 2.0 * stickPosition.x
        let stickY = padSize.height / 2.0 - stickSize.height / 2.0 + padSize.width / 2.0 * stickPosition.y
        stick.position = CGPoint(x: stickX, y: stickY)
    }

    func updateStickPosition(forTouchLocation location: CGPoint)
    {
        var l_vec = vector_float2( x: Float( location.x - startLocation.x ), y: Float( location.y - startLocation.y ) )
        
        l_vec.x = (l_vec.x / Float( padSize.width ) - 0.5) * 2.0
        l_vec.y = (l_vec.y / Float( padSize.height ) - 0.5) * 2.0
        if simd_length_squared(l_vec) > 1 {
            l_vec = simd_normalize(l_vec)
        }
        stickPosition = CGPoint( x: CGFloat( l_vec.x ), y: CGFloat( l_vec.y ) )
    }
    
    func getAngle(p1:CGPoint, p2:CGPoint) -> CGFloat {
        let deltaY = p2.y - p1.y
        let deltaX = p2.x - p1.x
        
        let angle = Float(atan2(deltaY, deltaX))
        
        return CGFloat(angle * (180.0 / Float.pi))
    }
    
    func updatePadPosition(to point: CGPoint) {
        
        let padPosition = self.padBackground.position
        var newPosition = CGPoint()
        
        if point.x > padPosition.x + padSize.width {
            newPosition.x = point.x - padSize.width
        }
        else {
            newPosition.x = point.x
        }
        
        if point.y > padPosition.y + padSize.height {
            newPosition.y = point.y - padSize.height
        }
        else {
            newPosition.y = point.y
        }
        
        startLocation = checkSafeArea(position: newPosition)
        
        //let moveAnimation = SKAction.move(to: startLocation, duration: 0.1)
        //self.padBackground.run(moveAnimation)
        
        self.padBackground.position = startLocation
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isPausedControl {
            trackingTouch = touches.first
            startLocation = trackingTouch!.location(in: self)
            startLocation.x -= self.padSize.width / 2
            startLocation.y -= self.padSize.height / 2
            self.buildPad()
            updateStickPosition(forTouchLocation: trackingTouch!.location(in: self))
            delegate?.padOverlayVirtualStickInteractionDidStart(self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isPausedControl {
            if(touches.count > 1) {
                return
            }
            if touches.contains(trackingTouch!) {
                let location = trackingTouch!.location(in: self)
                updateStickPosition(forTouchLocation: location)
                delegate?.padOverlayVirtualStickInteractionDidChange(self)
                
                
                //TODO
                if !self.padBackground.contains(location) {
                   // self.updatePadPosition(to: location)
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.destroyPad()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.contains(trackingTouch!) {
            self.destroyPad()
            self.delegate?.padOverlayVirtualStickInteractionDidEnd(self)
        }
    }
}
