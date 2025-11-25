//
//  MainView.swift
//  Lumen
//
//  Created by Zaki Sheriff on 2025-11-25.
//

import SwiftUI
import AppKit

struct MainView: View {
    @State private var selectedCategory: String? = "local"
    @State private var clipboard: ClipboardItem?
    @StateObject private var transferManager = TransferManager()
    
    // Services
    let localService = LocalFileService()
    let remoteService: MTPService
    
    // AI Services
    @StateObject private var geminiService = GeminiService()
    @StateObject private var fileScanner: FileScanner
    
    @State private var showingAISearch = false
    
    init() {
        let mtp = MTPService()
        self.remoteService = mtp
        self._fileScanner = StateObject(wrappedValue: FileScanner(mtpService: mtp))
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory)
                .background(.ultraThinMaterial) // Native sidebar material
        } detail: {
            ZStack {
                HSplitView {
                    // Mac Pane - Real File System
                    FileBrowserView(
                        title: "Mac",
                        fileService: localService,
                        currentPath: FileManager.default.homeDirectoryForCurrentUser.path,
                        clipboard: $clipboard,
                        onPaste: { destPath in
                            transferManager.startTransfer(item: clipboard!, to: localService, at: destPath)
                        }
                    )
                    .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Android Pane - Real MTP Connection
                    FileBrowserView(
                        title: "Android",
                        fileService: remoteService,
                        currentPath: "mtp://", // Root MTP path
                        clipboard: $clipboard,
                        onPaste: { destPath in
                            transferManager.startTransfer(item: clipboard!, to: remoteService, at: destPath)
                        }
                    )
                    .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                
                if transferManager.isTransferring {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    TransferProgressView(
                        filename: transferManager.filename,
                        progress: transferManager.progress,
                        status: transferManager.status,
                        transferSpeed: transferManager.transferSpeed,
                        timeRemaining: transferManager.timeRemaining,
                        onCancel: {
                            transferManager.cancel()
                        }
                    )
                }
            }
            .background(.regularMaterial) // Main content glass effect
        }
        .frame(minWidth: 800, minHeight: 500)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // AI Search Button
                Button(action: { showingAISearch = true }) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.purple)
                }
                .help("AI Search")
                
                // Buy Me a Coffee button in toolbar
                BuyMeACoffeeButton {
                    openCoffeePurchaseURL()
                }
            }
        }
        .sheet(isPresented: $showingAISearch) {
            AISearchView(
                scanner: fileScanner,
                geminiService: geminiService,
                clipboard: $clipboard,
                onOpen: { file in
                    showingAISearch = false
                    if !file.isRemote {
                        NSWorkspace.shared.open(URL(fileURLWithPath: file.path))
                    }
                },
                onClose: {
                    showingAISearch = false
                }
            )
        }
    }
    
    private func openCoffeePurchaseURL() {
        #if DEBUG
        print("Opening Buy Me a Coffee URL...")
        #endif
        if let url = URL(string: "https://buymeacoffee.com/zakisherifw") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    MainView()
}