//
//  AppViewModel.swift
//  fytloapp
//
//  Created by Victor Jr on 12/17/25.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import Photos

// MARK: - AppViewModel

@MainActor
final class AppViewModel: ObservableObject {

    // MARK: Routes / UI State

    enum Route: Equatable {
        case welcome
        case bodyUpload
        case outfitBuilder
        case generating
    }

    enum DirtySlot: Equatable {
        case none
        case top
        case bottom
    }

    enum PreviewSelection: Equatable {
        case before
        case after
    }

    enum AutoSavePreference: Int, Equatable {
        case unknown = 0
        case enabled = 1
        case disabled = 2
    }

    struct Toast: Equatable {
        var toastId: UUID
        var message: String
        var isVisible: Bool
    }

    // MARK: Published State (locked contract)

    @Published var route: Route = .welcome

    @Published var bodyImage: UIImage? = nil
    @Published var topImage: UIImage? = nil
    @Published var bottomImage: UIImage? = nil
    @Published var resultImage: UIImage? = nil

    @Published var dirtySlot: DirtySlot = .none
    @Published var selectedPreview: PreviewSelection = .before

    @Published var isGenerating: Bool = false

    @Published var toast: Toast = Toast(toastId: UUID(), message: "", isVisible: false)

    // MARK: Auto-save preference + prompt

    @Published var autoSavePreference: AutoSavePreference = .unknown {
        didSet {
            UserDefaults.standard.set(autoSavePreference.rawValue, forKey: Self.autoSavePreferenceKey)
        }
    }

    @Published var showAutoSavePrompt: Bool = false

    // MARK: Internal

    private var toastTask: Task<Void, Never>? = nil

    private var generationTask: Task<Void, Never>? = nil
    private var currentGenerationId: UUID? = nil

    private let generatorDelayRange: ClosedRange<UInt64> = 2_000_000_000...3_000_000_000 // 2–3 seconds

    private static let autoSavePreferenceKey = "fytlo.autoSavePreference"

    // MARK: Init

    init() {
        let stored = UserDefaults.standard.object(forKey: Self.autoSavePreferenceKey) as? Int
        if let stored, let pref = AutoSavePreference(rawValue: stored) {
            self.autoSavePreference = pref
        } else {
            self.autoSavePreference = .unknown
        }
        self.showAutoSavePrompt = false
    }

    // MARK: Session Reset / Generation Cancellation

    private func cancelGenerationAndResetUI(nextRoute: Route) {
        generationTask?.cancel()
        generationTask = nil
        currentGenerationId = nil

        isGenerating = false
        route = nextRoute
    }

    private func resetSessionImages() {
        bodyImage = nil
        topImage = nil
        bottomImage = nil
        resultImage = nil
        dirtySlot = .none
        showAutoSavePrompt = false
        // Keep autoSavePreference; it's a user choice.
    }

    // MARK: Derived State

    var canContinueFromBodyUpload: Bool {
        guard let img = bodyImage else { return false }
        return passesStubFullBodyCheck(img)
    }

    var canGenerate: Bool {
        guard !isGenerating else { return false }
        guard bodyImage != nil else { return false }
        guard dirtySlot != .none else { return false }

        switch dirtySlot {
        case .top:
            return topImage != nil
        case .bottom:
            return bottomImage != nil
        case .none:
            return false
        }
    }

    // MARK: Navigation

    func goToWelcome() {
        cancelGenerationAndResetUI(nextRoute: .welcome)
        resetSessionImages()
        selectedPreview = .before
    }

    func goToBodyUpload() {
        cancelGenerationAndResetUI(nextRoute: .bodyUpload)
        // Keep body image if user is returning to re-check; do not purge by default.
        selectedPreview = .before
    }

    func goToOutfitBuilder() {
        // If a generation is in flight, do not silently cancel; just navigate.
        route = .outfitBuilder
        // Keep current preview; default is .before.
    }

    // MARK: Body Upload

    func setBodyImage(_ image: UIImage?) {
        cancelGenerationAndResetUI(nextRoute: .bodyUpload)

        bodyImage = image

        // Reset downstream state when body changes
        resultImage = nil
        selectedPreview = .before
        dirtySlot = .none
        showAutoSavePrompt = false
    }

    /// Stub full-body check. TODO: replace with real model-based validation.
    private func passesStubFullBodyCheck(_ image: UIImage) -> Bool {
        // Heuristic: require tall-ish photo and minimum height.
        // This is intentionally simplistic; UI gate only.
        let size = image.size
        if size.height < 900 { return false }
        let aspect = size.height / max(size.width, 1)
        return aspect >= 1.2
    }

    // MARK: Outfit Slot Updates (One swap per generation)

    func requestSetTopImage(_ image: UIImage?) {
        guard canModify(slot: .top) else { return }
        topImage = image
        updateDirtySlotAfterSelecting(slot: .top, image: image)
    }

    func requestSetBottomImage(_ image: UIImage?) {
        guard canModify(slot: .bottom) else { return }
        bottomImage = image
        updateDirtySlotAfterSelecting(slot: .bottom, image: image)
    }

    func clearTopImage() {
        guard canModify(slot: .top) else { return }
        topImage = nil
        updateDirtySlotAfterSelecting(slot: .top, image: nil)
    }

    func clearBottomImage() {
        guard canModify(slot: .bottom) else { return }
        bottomImage = nil
        updateDirtySlotAfterSelecting(slot: .bottom, image: nil)
    }

    private func canModify(slot: DirtySlot) -> Bool {
        switch (dirtySlot, slot) {
        case (.none, _):
            return true
        case (.top, .top):
            return true
        case (.bottom, .bottom):
            return true
        case (.top, .bottom):
            showToast("Only one garment can be changed per generation.")
            return false
        case (.bottom, .top):
            showToast("Only one garment can be changed per generation.")
            return false
        default:
            return false
        }
    }

    private func updateDirtySlotAfterSelecting(slot: DirtySlot, image: UIImage?) {
        // Rule: if user touches a slot this generation, lock the other slot.
        // If they set nil after having selected it, we still consider it the swapped slot for this generation.
        // (Keeps rule simple and predictable.)
        if dirtySlot == .none {
            dirtySlot = slot
        }
        // If they’re editing the same slot again, keep it.
    }

    // MARK: Preview Toggle

    func setPreview(_ selection: PreviewSelection) {
        selectedPreview = selection
    }

    // MARK: Auto-save prompt handling

    func setAutoSaveEnabled(_ enabled: Bool) {
        autoSavePreference = enabled ? .enabled : .disabled
        showAutoSavePrompt = false

        if enabled, resultImage != nil {
            Task { await attemptAutoSaveIfAllowed() }
        }
    }

    // MARK: Generate Flow (Stub)

    func generate() {
        // Prevent overlapping generations
        guard !isGenerating else { return }

        // Tightened guard logic
        guard bodyImage != nil else {
            showToast("Add a full-body photo to continue.")
            return
        }

        // Must have a garment in the dirty slot
        guard dirtySlot != .none else {
            showToast("Add a top or bottom to generate.")
            return
        }

        if dirtySlot == .top, topImage == nil {
            showToast("Add a top or bottom to generate.")
            return
        }
        if dirtySlot == .bottom, bottomImage == nil {
            showToast("Add a top or bottom to generate.")
            return
        }

        // Cancel any existing generation task
        generationTask?.cancel()

        let genId = UUID()
        currentGenerationId = genId

        isGenerating = true
        route = .generating

        generationTask = Task { [weak self] in
            guard let self else { return }

            // Simulate 2–3 seconds
            let delay = UInt64.random(in: self.generatorDelayRange)
            try? await Task.sleep(nanoseconds: delay)

            if Task.isCancelled {
                // Ensure UI doesn't get stuck in generating
                await MainActor.run {
                    if self.currentGenerationId == genId {
                        self.cancelGenerationAndResetUI(nextRoute: .outfitBuilder)
                    }
                }
                return
            }

            // Anti-stale: ensure this is still the active generation
            guard self.currentGenerationId == genId else {
                // Stale generation; do not touch UI state
                return
            }

            // Stub "result": reuse bodyImage (replace later with real output)
            self.resultImage = self.bodyImage

            // Clear dirty slot + default preview to After
            self.dirtySlot = .none
            self.selectedPreview = .after

            // Transition back to outfit builder "Result" view
            self.isGenerating = false
            self.route = .outfitBuilder

            // Post-success behavior: consent-based auto-save decision
            await self.handlePostGenerationAutoSave()
            self.currentGenerationId = nil
        }
    }

    private func handlePostGenerationAutoSave() async {
        guard resultImage != nil else { return }

        switch autoSavePreference {
        case .unknown:
            showAutoSavePrompt = true
        case .enabled:
            await attemptAutoSaveIfAllowed()
        case .disabled:
            break
        }
    }

    // MARK: Auto-save Result (consent-based)

    private func attemptAutoSaveIfAllowed() async {
        guard let image = resultImage else { return }

        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            saveToPhotos(image)
        case .notDetermined:
            // Only prompt when preference is enabled
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if newStatus == .authorized || newStatus == .limited {
                saveToPhotos(image)
            } else {
                showToast("Couldn’t save. Photos permission needed.")
            }
        default:
            showToast("Couldn’t save. Photos permission needed.")
        }
    }

    private func saveToPhotos(_ image: UIImage) {
        // Never log bytes. Best-effort save with callback-based toast correctness.
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { [weak self] success, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if success {
                    self.showToast("Saved.")
                } else {
                    self.showToast("Couldn’t save. Try again.")
                }
            }
        }
    }

    // MARK: Toast

    func showToast(_ message: String, durationSeconds: Double = 2.0) {
        toastTask?.cancel()

        let id = UUID()
        toast = Toast(toastId: id, message: message, isVisible: true)

        toastTask = Task { [weak self] in
            guard let self else { return }
            let ns = UInt64(max(durationSeconds, 0.5) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)

            // Only hide the toast we created (prevents race with a newer toast)
            guard self.toast.toastId == id else { return }
            self.toast = Toast(toastId: self.toast.toastId, message: self.toast.message, isVisible: false)
        }
    }

    func hideToast() {
        toastTask?.cancel()
        toast = Toast(toastId: toast.toastId, message: toast.message, isVisible: false)
    }
}
