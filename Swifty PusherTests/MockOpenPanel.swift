//
//  MockOpenPanel.swift
//  Swifty PusherTests
//
//  Created by QIU DU on 8/4/22.
//

import SwiftUI
import UniformTypeIdentifiers

@testable import Swifty_Pusher

final class MockOpenPanel: OpenPanel {
    
    var stubModalResponse: NSApplication.ModalResponse = .cancel
    var stubRunModalHandler: (() -> Void)?
    
    var url: URL?
    var allowsMultipleSelection: Bool = true
    var canChooseDirectories: Bool = true
    var allowedContentTypes: [UTType] = []
    
    func runModal() -> NSApplication.ModalResponse {
        stubRunModalHandler?()
        return stubModalResponse
    }
}
