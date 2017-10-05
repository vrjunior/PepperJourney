import Foundation
import SpriteKit
import CoreGraphics

class TouchJoystick : SKNode {
    let kThumbSpringBackDuration: Double =  0.3
    let backdropNode, thumbNode: SKSpriteNode
    var isTracking: Bool = false
    var velocity: CGPoint = CGPoint()
    var travelLimit: CGPoint = CGPoint()
    var angularVelocity: CGFloat = 0.0
    var size: Float = 0.0
    
    func anchorPointInPoints() -> CGPoint {
        return CGPoint()
    }
    
    init(thumbNode: SKSpriteNode = SKSpriteNode(imageNamed: "joystick.png"), backdropNode: SKSpriteNode = SKSpriteNode(imageNamed: "dpad.png")) {
        self.thumbNode = thumbNode
        self.backdropNode = backdropNode
        
        super.init()
        
        self.addChild(self.backdropNode)
        self.addChild(self.thumbNode)
        
        self.isUserInteractionEnabled = true
                
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.location(in: self)
            if (!self.isTracking && self.thumbNode.frame.contains(touchPoint)) {
                self.isTracking = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.location(in: self)
            
            if self.isTracking && sqrtf(powf((Float(touchPoint.x) - Float(self.thumbNode.position.x)), 2) + powf((Float(touchPoint.y) - Float(self.thumbNode.position.y)), 2)) < Float(self.thumbNode.size.width) {
                if sqrtf(powf((Float(touchPoint.x) - Float(self.anchorPointInPoints().x)), 2) + powf((Float(touchPoint.y) - Float(self.anchorPointInPoints().y)), 2)) <= Float(self.thumbNode.size.width) {
                    let moveDifference: CGPoint = CGPoint(x: touchPoint.x - self.anchorPointInPoints().x, y: touchPoint.y - self.anchorPointInPoints().y)
                    self.thumbNode.position = CGPoint(x: self.anchorPointInPoints().x + moveDifference.x, y: self.anchorPointInPoints().y + moveDifference.y)
                } else {
                    let vX: Double = Double(touchPoint.x) - Double(self.anchorPointInPoints().x)
                    let vY: Double = Double(touchPoint.y) - Double(self.anchorPointInPoints().y)
                    let magV: Double = sqrt(vX*vX + vY*vY)
                    let aX: Double = Double(self.anchorPointInPoints().x) + vX / magV * Double(self.thumbNode.size.width)
                    let aY: Double = Double(self.anchorPointInPoints().y) + vY / magV * Double(self.thumbNode.size.width)
                    self.thumbNode.position = CGPoint(x: CGFloat(aX), y: CGFloat(aY))
                }
            }
            self.velocity = CGPoint(x: ((self.thumbNode.position.x - self.anchorPointInPoints().x)), y: ((self.thumbNode.position.y - self.anchorPointInPoints().y)))
            self.angularVelocity = -atan2(self.thumbNode.position.x - self.anchorPointInPoints().x, self.thumbNode.position.y - self.anchorPointInPoints().y)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resetVelocity()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resetVelocity()
    }

    func resetVelocity() {
        self.isTracking = false
        self.velocity = CGPoint.zero
        let easeOut: SKAction = SKAction.move(to: self.anchorPointInPoints(), duration: kThumbSpringBackDuration)
        easeOut.timingMode = SKActionTimingMode.easeOut
        self.thumbNode.run(easeOut)
    }
}
