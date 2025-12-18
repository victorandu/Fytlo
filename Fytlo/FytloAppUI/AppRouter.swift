//
//  AppRouter.swift
//  FytloUI
//
//  Created by Fytlo.
//

import SwiftUI

// MARK: - AppRouter

struct AppRouter: View {
    @StateObject private var vm = AppViewModel()
    @State private var frozenRoute: AppViewModel.Route? = nil

    var body: some View {
        ZStack {
            NavigationStack {
                content
            }
            .disabled(vm.showAutoSavePrompt) // block taps behind consent overlay
            .blur(radius: vm.showAutoSavePrompt ? 2.0 : 0)
            .accessibilityHidden(vm.showAutoSavePrompt)

            if vm.showAutoSavePrompt {
                autoSaveConsentOverlay
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .toast(
            message: vm.toast.message,
            isVisible: vm.toast.isVisible,
            onDismiss: { vm.hideToast() }
        )
        .animation(.easeInOut(duration: 0.18), value: vm.showAutoSavePrompt)
        .onChange(of: vm.showAutoSavePrompt) { _, showing in
            if showing {
                frozenRoute = vm.route
            } else {
                frozenRoute = nil
            }
        }
    }

    // MARK: Content Routing

    @ViewBuilder
    private var content: some View {
        let route = frozenRoute ?? vm.route

        switch route {
        case .welcome:
            WelcomeView(vm: vm)

        case .bodyUpload:
            BodyUploadView(vm: vm)

        case .outfitBuilder:
            OutfitBuilderView(vm: vm)

        case .generating:
            GeneratingView(vm: vm)
        }
    }

    // MARK: Auto-save Consent Overlay

    private var autoSaveConsentOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Auto-save results?")
                    .font(.system(size: 18, weight: .semibold))

                Text("Save every try-on to your Photos automatically.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)

                VStack(spacing: 10) {
                    Button {
                        vm.setAutoSaveEnabled(true)
                    } label: {
                        Text("Yes, auto-save")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        vm.setAutoSaveEnabled(false)
                    } label: {
                        Text("Not now")
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 4)
            }
            .padding(18)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 10)
            .padding(.horizontal, 20)
        }
        .allowsHitTesting(true) // block taps behind
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - Preview

#Preview {
    AppRouter()
}
