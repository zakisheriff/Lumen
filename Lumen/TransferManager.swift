//
//  TransferManager.swift
//  Lumen
//
//  Created by Zaki Sheriff on 2025-11-25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TransferManager: ObservableObject {
    @Published var isTransferring = false
    @Published var progress: Double = 0
    @Published var status: String = ""
    @Published var filename: String = ""
    
    private var currentTask: Task<Void, Never>?
    
    func startTransfer(item: ClipboardItem, to destService: FileService, at destPath: String) {
        guard !isTransferring else { return }
        
        isTransferring = true
        filename = item.item.name
        progress = 0
        status = "Preparing..."
        
        currentTask = Task {
            do {
                // Determine transfer type
                if item.sourceService is LocalFileService && destService is MTPService {
                    // Mac -> Android (Upload)
                    let sourceURL = URL(fileURLWithPath: item.item.path)
                    try await destService.uploadFile(from: sourceURL, to: destPath) { progress, status in
                        Task { @MainActor in
                            self.progress = progress
                            self.status = status
                        }
                    }
                } else if item.sourceService is MTPService && destService is LocalFileService {
                    // Android -> Mac (Download)
                    let destURL = URL(fileURLWithPath: destPath).appendingPathComponent(item.item.name)
                    try await item.sourceService.downloadFile(at: item.item.path, to: destURL, size: item.item.size) { progress, status in
                        Task { @MainActor in
                            self.progress = progress
                            self.status = status
                        }
                    }
                } else if item.sourceService is LocalFileService && destService is LocalFileService {
                     // Mac -> Mac (Local Copy)
                    let destURL = URL(fileURLWithPath: destPath).appendingPathComponent(item.item.name)
                    try await (item.sourceService as! LocalFileService).downloadFile(at: item.item.path, to: destURL, size: item.item.size) { progress, status in
                         Task { @MainActor in
                            self.progress = progress
                            self.status = status
                        }
                    }
                } else {
                    // Android -> Android (Not supported yet)
                    self.status = "Direct Android-to-Android transfer not supported"
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                }
                
                self.isTransferring = false
                self.status = "Done"
                
            } catch {
                self.isTransferring = false
                self.status = "Error: \(error.localizedDescription)"
                print("Transfer error: \(error)")
            }
        }
    }
    
    func cancel() {
        currentTask?.cancel()
        isTransferring = false
        status = "Cancelled"
    }
}
