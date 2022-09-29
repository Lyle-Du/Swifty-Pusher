//
//  JSONWebToken.swift
//  Swifty Pusher
//
//  Created by QIU DU on 6/4/22.
//

import Foundation

struct JSONWebToken: Codable {
    
    let token: String
    
    private let header: Header
    private let claims: Claims

    init(
        keyID: String,
        teamID: String,
        issueDate: Date,
        p8Payload: P8Payload,
        userDefaults: UserDefaults = .standard) throws
    {
        header = Header(keyID: keyID)
        
        let requestedDateKey = "\(keyID).\(teamID).requestedDate"
        let oldDate = userDefaults.integer(forKey: requestedDateKey)
        let newDate = Int(issueDate.timeIntervalSince1970.rounded())
        
        let tokenKey = "\(keyID).\(teamID).tokenKey"
        
        let isExpired = newDate > (oldDate + 30*60)
        guard isExpired else {
            claims = Claims(teamID: teamID, issueDate: oldDate)
            guard let token = userDefaults.string(forKey: tokenKey) else {
                throw JSONWebTokenError.invalidToken
            }
            self.token = token
            return
        }
        
        claims = Claims(teamID: teamID, issueDate: newDate)
        let digest = try Self.digest(header: header, claims: claims)
        let ellipticCurveKey = try EllipticCurveKey(p8Payload).key
        let signature = try ellipticCurveKey.es256Sign(digest: digest)
        token = [digest, signature].joined(separator: ".")
        userDefaults.set(newDate, forKey: requestedDateKey)
        userDefaults.set(token, forKey: tokenKey)
    }
}

private extension JSONWebToken {
    
    static func digest(header: Header, claims: Claims) throws -> String {
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
    case digestDataCorruption, keyNotSupportES256Signing, invalidASN1, invalidP8, invalidToken
}
