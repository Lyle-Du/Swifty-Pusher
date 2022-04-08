//
//  P8Parser.swift
//  Swifty Pusher
//
//  Created by QIU DU on 6/4/22.
//

import Foundation

struct P8Parser {
    
    /// Convert PEM format .p8 file to DER-encoded ASN.1 data
    static func parse(url: URL?) -> P8Payload? {
        guard
            let url = url,
            let content = try? String(contentsOf: url) else
        {
            return nil
        }
        
        let keyContent = content.split(separator: "\n")
            .filter { !($0.hasPrefix("-----") && $0.hasSuffix("-----")) }
            .joined(separator: "")
        
        return P8Payload(keyContent)
    }
}

struct P8Payload {
    
    let data: Data
    
    init?(_ base64Encoded: String) {
        guard let asn1 = Data(base64Encoded: base64Encoded) else {
            return nil
        }
        data = asn1
    }
}
