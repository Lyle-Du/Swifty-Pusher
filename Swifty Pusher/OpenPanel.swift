//
//  OpenPanel.swift
//  Swifty Pusher
//
//  Created by QIU DU on 8/4/22.
//

import SwiftUI
import UniformTypeIdentifiers

protocol OpenPanel: AnyObject {
    var url: URL? { get }
    var allowsMultipleSelection: Bool { get set }
    var canChooseDirectories: Bool { get set }
    var allowedContentTypes: [UTType] { get set }
    func runModal() -> NSApplication.ModalResponse
}

extension NSOpenPanel: OpenPanel {}
