//
//  ViewModel.swift
//  Swifty Pusher
//
//  Created by QIU DU on 6/4/22.
//

import Foundation

import SwiftUI
import UniformTypeIdentifiers

final class ViewModel: ObservableObject {
    
    let teamIDTitle = "Team ID"
    let bundleIDTitle = "Bundle ID"
    let keyIDTitle = "Key ID"
    let indicator = "●"
    let importKeyButtonTitle = "Import Key (*.p8)"
    let payloadTitle = "Payload"
    let apnsTitle = "APN Server"
    let apnsPriorityTitle = "APNs Priority"
    let apnsPushTypeTitle = "Push Type"
    let pushTypeTemplateButtonTitle = "Load Template"
    let deviceTokenTitle = "Device Token"
    let pushButtonTitle = "Push Notification"
    
    let teamIDHint = "10 Characters Team ID"
    let bundleIDHint = "com.example.app"
    let keyIDHint = "10 Characters Key ID"
    let deviceTokenHint = "Unique Device Token"
    
    @Published var importKeyButtonIndicatorColor: Color = .red
    @Published var notificationIndicatorColor: Color = .gray
    @Published var teamID: String {
        didSet {
            userDefaults.set(teamID, forKey: StoreKey.teamID)
        }
    }
    @Published var bundleID: String {
        didSet {
            userDefaults.set(bundleID, forKey: StoreKey.bundleID)
        }
    }
    @Published var keyID: String {
        didSet {
            userDefaults.set(keyID, forKey: StoreKey.keyID)
        }
    }
    @Published var deviceToken: String {
        didSet {
            userDefaults.set(deviceToken, forKey: StoreKey.deviceToken)
        }
    }
    @Published var selectedAPNServer: ApplePushNotificationServer {
        didSet {
            userDefaults.set(selectedAPNServer.rawValue, forKey: StoreKey.selectedAPNs)
        }
    }
    @Published var selectedAPNSPriority: APNSPriority {
        didSet {
            if selectedAPNSPriority == .high {
                if selectedAPNSPushType == .background {
                    selectedAPNSPushType = .alert
                }
            }
            userDefaults.set(selectedAPNSPriority.rawValue, forKey: StoreKey.selectedAPNSPriority)
        }
    }
    @Published var selectedAPNSPushType: APNSPushType {
        didSet {
            if selectedAPNSPushType == .background {
                selectedAPNSPriority = .low
            }
            payload = selectedAPNSPushType.template
            userDefaults.set(selectedAPNSPushType.rawValue, forKey: StoreKey.selectedAPNSPushType)
        }
    }
    @Published var payload = ""
    @Published var debugMessage = ""
    
    private var keyURL: URL? {
        didSet {
            userDefaults.set(keyURL, forKey: StoreKey.keyURL)
        }
    }
    private var p8Payload: P8Payload? {
        didSet {
            updateIndicatorColor()
        }
    }
    private let panel: OpenPanel
    private let session: URLSession
    private let userDefaults: UserDefaults
    private let dispatchQueue: DispatchQueue
    private let encoder = JSONEncoder()
    private var apnsID: String?
    
    init(
        panel: OpenPanel = NSOpenPanel(),
        session: URLSession = URLSession.shared,
        userDefaults: UserDefaults = UserDefaults.standard,
        dispatchQueue: DispatchQueue = DispatchQueue.main)
    {
        self.panel = panel
        self.session = session
        self.userDefaults = userDefaults
        self.dispatchQueue = dispatchQueue
        
        teamID = userDefaults.string(forKey: StoreKey.teamID) ?? ""
        bundleID = userDefaults.string(forKey: StoreKey.bundleID) ?? ""
        keyID = userDefaults.string(forKey: StoreKey.keyID) ?? ""
        keyURL = userDefaults.url(forKey: StoreKey.keyURL)
        deviceToken = userDefaults.string(forKey: StoreKey.deviceToken) ?? ""
        if let selectedAPNsRawValue = userDefaults.string(forKey: StoreKey.selectedAPNs) {
            selectedAPNServer = ApplePushNotificationServer(rawValue: selectedAPNsRawValue) ?? .sandbox
        } else {
            selectedAPNServer = .sandbox
        }
        
        let selectedAPNSPriorityRawValue = userDefaults.integer(forKey: StoreKey.selectedAPNSPriority)
        selectedAPNSPriority = APNSPriority(rawValue: selectedAPNSPriorityRawValue) ?? .high
        
        if let selectedAPNSPushTypeRawValue = userDefaults.string(forKey: StoreKey.selectedAPNSPushType) {
            selectedAPNSPushType = APNSPushType(rawValue: selectedAPNSPushTypeRawValue) ?? .alert
        } else {
            selectedAPNSPushType = .alert
        }
        
        p8Payload = P8Parser.parse(url: keyURL)
        updateIndicatorColor()
        loadPayload()
        
        self.panel.allowsMultipleSelection = false
        self.panel.canChooseDirectories = false
        guard let fileType = UTType(filenameExtension: "p8", conformingTo: .data) else { return }
        self.panel.allowedContentTypes = [fileType]
    }
    
    func loadKey() {
        if panel.runModal() == .OK, let url = panel.url {
            keyURL = url
            p8Payload = P8Parser.parse(url: url)
        }
    }
    
    func push() {
        guard let p8Payload = p8Payload else { return }
        
        do {
            let jsonWebToken = JSONWebToken(keyID: keyID, teamID: teamID, issueDate: Date())
            let authenticationToken = try jsonWebToken.sign(p8Payload)
            guard let request = selectedAPNServer.urlRequest(
                authenticationToken: authenticationToken,
                bundleID: bundleID,
                deviceToken: deviceToken,
                payload: payload,
                priority: selectedAPNSPriority,
                pushTye: selectedAPNSPushType,
                apnsID: apnsID) else
            {
                return
            }
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                var messages = [ error?.localizedDescription ]
                
                self.dispatchQueue.async {
                    guard error != nil else { return }
                    self.notificationIndicatorColor = .red
                }
                
                if let response = response as? HTTPURLResponse {
                    var description = response.description
                    let regex = try! NSRegularExpression(pattern: "<.*:.*x.*>", options: NSRegularExpression.Options.caseInsensitive)
                    let range = NSMakeRange(0, description.count)
                    description = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "Response:")
                    if let url = response.url {
                        messages.append("URL: \(url)")
                    }
                    
                    self.dispatchQueue.async {
                        self.notificationIndicatorColor = response.statusCode == 200 ? .green : .red
                    }
                    
                    messages.append("Status Code: \(response.statusCode) (\(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)))")
                    
                    if let allHeaderFields = response.allHeaderFields as? [String: String] {
                        messages.append("Header: \(allHeaderFields.description)")
                        self.apnsID = allHeaderFields["apns-id"]
                    }
                }
                
                if let data = data, let description = String(data: data, encoding: .utf8), !description.isEmpty {
                    messages.append("Payload: \(description)")
                }
                
                self.dispatchQueue.async {
                    self.debugMessage = messages.compactMap { $0 } .joined(separator: "\n")
                }
            }
            
            task.resume()
            
        } catch {
            debugMessage = error.localizedDescription
        }
    }
    
    func loadPayload() {
        payload = selectedAPNSPushType.template
    }
}

private extension ViewModel {
    
    func updateIndicatorColor() {
        if p8Payload == nil {
            importKeyButtonIndicatorColor = .red
        } else {
            importKeyButtonIndicatorColor = .green
        }
    }
}

private extension ViewModel {
    
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
}
