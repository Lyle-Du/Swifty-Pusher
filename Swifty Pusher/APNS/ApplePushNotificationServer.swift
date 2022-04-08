//
//  ApplePushNotificationServer.swift
//  Swifty Pusher
//
//  Created by QIU DU on 6/4/22.
//

import Foundation

enum ApplePushNotificationServer: String, CaseIterable {
    
    case sandbox
    case production
    
    var title: String {
        rawValue.capitalized
    }
    
    func urlRequest(
        authenticationToken: String,
        bundleID: String,
        deviceToken: String,
        payload: String,
        priority: APNSPriority,
        pushTye: APNSPushType,
        apnsID: String?) -> URLRequest?
    {
        guard let url = urlComponents(deviceToken: deviceToken).url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("bearer \(authenticationToken)", forHTTPHeaderField: "authorization")
        request.setValue("\(pushTye.topic(bundleID: bundleID))", forHTTPHeaderField: APNSPushType.topicKey)
        request.setValue("\(priority.rawValue)", forHTTPHeaderField: APNSPriority.key)
        request.setValue("\(pushTye.rawValue)", forHTTPHeaderField: APNSPushType.typeKey)
        if let apnsID = apnsID {
            request.setValue(apnsID, forHTTPHeaderField: "apns-id")
        }
        
        request.httpBody = payload.data(using: .utf8)
        return request
    }
}

private extension ApplePushNotificationServer {
    
    var hostAddon: String? {
        switch self {
        case .sandbox:
            return rawValue
        case .production:
            return nil
        }
    }
    
    func urlComponents(deviceToken: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = ["api", hostAddon, "push.apple.com"]
            .compactMap { $0 }
            .joined(separator: ".")
        urlComponents.path = "/3/device/\(deviceToken)"
        return urlComponents
    }
}
