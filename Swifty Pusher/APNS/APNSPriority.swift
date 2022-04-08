//
//  APNSPriority.swift
//  Swifty Pusher
//
//  Created by QIU DU on 7/4/22.
//

import Foundation

enum APNSPriority: Int, CaseIterable {
    
    case low = 5
    case high = 10
    
    var title: String {
        String(rawValue)
    }
}

extension APNSPriority {
    static let key = "apns-priority"
}
