//
//  TestSplitViewApp.swift
//  TestSplitView
//
//  Created by Stephan Goergens on 20.08.26.
//

import SwiftUI

@main
struct MeineApp: App {
    var body: some Scene {
        MenuBarExtra("Mac Helpers", systemImage: "wrench.and.screwdriver.fill") {
            MyContentView()
        }
        .menuBarExtraStyle(PullDownMenuBarExtraStyle())

        Settings {
            SettingSplitView()
        }
    }
}

struct MyContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Menu("UNC/smb Converter"){}
            Menu("Clipboard Manager"){}
            Menu("Mouse Mover"){}
            Divider()
            SettingsLink {
                Text("Settings")
            }
            .keyboardShortcut(",", modifiers: .command)
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding()
    }
}
