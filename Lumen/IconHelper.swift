import AppKit
import SwiftUI

struct IconHelper {
    static func nativeIcon(for item: FileSystemItem) -> Image {
        let workspace = NSWorkspace.shared
        let nsImage: NSImage
        
        if item.isDirectory {
            // Get the system folder icon
            nsImage = workspace.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
        } else {
            // Get the system icon for the file extension
            let ext = (item.path as NSString).pathExtension
            nsImage = workspace.icon(forFileType: ext.isEmpty ? "public.data" : ext)
        }
        
        nsImage.size = NSSize(width: 128, height: 128) // Higher resolution for better quality
        return Image(nsImage: nsImage)
    }
    
    // Get color for file type (for styling)
    static func colorForType(_ type: FileType) -> [Color] {
        switch type {
        case .folder:
            return [.blue, .blue.opacity(0.7)]
        case .image:
            return [.blue, .cyan]
        case .video:
            return [.purple, .pink]
        case .audio:
            return [.orange, .red]
        case .document:
            return [.blue, .indigo]
        case .archive:
            return [.yellow, .orange]
        default:
            return [.gray, .gray.opacity(0.7)]
        }
    }
}