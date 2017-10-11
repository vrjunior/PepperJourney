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
    private var startLocationCenter = CGPoint.zero
    private var stick: SKShapeNode!
    
    private var background: SKShapeNode!
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.padSize = CGSize(width: 40, height: 40)
        
        alpha = 0.7
        isUserInteractionEnabled = true
    }
    
    
    func buildPad() {
        
        let backgroundRect = CGRect(x: CGFloat(self.startLocationCenter.x), y: CGFloat(self.startLocationCenter.y), width: CGFloat(padSize.width), height: CGFloat(padSize.height))
        
        background = SKShapeNode()
        background.path = CGPath( ellipseIn: backgroundRect, transform: nil )
        background.strokeColor = SKColor.black
        background.lineWidth = 1
        
        self.addChild(background)
        var stickRect = CGRect(x: CGFloat(self.startLocationCenter.x), y: CGFloat(self.startLocationCenter.y), width: CGFloat(stickSize.width), height: CGFloat(stickSize.height))
        stickRect.size = stickSize
        stick = SKShapeNode()
        stick.path = CGPath( ellipseIn: stickRect, transform: nil)
        stick.lineWidth = 0.75
        //#if os( OSX )
        stick.fillColor = SKColor.white
        //#endif
        stick.strokeColor = SKColor.black
        self.addChild(stick)
        updateStickPosition()
    }
    
    func destroyPad() {
        self.background.removeFromParent()
        self.stick.removeFromParent()
    }
    
    var stickSize: CGSize {
        return CGSize( width: padSize.width / 3.0, height: padSize.height / 3.0)
    }

    func updateForSizeChange() {
        guard let background = background else { return }

        let backgroundRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(padSize.width), height: CGFloat(padSize.height))
        background.path = CGPath( ellipseIn: backgroundRect, transform: nil)
        let stickRect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(padSize.width / 3.0), height: CGFloat(padSize.height / 3.0))
        stick.path = CGPath( ellipseIn: stickRect, transform: nil)
    }

    func updateStickPosition() {
        let stickSize: CGSize = self.stickSize
        let stickX = padSize.width / 2.0 - stickSize.width / 2.0 + padSize.width / 2.0 * stickPosition.x
        let stickY = padSize.height / 2.0 - stickSize.height / 2.0 + padSize.width / 2.0 * stickPosition.y
        stick.position = CGPoint(x: stickX, y: stickY)
    }

    func updateStickPosition(forTouchLocation location: CGPoint) {
        var l_vec = vector_float2( x: Float( location.x - startLocationCenter.x ), y: Float( location.y - startLocationCenter.y ) )
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
        if(touches.count != 1) {
            return
        }
        trackingTouch = touches.first
        startLocation = trackingTouch!.location(in: self)
        // Center start location
        self.startLocationCenter.x = startLocation.x - padSize.width / 2.0
        self.startLocationCenter.y = startLocation.y - padSize.height / 2.0
        updateStickPosition(forTouchLocation: trackingTouch!.location(in: self))
        self.buildPad()
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
        if touches.contains(trackingTouch!) {
            self.resetInteraction()
            self.destroyPad()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.contains(trackingTouch!) {
            self.resetInteraction()
            self.destroyPad()
        }
    }
}
