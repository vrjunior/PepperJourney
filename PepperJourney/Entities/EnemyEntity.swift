//
//  EnemyEntity.swift
//  PepperJourney
//
//  Created by Valmir Junior on 12/12/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//

import Foundation
import GameKit

protocol EnemyEntity {
    func killEnemy()
    func getEnemyNode() -> SCNNode
    func getEntity() -> GKEntity
    func attack()
}
