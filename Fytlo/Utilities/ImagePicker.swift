//
//  ImagePicker.swift
//  fytloapp
//
//  Created by Victor Jr on 12/17/25.
//
//  Privacy (Info.plist) reminders:
//  - NSCameraUsageDescription
//  - NSPhotoLibraryUsageDescription
//  - (Optional for saving) NSPhotoLibraryAddUsageDescription
//

import SwiftUI
import UIKit

// MARK: - ImagePicker

struct ImagePicker: UIViewControllerRepresentable {
    enum Source {
        case camera
        case photoLibrary

        var uiKitSourceType: UIImagePickerController.SourceType {
            switch self {
            case .camera: return .camera
            case .photoLibrary: return .photoLibrary
            }
        }
    }

    let source: Source
    @Binding var image: UIImage?

    var onError: ((String) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false

        // Camera availability guard (simulator-safe)
        let type = source.uiKitSourceType
        if type == .camera, !UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Present an empty picker; immediately dismiss and report error.
            DispatchQueue.main.async {
                onError?("Camera is not available on this device.")
                dismiss()
            }
            return picker
        }

        picker.sourceType = type
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let picked = info[.originalImage] as? UIImage {
                parent.image = picked
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Cancel: do not modify binding
            parent.dismiss()
        }
    }
}
