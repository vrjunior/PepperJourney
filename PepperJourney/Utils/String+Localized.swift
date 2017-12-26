//
//  String.swift
//  LocalCommerce
//
//  Created by vrjunior on 07/07/17.
//  Copyright © 2017 Valmir Junior. All rights reserved.
//
import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
