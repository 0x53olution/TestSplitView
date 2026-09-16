//
//  SettingSplitView.swift
//  TestSplitView
//
//  Created by Stephan Goergens on 20.08.26.
//

import SwiftUI

struct SettingSplitView: View {
    @StateObject private var settings = AppSettings()

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
            List {
                NavigationLink(destination: General(settings: settings)) {
                    Label("General", systemImage: "gear")
                }
                NavigationLink(destination: MouseMover(settings: settings)) {
                    Label("Mouse Mover", systemImage: "cursorarrow.motionlines")
                }
                NavigationLink(destination: Clipboard(settings: settings)) {
                    Label("Clipboard", systemImage: "clipboard")
                }
            }
            .padding(.top)
            .frame(width: 215)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            General(settings: settings)
                .navigationTitle("Settings")
        }
        .frame(minWidth: 715, maxWidth: 715, minHeight: 470, maxHeight: .infinity)
    }
}

struct General: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        ScrollView {
            GroupBox {
                VStack {
                    HStack {
                        Text("Launch at LogIn")
                        Spacer()
                        Toggle("", isOn: $settings.launchAtLogin)
                            .toggleStyle(.switch)
                    }
                }
                .padding(4)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
    }
}

struct MouseMover: View {
    @ObservedObject var settings: AppSettings

    @State private var selectedID: TimeSpan.ID?
    @State private var isShowingAddSheet = false
    @State private var newDurationText = ""
    
    var body: some View {
        ScrollView {
            VStack {
                GroupBox {
                    VStack {
                        HStack {
                            Text("Randomizer active")
                            Spacer()
                            Toggle("", isOn: $settings.mouseMoverEnabled)
                                .toggleStyle(.switch)
                        }
                    }
                    .padding(4)
                }
                .padding(.horizontal)
                .padding(.bottom)
                GroupBox {
                    VStack(spacing: 0) {
                        // Gemeinsamer Container für Tabelle und Buttons
                        VStack(spacing: 0) {
                            // 1. Die Tabelle (ohne eigene Rundung/Rahmen)
                            Table(settings.timeSpans, selection: $selectedID) {
                                TableColumn("Time Span") { item in
                                    Text(item.duration, format: .number)
                                }
                            }
                            .frame(minHeight: 160)
                            
                            Divider() // Trennlinie zwischen Tabelle und Buttons
                            
                            // 2. Die Button-Leiste als "letzte Zeile"
                            HStack(spacing: 0) {
                                Button {
                                    newDurationText = ""
                                    isShowingAddSheet = true
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.secondary)
                                        .frame(width: 28, height: 22)
                                }
                                .buttonStyle(.plain)
                                
                                Divider()
                                    .frame(height: 12)
                                
                                Button {
                                    guard let selectedID else { return }
                                    settings.removeTimeSpan(id: selectedID)
                                    self.selectedID = nil
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundColor(.secondary)
                                        .frame(width: 28, height: 22)
                                }
                                .buttonStyle(.plain)
                                .disabled(selectedID == nil)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            .frame(height: 24)
                            .background(Color(NSColor.controlBackgroundColor)) // Nutzt die native Tabellen-Hintergrundfarbe
                        }
                        // Hier wird die gesamte Einheit gerundet und umrandet
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(4)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .sheet(isPresented: $isShowingAddSheet) {
            VStack(alignment: .leading, spacing: 12) {
                Text("New Time Span")
                    .font(.headline)

                TextField("Value in seconds", text: $newDurationText)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Spacer()

                    Button("Cancel") {
                        isShowingAddSheet = false
                    }

                    Button("Add") {
                        guard let value = Int(newDurationText.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 else {
                            return
                        }
                        if let newItem = settings.addTimeSpan(value) {
                            selectedID = newItem.id
                        }
                        isShowingAddSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(Int(newDurationText.trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
                }
            }
            .padding(16)
            .frame(width: 320)
        }
    }
}

struct Clipboard: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        ScrollView {
            GroupBox {
                VStack {
                    HStack {
                        Text("Transparent Click-Through")
                        Spacer()
                        Toggle("", isOn: $settings.usePopUpWindow)
                            .toggleStyle(.switch)
                    }
                }
                .padding(4)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
    }
}

#Preview {
    SettingSplitView()
}
