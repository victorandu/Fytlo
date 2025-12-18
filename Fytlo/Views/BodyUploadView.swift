//
//  BodyUploadView.swift
//  FytloUI
//
//  Created by Fytlo.
//

import SwiftUI
import UIKit

// MARK: - BodyUploadView

struct BodyUploadView: View {
    @ObservedObject var vm: AppViewModel

    @State private var showCameraPicker = false
    @State private var showPhotoPicker = false
    @State private var tempSelectedImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 16) {
            previewArea

            VStack(spacing: 6) {
                Text("Full-body photo")
                    .font(.title3.weight(.semibold))

                Text("Head to shoes. Front-facing. Good light.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Button {
                    showCameraPicker = true
                } label: {
                    Text("Take photo")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showPhotoPicker = true
                } label: {
                    Text("Choose from Photos")
                        .font(.headline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)

            Button {
                guard vm.canContinueFromBodyUpload else {
                    vm.showToast("Add a full-body photo to continue.")
                    return
                }
                vm.goToOutfitBuilder()
            } label: {
                Text("Continue")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(!vm.canContinueFromBodyUpload)
            .opacity(vm.canContinueFromBodyUpload ? 1.0 : 0.5)
        }
        .padding(.top, 12)
        .navigationTitle("Full-body photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    vm.goToWelcome()
                }
                .font(.body)
            }
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(
                source: .camera,
                image: $tempSelectedImage,
                onError: { message in
                    vm.showToast(message)
                }
            )
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(
                source: .photoLibrary,
                image: $tempSelectedImage,
                onError: { message in
                    vm.showToast(message)
                }
            )
        }
        .onChange(of: tempSelectedImage) { _, newImage in
            guard let image = newImage else { return }

            vm.setBodyImage(image)

            if !vm.canContinueFromBodyUpload {
                // TODO: Replace with real full-body + blur checks once available
                vm.setBodyImage(nil)
                vm.showToast("Not full body. Step back and get head-to-shoes.")
            }

            tempSelectedImage = nil
        }
    }

    // MARK: Preview Area

    private var previewArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 320)

            if let image = vm.bodyImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.rectangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("No photo yet")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BodyUploadView(vm: AppViewModel())
    }
}
