//
//  GlassPreviews.swift
//  fytloapp
//
//  Fytlo Design System - Liquid Glass
//  SwiftUI Previews for all glass components.
//

import SwiftUI

// MARK: - Glass Style Preview Card

/// Sample content card for demonstrating glass styles.
private struct GlassPreviewCard: View {

    let style: GlassStyle
    let title: String

    var body: some View {
        GlassSurface(style, padding: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Corner radius: \(Int(style.cornerRadius))pt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(action: {}) {
                    Text("Action")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - All Styles Preview

/// Preview showing all three glass styles.
private struct GlassStylesPreview: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Liquid Glass Styles")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                GlassPreviewCard(style: .prominent, title: "Prominent")
                    .padding(.horizontal)

                GlassPreviewCard(style: .regular, title: "Regular")
                    .padding(.horizontal)

                GlassPreviewCard(style: .subtle, title: "Subtle")
                    .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Scrim Overlay Preview

/// Preview demonstrating ScrimOverlay for text readability.
private struct ScrimOverlayPreview: View {

    var body: some View {
        VStack(spacing: 20) {
            Text("Scrim Overlay")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Bottom scrim example
            ZStack(alignment: .bottom) {
                // Simulated photo background
                LinearGradient(
                    colors: [.orange, .pink, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Scrim + text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Photo Caption")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Scrim ensures readability over images")
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    ScrimOverlay(edge: .bottom, intensity: 0.6, height: 100)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            }

            // Top scrim example
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [.green, .teal, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                HStack {
                    Text("Top Scrim")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding()
                .background(
                    ScrimOverlay(edge: .top, intensity: 0.5, height: 60)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
            }
        }
        .padding()
    }
}

// MARK: - Glass Over Image Preview

/// Preview showing glass surfaces over a photo-like background.
private struct GlassOverImagePreview: View {

    var body: some View {
        ZStack {
            // Simulated photo background
            LinearGradient(
                colors: [.indigo, .purple, .pink],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                GlassSurface(.subtle, padding: true) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Subtle pill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }

                GlassSurface(.regular, padding: true) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Regular Card")
                            .font(.headline)
                        Text("Standard glass for content areas")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                GlassSurface(.prominent, padding: true) {
                    HStack {
                        Button("Cancel") {}
                            .buttonStyle(.bordered)

                        Spacer()

                        Button("Generate") {}
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - SwiftUI Previews

#Preview("Glass Styles - Light") {
    GlassStylesPreview()
        .preferredColorScheme(.light)
}

#Preview("Glass Styles - Dark") {
    GlassStylesPreview()
        .preferredColorScheme(.dark)
}

#Preview("Scrim Overlay") {
    ScrimOverlayPreview()
}

#Preview("Glass Over Image - Light") {
    GlassOverImagePreview()
        .preferredColorScheme(.light)
}

#Preview("Glass Over Image - Dark") {
    GlassOverImagePreview()
        .preferredColorScheme(.dark)
}
