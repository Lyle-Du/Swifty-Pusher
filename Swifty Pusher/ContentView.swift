//
//  ContentView.swift
//  Swifty Pusher
//
//  Created by QIU DU on 7/4/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    private let titleWidth = CGFloat(100)
    private let titleAlignment = Alignment.trailing
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Group {
                makeTextField(viewModel.teamIDTitle, $viewModel.teamID, viewModel.teamIDHint)
                makeTextField(viewModel.bundleIDTitle, $viewModel.bundleID, viewModel.bundleIDHint)
                
                HStack {
                    makeTextField(viewModel.keyIDTitle, $viewModel.keyID, viewModel.keyIDHint)
                    Button(action: { viewModel.loadKey() }) {
                        HStack {
                            Text(viewModel.indicator).foregroundColor(viewModel.importKeyButtonIndicatorColor)
                            Text(viewModel.importKeyButtonTitle)
                        }
                    }
                }
                
                makeTextField(viewModel.deviceTokenTitle, $viewModel.deviceToken, viewModel.deviceTokenHint)
                
                Divider()
                
                Form {
                    Picker(viewModel.apnsTitle, selection: $viewModel.selectedAPNServer) {
                        ForEach(ApplePushNotificationServer.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker(viewModel.apnsPriorityTitle, selection: $viewModel.selectedAPNSPriority) {
                        ForEach(APNSPriority.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                    
                    HStack {
                        Picker(viewModel.apnsPushTypeTitle, selection: $viewModel.selectedAPNSPushType) {
                            ForEach(APNSPushType.allCases, id: \.self) {
                                Text($0.title)
                            }
                        }
                        
                        Button(viewModel.pushTypeTemplateButtonTitle) {
                            viewModel.loadPayload()
                        }
                    }
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.payloadTitle).frame(alignment: .leading)
                    Spacer()
                    Button(action: { viewModel.push() }) {
                        HStack{
                            Text(viewModel.indicator)
                                .foregroundColor(viewModel.notificationIndicatorColor)
                            Text(viewModel.pushButtonTitle)
                        }
                    }
                }
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.payload)
                }
            }
            
            Divider()
            
            ScrollView {
                Text(viewModel.debugMessage)
                    .font(.footnote)
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxHeight: 100, alignment: .topLeading)
        }
        .frame(width: 400, height: 600, alignment: .top)
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification), perform: { _ in
            NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
        })
    }
}

private extension ContentView {
    
    func makeTextField(_ title: String, _ text: Binding<String>, _ prompt: String) -> some View {
        HStack {
            Text(title).frame(width: titleWidth, alignment: titleAlignment)
            TextField(prompt, text: text)
        }
    }
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}
