//
//  APNSPushType.swift
//  Swifty Pusher
//
//  Created by QIU DU on 7/4/22.
//

import Foundation

enum APNSPushType: String, CaseIterable {
    
    case alert
    case background
    case location
    case voip
    
    var title: String {
        rawValue.capitalized
    }
    
    var template: String {
        switch self {
        case .alert:
            return """
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
        case .background:
            return """
{
   "aps" : {
      "content-available" : 1
   },
   "acme1" : "bar",
   "acme2" : 42
}
"""
        case .location:
            return "Location"
        case .voip:
            return "VOIP identifier"
        }
    }
    
    func topic(bundleID: String) -> String {
        switch self {
        case .alert, .background:
            return bundleID
        case .location:
            return bundleID + ".location-query"
        case .voip:
            return bundleID + ".voip"
        }
    }
}

extension APNSPushType {
    static let typeKey = "apns-push-type"
    static let topicKey = "apns-topic"
}
