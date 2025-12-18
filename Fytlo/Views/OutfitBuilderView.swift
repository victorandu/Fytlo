//
//  OutfitBuilderView.swift
//  fytloapp
//
//  Created by Victor Jr on 12/17/25.
//
import SwiftUI
import UIKit

// MARK: - OutfitBuilderView

struct OutfitBuilderView: View {
    @ObservedObject var vm: AppViewModel

    @State private var activePicker: PickerTarget? = nil
    @State private var tempSelectedImage: UIImage? = nil

    private enum PickerTarget: Identifiable {
        case top
        case bottom

        var id: String {
            switch self {
            case .top: return "top"
            case .bottom: return "bottom"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    previewSection
                    garmentCardsSection
                    helperText
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }

            generateBar
        }
        .navigationTitle("Outfit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("New Photo") {
                    vm.goToBodyUpload()
                }
            }
        }
        .onAppear {
            if vm.resultImage != nil {
                vm.setPreview(.after)
            }
        }
        .onChange(of: vm.resultImage) { _, newValue in
            if newValue != nil {
                vm.setPreview(.after)
            }
        }
        .sheet(item: $activePicker) { _ in
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
            guard let target = activePicker else {
                tempSelectedImage = nil
                return
            }

            switch target {
            case .top:
                vm.requestSetTopImage(image)
            case .bottom:
                vm.requestSetBottomImage(image)
            }

            // Reset picker state
            tempSelectedImage = nil
            activePicker = nil
        }
    }

    // MARK: Preview

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Preview", selection: Binding(
                get: { vm.selectedPreview },
                set: { vm.setPreview($0) }
            )) {
                Text("Before").tag(AppViewModel.PreviewSelection.before)
                Text("After").tag(AppViewModel.PreviewSelection.after)
            }
            .pickerStyle(.segmented)
            .accessibilityLabel(Text("Before or After preview"))

            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))

                previewContent
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
        }
    }

    @ViewBuilder
    private var previewContent: some View {
        switch vm.selectedPreview {
        case .before:
            if let img = vm.bodyImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(Text("Before preview"))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text("No photo yet")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .accessibilityLabel(Text("No photo yet"))
            }

        case .after:
            if let img = vm.resultImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(Text("After preview"))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text("No result yet")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .accessibilityLabel(Text("No result yet"))
            }
        }
    }

    // MARK: Garment Cards

    private var garmentCardsSection: some View {
        VStack(spacing: 12) {
            GarmentSlotCard(
                slot: .top,
                image: vm.topImage,
                isLocked: vm.dirtySlot == .bottom,
                actionTitle: vm.topImage == nil ? "Upload" : "Change",
                onTap: {
                    activePicker = .top
                },
                onLockedTap: {
                    vm.showToast("One swap at a time. Change top or bottom, then generate.")
                }
            )

            GarmentSlotCard(
                slot: .bottom,
                image: vm.bottomImage,
                isLocked: vm.dirtySlot == .top,
                actionTitle: vm.bottomImage == nil ? "Upload" : "Change",
                onTap: {
                    activePicker = .bottom
                },
                onLockedTap: {
                    vm.showToast("One swap at a time. Change top or bottom, then generate.")
                }
            )
        }
    }

    private var helperText: some View {
        Text("You can start with just a top or just a bottom.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 2)
    }

    // MARK: Generate Bar

    private var generateBar: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                if vm.canGenerate {
                    vm.generate()
                } else {
                    vm.showToast("Add a top or bottom to generate.")
                }
            } label: {
                Text(vm.isGenerating ? "Generating…" : "Generate")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!vm.canGenerate)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OutfitBuilderView(vm: AppViewModel())
    }
}
