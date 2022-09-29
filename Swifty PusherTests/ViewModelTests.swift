//
//  Swifty_PusherTests.swift
//  Swifty PusherTests
//
//  Created by QIU DU on 7/4/22.
//

import Combine
import SwiftUI
import UniformTypeIdentifiers
import XCTest

import OHHTTPStubs
import OHHTTPStubsSwift

@testable import Swifty_Pusher

final class ViewModelTests: XCTestCase {
    
    private let panel = MockOpenPanel()
    private let session = URLSession.shared
    private let userDefaults = UserDefaults(suiteName: #file)!
    private let dispatchQueue = DispatchQueue.main
    private var cancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaults.removePersistentDomain(forName: #file)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        OHHTTPStubs.HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testStaticContent() throws {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.teamIDTitle, "Team ID")
        XCTAssertEqual(viewModel.bundleIDTitle, "Bundle ID")
        XCTAssertEqual(viewModel.keyIDTitle, "Key ID")
        XCTAssertEqual(viewModel.indicator, "●")
        XCTAssertEqual(viewModel.importKeyButtonTitle, "Import Key (*.p8)")
        XCTAssertEqual(viewModel.payloadTitle, "Payload")
        XCTAssertEqual(viewModel.apnsTitle, "APN Server")
        XCTAssertEqual(viewModel.apnsPriorityTitle, "APNs Priority")
        XCTAssertEqual(viewModel.apnsPushTypeTitle, "Push Type")
        XCTAssertEqual(viewModel.pushTypeTemplateButtonTitle, "Load Template")
        XCTAssertEqual(viewModel.deviceTokenTitle, "Device Token")
        XCTAssertEqual(viewModel.pushButtonTitle, "Push Notification")
        XCTAssertEqual(viewModel.teamIDHint, "10 Characters Team ID")
        XCTAssertEqual(viewModel.bundleIDHint, "com.example.app")
        XCTAssertEqual(viewModel.keyIDHint, "10 Characters Key ID")
        XCTAssertEqual(viewModel.deviceTokenHint, "Unique Device Token")
        XCTAssertEqual(viewModel.importKeyButtonIndicatorColor, .red)
        XCTAssertEqual(viewModel.notificationIndicatorColor, .gray)
    }
    
    func testDefaultValues_givenNoValuesStored() throws {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.teamID, "")
        XCTAssertEqual(viewModel.bundleID, "")
        XCTAssertEqual(viewModel.keyID, "")
        XCTAssertEqual(viewModel.deviceToken, "")
        XCTAssertEqual(viewModel.selectedAPNServer, .sandbox)
        XCTAssertEqual(viewModel.selectedAPNSPriority, .high)
        XCTAssertEqual(viewModel.selectedAPNSPushType, .alert)
    }
    
    func testInitialValuesEqualToStoredValues_givenValuesStored() throws {
        userDefaults.set("teamID_value", forKey: StoreKey.teamID)
        userDefaults.set("bundleID_value", forKey: StoreKey.bundleID)
        userDefaults.set("keyID_value", forKey: StoreKey.keyID)
        userDefaults.set("deviceToken_value", forKey: StoreKey.deviceToken)
        userDefaults.set("production", forKey: StoreKey.selectedAPNs)
        userDefaults.set(5, forKey: StoreKey.selectedAPNSPriority)
        userDefaults.set("background", forKey: StoreKey.selectedAPNSPushType)
        
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.teamID, "teamID_value")
        XCTAssertEqual(viewModel.bundleID, "bundleID_value")
        XCTAssertEqual(viewModel.keyID, "keyID_value")
        XCTAssertEqual(viewModel.deviceToken, "deviceToken_value")
        XCTAssertEqual(viewModel.selectedAPNServer, .production)
        XCTAssertEqual(viewModel.selectedAPNSPriority, .low)
        XCTAssertEqual(viewModel.selectedAPNSPushType, .background)
    }
    
    func testValuesStored_whenValuesUpdated() throws {
        let viewModel = makeViewModel()
        viewModel.teamID = "teamID_updated"
        XCTAssertEqual(userDefaults.string(forKey: StoreKey.teamID), "teamID_updated")
        viewModel.bundleID = "bundleID_updated"
        XCTAssertEqual(userDefaults.string(forKey: StoreKey.bundleID), "bundleID_updated")
        viewModel.keyID = "keyID_updated"
        XCTAssertEqual(userDefaults.string(forKey: StoreKey.keyID), "keyID_updated")
        viewModel.deviceToken = "deviceToken_updated"
        XCTAssertEqual(userDefaults.string(forKey: StoreKey.deviceToken), "deviceToken_updated")
        viewModel.selectedAPNServer = .production
        XCTAssertEqual(userDefaults.string(forKey: StoreKey.selectedAPNs), "production")
        viewModel.selectedAPNSPriority = .low
        XCTAssertEqual(userDefaults.integer(forKey: StoreKey.selectedAPNSPriority), 5)
        viewModel.selectedAPNSPushType = .background
        XCTAssertEqual(userDefaults.string(forKey: StoreKey.selectedAPNSPushType), "background")
    }
    
    func testPayload_givenSelectedAPNSPushTypeUpdated() throws {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.payload, Constants.alertPayload)
        viewModel.selectedAPNSPushType = .alert
        XCTAssertEqual(viewModel.payload, Constants.alertPayload)
        viewModel.selectedAPNSPushType = .background
        XCTAssertEqual(viewModel.payload, Constants.backgroundPayload)
        viewModel.selectedAPNSPushType = .location
        XCTAssertEqual(viewModel.payload, Constants.locationPayload)
        viewModel.selectedAPNSPushType = .voip
        XCTAssertEqual(viewModel.payload, Constants.voipPayload)
    }
    
    func testSelectedAPNSPriorityBecomesLow_whenSelectedAPNSPushTypeSetToBackground_givenSelectedAPNSPriorityIsHigh() throws {
        let viewModel = makeViewModel()
        viewModel.selectedAPNSPriority = .high
        viewModel.selectedAPNSPushType = .background
        XCTAssertEqual(viewModel.selectedAPNSPriority, .low)
    }
    
    func testSelectedAPNSPushTypeBecomesAlert_whenSelectedAPNSPrioritySetToBackground_givenSelectedAPNSPushTypeIsBackground() throws {
        let viewModel = makeViewModel()
        viewModel.selectedAPNSPushType = .background
        viewModel.selectedAPNSPriority = .high
        XCTAssertEqual(viewModel.selectedAPNSPushType, .alert)
    }
    
    func testOpenPanelProperty_givenViewModelInitialised() throws {
        let viewModel = makeViewModel()
        defer { _ = viewModel }
        XCTAssertFalse(panel.allowsMultipleSelection)
        XCTAssertFalse(panel.canChooseDirectories)
        let fileType = try XCTUnwrap(UTType(filenameExtension: "p8", conformingTo: .data))
        XCTAssertEqual(panel.allowedContentTypes, [fileType])
    }
    
    func testIndicatorColorIsGreen_whenLoadKeySuccess() throws {
        let expectation = expectation(description: #function)
        panel.url = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "test", ofType: "p8")!)
        panel.stubModalResponse = .OK
        panel.stubRunModalHandler = expectation.fulfill
        let viewModel = makeViewModel()
        viewModel.loadKey()
        XCTAssertEqual(viewModel.importKeyButtonIndicatorColor, .green)
        waitForExpectations(timeout: 0)
    }
    
    func testDebugMessage_givenPushNotificationSuccess() throws {
        let expectation = self.expectation(description: #function)
        let stub = stub(condition: isHost("api.sandbox.push.apple.com")) { request in
            XCTAssertEqual(request.url, URL(string: "https://api.sandbox.push.apple.com/3/device/test_deviceToken"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.allHTTPHeaderFields?[APNSPushType.typeKey], APNSPushType.alert.rawValue)
            XCTAssertEqual(request.allHTTPHeaderFields?[APNSPushType.topicKey], "test_bundleID")
            XCTAssertEqual(request.allHTTPHeaderFields?[APNSPriority.key], String(APNSPriority.high.rawValue))
            expectation.fulfill()
            return HTTPStubsResponse(
                data: "{\"key\" : \"value\"}".data(using: .utf8)!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"])
        }
        
        panel.url = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "test", ofType: "p8")!)
        panel.stubModalResponse = .OK
        let viewModel = makeViewModel()
        defer { _ = viewModel }
        viewModel.bundleID = "test_bundleID"
        viewModel.deviceToken = "test_deviceToken"
        viewModel.loadKey()
        viewModel.push()
        waitForExpectations(timeout: 0.1)
        
        addTeardownBlock {
            OHHTTPStubs.HTTPStubs.removeStub(stub)
        }
    }
    
    func testNotificationIndicatorColor_givenPushNotificationSuccess() throws {
        let requestExpectation = self.expectation(description: "request")
        let stub = stub(condition: isHost("api.sandbox.push.apple.com")) { request in
            requestExpectation.fulfill()
            return HTTPStubsResponse(
                data: "{\"key\" : \"value\"}".data(using: .utf8)!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"])
        }
        
        panel.url = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "test", ofType: "p8")!)
        panel.stubModalResponse = .OK
        let viewModel = makeViewModel()
        defer { _ = viewModel }
        
        let receivedColorExpectation = self.expectation(description: "received color")
        receivedColorExpectation.expectedFulfillmentCount = 3
        var receivedColor = [Color]()
        cancellable = viewModel.$notificationIndicatorColor
            .sink { color in
                receivedColorExpectation.fulfill()
                receivedColor.append(color)
            }
        
        viewModel.bundleID = "test_bundleID"
        viewModel.deviceToken = "test_deviceToken"
        viewModel.loadKey()
        viewModel.push()
        
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(receivedColor, [.gray, .yellow, .green])
        
        addTeardownBlock {
            OHHTTPStubs.HTTPStubs.removeStub(stub)
        }
    }
    
    func testNotificationIndicatorColor_givenPushNotificationFailed() throws {
        let requestExpectation = self.expectation(description: "request")
        let stub = stub(condition: isHost("api.sandbox.push.apple.com")) { request in
            requestExpectation.fulfill()
            return HTTPStubsResponse(
                data: "{\"key\" : \"value\"}".data(using: .utf8)!,
                statusCode: 429,
                headers: ["Content-Type":"application/json"])
        }
        
        panel.url = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "test", ofType: "p8")!)
        panel.stubModalResponse = .OK
        let viewModel = makeViewModel()
        defer { _ = viewModel }
        
        let receivedColorExpectation = self.expectation(description: "received color")
        receivedColorExpectation.expectedFulfillmentCount = 3
        var receivedColor = [Color]()
        cancellable = viewModel.$notificationIndicatorColor
            .sink { color in
                receivedColorExpectation.fulfill()
                receivedColor.append(color)
            }
        
        viewModel.bundleID = "test_bundleID"
        viewModel.deviceToken = "test_deviceToken"
        viewModel.loadKey()
        viewModel.push()
        
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(receivedColor, [.gray, .yellow, .red])
        
        addTeardownBlock {
            OHHTTPStubs.HTTPStubs.removeStub(stub)
        }
    }
}

private extension ViewModelTests {
    
    func makeViewModel() -> ViewModel {
        ViewModel(panel: panel, session: session, userDefaults: userDefaults, dispatchQueue: dispatchQueue)
    }
    
    struct StoreKey {
        static let teamID = "teamID"
        static let bundleID = "bundleID"
        static let keyID = "keyID"
        static let keyURL = "keyURL"
        static let deviceToken = "deviceToken"
        static let selectedAPNs = "selectedAPNs"
        static let selectedAPNSPriority = "selectedAPNSPriority"
        static let selectedAPNSPushType = "selectedAPNSPushType"
    }
    
    struct Constants {
        static let alertPayload = """
{
   "aps" : {
      "alert" : {
         "title" : "Notification Title",
         "subtitle" : "Notification subtitle",
         "body" : "This is the body of push notification :)"
      },
      "sound":"default"
   }
}
"""
        static let backgroundPayload = """
{
   "aps" : {
      "content-available" : 1
   },
   "acme1" : "bar",
   "acme2" : 42
}
"""
        static let locationPayload = "Location"
        static let voipPayload = "VOIP identifier"
    }
}
