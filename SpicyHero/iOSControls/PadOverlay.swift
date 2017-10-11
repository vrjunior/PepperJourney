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
        
        self.checkSafeAreaForPad()
        
        self.padBackground.position = CGPoint(x: startLocation.x, y: startLocation.y)
        self.stick.position = CGPoint(x: self.startLocation.x, y: self.startLocation.y)
        
        updateStickPosition()
    }
    
    func checkSafeAreaForPad() {
        
        if(self.startLocation.x < self.lowerXSafeArea) {
            self.startLocation.x = self.lowerXSafeArea - self.padSize.width / 2
        }
        
        if(self.startLocation.x > self.higherXSafeArea) {
            startLocation.x = self.higherXSafeArea
        }
        
        if(self.startLocation.y < self.lowerYSafeArea) {
            self.startLocation.y = self.lowerYSafeArea - self.padSize.height / 2
        }
        
        if(self.startLocation.y > self.higherYSafeArea) {
            self.startLocation.y = self.higherYSafeArea
        }
        
    }
    
    func destroyPad() {
        
        self.padBackground.alpha = 0
        
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

    func resetInteraction() {
        stickPosition = CGPoint.zero
        trackingTouch = nil
        startLocation = CGPoint.zero
        delegate?.padOverlayVirtualStickInteractionDidEnd(self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        trackingTouch = touches.first
        startLocation = trackingTouch!.location(in: self)
        startLocation.x -= self.padSize.width / 2
        startLocation.y -= self.padSize.height / 2
        self.buildPad()
        updateStickPosition(forTouchLocation: trackingTouch!.location(in: self))
        delegate?.padOverlayVirtualStickInteractionDidStart(self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(touches.count > 1) {
            return
        }
        if touches.contains(trackingTouch!) {
            updateStickPosition(forTouchLocation: trackingTouch!.location(in: self))
            delegate?.padOverlayVirtualStickInteractionDidChange(self)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.destroyPad()
        self.delegate?.padOverlayVirtualStickInteractionDidEnd(self)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.contains(trackingTouch!) {
            self.resetInteraction()
            self.destroyPad()
        }
    }
}
