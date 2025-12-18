//
//  ToastView.swift
//  FytloUI
//
//  Created by Fytlo.
//

import SwiftUI

// MARK: - ToastView

struct ToastView: View {
    let message: String
    let isVisible: Bool
    var durationSeconds: Double = 2.0
    var onDismiss: (() -> Void)? = nil

    @State private var hideTask: Task<Void, Never>?

    private func sanitize(_ raw: String) -> String {
        // Guardrails: prevent accidental sensitive leaks in UI + VoiceOver.
        var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Normalize whitespace
        value = value
            .replacingOccurrences(of: "\\n", with: " ")
            .replacingOccurrences(of: "\\t", with: " ")
        while value.contains("  ") {
            value = value.replacingOccurrences(of: "  ", with: " ")
        }

        // Redact emails
        value = value.replacingOccurrences(
            of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
            with: "•••",
            options: .regularExpression
        )

        // Redact URLs
        value = value.replacingOccurrences(
            of: "https?:\\/\\/[^\\s]+",
            with: "•••",
            options: .regularExpression
        )

        // Redact long token-like strings (JWTs, base64, hex blobs)
        value = value.replacingOccurrences(
            of: "[A-Za-z0-9_-]{24,}",
            with: "•••",
            options: .regularExpression
        )

        // Final length cap
        return String(value.prefix(160))
    }

    private var displayMessage: String {
        sanitize(message)
    }

    private var effectiveDuration: Double {
        // If durationSeconds is 0, treat as "persistent" (no auto-hide).
        // Otherwise clamp to a sensible minimum to avoid flicker.
        guard durationSeconds > 0 else { return 0 }
        return max(0.8, durationSeconds)
    }

    var body: some View {
        let display = displayMessage

        Group {
            if isVisible, !display.isEmpty {
                content(display)
                    .onTapGesture { dismiss() }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        if isVisible { scheduleAutoHideIfNeeded() }
                    }
                    .onChange(of: isVisible) { _, newValue in
                        if newValue {
                            // Start timer only when toast becomes visible.
                            scheduleAutoHideIfNeeded()
                        } else {
                            cancelAutoHide()
                        }
                    }
                    .onChange(of: durationSeconds) { _, _ in
                        // If duration changes while visible, restart timing.
                        if isVisible { scheduleAutoHideIfNeeded() }
                    }
                    .onDisappear { cancelAutoHide() }
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: isVisible)
    }

    // MARK: Content

    private func content(_ display: String) -> some View {
        Text(display)
            .font(.callout.weight(.medium))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
    }

    // MARK: Auto-hide

    private func scheduleAutoHideIfNeeded() {
        cancelAutoHide()
        guard effectiveDuration > 0 else { return }

        hideTask = Task { @MainActor in
            let ns = UInt64(effectiveDuration * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
            dismiss()
        }
    }

    private func cancelAutoHide() {
        hideTask?.cancel()
        hideTask = nil
    }

    private func dismiss() {
        cancelAutoHide()
        onDismiss?()
    }
}

// MARK: - Convenience View Modifier

extension View {
    func toast(
        message: String,
        isVisible: Bool,
        durationSeconds: Double = 2.0,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        overlay(alignment: .bottom) {
            ToastView(
                message: message,
                isVisible: isVisible,
                durationSeconds: durationSeconds,
                onDismiss: onDismiss
            )
        }
    }
}

// MARK: - Preview

#Preview("Toast - Visible") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        VStack(spacing: 12) {
            Text("Screen Content")
                .font(.system(size: 18, weight: .semibold))
            Text("Toast overlays at the bottom.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
    }
    .toast(
        message: "Only one garment can be changed per generation.",
        isVisible: true,
        durationSeconds: 0 // keep visible in preview
    )
}

#Preview("Toast - Hidden") {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        VStack(spacing: 12) {
            Text("Screen Content")
                .font(.system(size: 18, weight: .semibold))
            Text("Toast is hidden.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
    }
    .toast(
        message: "Saved.",
        isVisible: false
    )
}
