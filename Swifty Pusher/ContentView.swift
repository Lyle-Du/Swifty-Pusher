//
//  ContentView.swift
//  Swifty Pusher
//
//  Created by QIU DU on 7/4/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    private func makeTextField(_ title: String, _ text: Binding<String>, _ prompt: String) -> some View {
        guard #available(macOS 12.0, *) else {
            return AnyView(ZStack {
                if text.wrappedValue.isEmpty {
                    Text(prompt)
                        .frame(minWidth: .zero, maxWidth: .infinity ,alignment: .trailing)
                        .font(.system(size: 10))
                        .padding(.trailing, 8)
                        .foregroundColor(.gray)
                }
                TextField(title, text: text)
            })
        }
        return AnyView(TextField(title, text: text, prompt: Text(prompt)))
    }
    
    var body: some View {
        VStack {
            Form {
                
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
            
            ScrollView(.vertical) {
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

extension NSTextView {
  open override var frame: CGRect {
    didSet {
      backgroundColor = .clear
      drawsBackground = true
    }
  }
}
