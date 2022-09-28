//
//  JSONWebTokenTests.swift
//  Swifty PusherTests
//
//  Created by QIU DU on 29/9/22.
//

import XCTest

@testable import Swifty_Pusher

final class JSONWebTokenTests: XCTestCase {
    
    func testJsonWebTokenGenerateNewTokenFailed_givenTheIssueDateIsExceeding30Minutes_andInvalidASN1() throws {
        let keyID = "keyID"
        let teamID = "teamID"
        let url = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "test", ofType: "p8")!)
        let data = try Data(contentsOf: url)
        let p8Payload = try XCTUnwrap(P8Payload(data.base64EncodedString()))
        let userDefault = UserDefaults()
        userDefault.set(Int(Date(timeIntervalSince1970: .zero).timeIntervalSince1970), forKey: "\(keyID).\(teamID).requestedDate")
        userDefault.set("oldToken", forKey: "\(keyID).\(teamID).tokenKey")
        XCTAssertThrowsError(try JSONWebToken(
            keyID: keyID,
            teamID: teamID,
            issueDate: Date(timeIntervalSince1970: 30*60 + 1),
            p8Payload: p8Payload,
            userDefaults: userDefault))
        { error in
            XCTAssertEqual(error as? JSONWebTokenError, .invalidASN1)
        }
    }
    
    func testJsonWebTokenUsesStoredToken_givenTheIssueDateIsWithin30Minutes() throws {
        let keyID = "keyID"
        let teamID = "teamID"
        let url = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "test", ofType: "p8")!)
        let data = try Data(contentsOf: url)
        let p8Payload = try XCTUnwrap(P8Payload(data.base64EncodedString()))
        let userDefault = UserDefaults()
        userDefault.set(Int(Date(timeIntervalSince1970: .zero).timeIntervalSince1970), forKey: "\(keyID).\(teamID).requestedDate")
        userDefault.set("oldToken", forKey: "\(keyID).\(teamID).tokenKey")
        let jsonWebToken = try JSONWebToken(
            keyID: keyID,
            teamID: teamID,
            issueDate: Date(timeIntervalSince1970: 30*60),
            p8Payload: p8Payload,
            userDefaults: userDefault)
        XCTAssertEqual(jsonWebToken.token, "oldToken")
    }
}
