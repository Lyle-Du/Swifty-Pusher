//
//  Data+Base64EncodedURLString.swift
//  Swifty Pusher
//
//  Created by QIU DU on 6/4/22.
//

import Foundation

extension Data {
    
    func base64EncodedURLString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
