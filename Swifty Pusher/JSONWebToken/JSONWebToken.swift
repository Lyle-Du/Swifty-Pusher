//
//  JSONWebToken.swift
//  Swifty Pusher
//
//  Created by QIU DU on 6/4/22.
//

import Foundation

struct JSONWebToken: Codable {
    
    private let header: Header
    private let claims: Claims

    init(keyID: String, teamID: String, issueDate: Date) {
        header = Header(keyID: keyID)
        claims = Claims(teamID: teamID, issueDate: Int(issueDate.timeIntervalSince1970.rounded()))
    }

    func sign(_ payload: P8Payload) throws -> String {
        let digest = try self.digest()
        let ellipticCurveKey = try EllipticCurveKey(payload).key
        let signature = try ellipticCurveKey.es256Sign(digest: digest)
        return [digest, signature].joined(separator: ".")
    }
}

private extension JSONWebToken {
    
    func digest() throws -> String {
        let headerString = try JSONEncoder().encode(header.self).base64EncodedURLString()
        let claimsString = try JSONEncoder().encode(claims.self).base64EncodedURLString()
        return [headerString, claimsString].joined(separator: ".")
    }
}

private extension JSONWebToken {
    
    struct Header: Codable {
        
        let algorithm: String = "ES256"
        let keyID: String
        
        enum CodingKeys: String, CodingKey {
            case algorithm = "alg"
            case keyID = "kid"
        }
    }
    
    struct Claims: Codable {
        
        let teamID: String
        let issueDate: Int
        
        enum CodingKeys: String, CodingKey {
            case teamID = "iss"
            case issueDate = "iat"
        }
    }
}

enum JSONWebTokenError: Error {
    case digestDataCorruption, keyNotSupportES256Signing, invalidASN1, invalidP8
}
