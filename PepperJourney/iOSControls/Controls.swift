//
//  Controls.swift
//  PepperJourney
//
//  Created by Valmir Junior on 04/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import CoreGraphics

// Controls Protocol
protocol Controls : NSObjectProtocol {
    func padOverlayVirtualStickInteractionDidStart(_ padNode: PadOverlay)
    func padOverlayVirtualStickInteractionDidChange(_ padNode: PadOverlay)
    func padOverlayVirtualStickInteractionDidEnd(_ padNode: PadOverlay)
    func rotateCamera(angle: CGFloat)
    func jump()
    func attack()
}
