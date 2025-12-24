//
//  GlassModifiers.swift
//  fytloapp
//
//  Fytlo Design System - Liquid Glass
//  Centralized iOS version checks and material application.
//

import SwiftUI

// MARK: - Glass Background Modifier

/// Applies glass material background with iOS 26 Liquid Glass support.
/// All #available checks for glass styling are centralized here.
struct GlassBackgroundModifier: ViewModifier {

    let style: GlassStyle

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(glassBackground)
    }

    @ViewBuilder
    private var glassBackground: some View {
        // iOS 26+ Liquid Glass
        // When iOS 26 SDK is available, this branch will use new glass APIs.
        // For now, we use the best available SwiftUI Material as fallback.
        if #available(iOS 26, *) {
            // Future: Use system Liquid Glass material when SDK available.
            // Placeholder: maps to same fallback until iOS 26 SDK ships.
            fallbackMaterial
        } else {
            fallbackMaterial
        }
    }

    /// Fallback materials for iOS 15-25 using SwiftUI Material.
    @ViewBuilder
    private var fallbackMaterial: some View {
        switch style {
        case .prominent:
            // Thicker material for prominent surfaces
            Rectangle()
                .fill(.regularMaterial)

        case .regular:
            // Standard material for cards/sheets
            Rectangle()
                .fill(.thinMaterial)

        case .subtle:
            // Lightest material for small chrome
            Rectangle()
                .fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Glass Stroke Modifier

/// Applies the glass edge highlight stroke.
struct GlassStrokeModifier: ViewModifier {

    let style: GlassStyle

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                    .strokeBorder(style.strokeColor, lineWidth: style.strokeWidth)
            )
    }
}

// MARK: - Glass Shadow Modifier

/// Applies subtle shadow appropriate for the glass style.
struct GlassShadowModifier: ViewModifier {

    let style: GlassStyle

    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.black.opacity(style.shadowOpacity),
                radius: style.shadowRadius,
                x: 0,
                y: style.shadowY
            )
    }
}

// MARK: - Glass Shape Modifier

/// Applies corner radius and clipping for glass surfaces.
struct GlassShapeModifier: ViewModifier {

    let style: GlassStyle

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
    }
}

// MARK: - Combined Glass Modifier

/// Combines all glass styling into a single modifier.
/// Usage: `.modifier(GlassModifier(.regular))`
struct GlassModifier: ViewModifier {

    let style: GlassStyle

    func body(content: Content) -> some View {
        content
            .modifier(GlassBackgroundModifier(style: style))
            .modifier(GlassShapeModifier(style: style))
            .modifier(GlassStrokeModifier(style: style))
            .modifier(GlassShadowModifier(style: style))
    }
}

// MARK: - View Extension

extension View {

    /// Applies Liquid Glass styling to this view.
    /// - Parameter style: The glass style to apply (.prominent, .regular, .subtle)
    /// - Returns: A view with glass background, shape, stroke, and shadow applied.
    func glassBackground(_ style: GlassStyle) -> some View {
        self.modifier(GlassModifier(style: style))
    }

    /// Applies only the glass material background without shape/stroke/shadow.
    /// Useful when you need custom clipping or overlay behavior.
    func glassMaterial(_ style: GlassStyle) -> some View {
        self.modifier(GlassBackgroundModifier(style: style))
    }
}
