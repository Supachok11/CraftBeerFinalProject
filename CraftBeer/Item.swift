//
//  Item.swift
//  CraftBeer
//
//  Created by Supachok Chatupamai on 29/4/2568 BE.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
