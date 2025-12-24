//
//  GlassSurface.swift
//  fytloapp
//
//  Fytlo Design System - Liquid Glass
//  Reusable glass container view.
//

import SwiftUI

// MARK: - GlassSurface

/// A reusable container that applies Liquid Glass styling to its content.
///
/// Usage:
/// ```swift
/// GlassSurface(.regular) {
///     Text("Hello, Glass!")
/// }
///
/// GlassSurface(.prominent, padding: true) {
///     VStack { ... }
/// }
/// ```
struct GlassSurface<Content: View>: View {

    let style: GlassStyle
    let applyDefaultPadding: Bool
    let content: Content

    /// Creates a glass surface container.
    /// - Parameters:
    ///   - style: The glass style (.prominent, .regular, .subtle)
    ///   - padding: Whether to apply the style's default padding. Default is `false`.
    ///   - content: The content to display inside the glass surface.
    init(
        _ style: GlassStyle,
        padding: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.applyDefaultPadding = padding
        self.content = content()
    }

    var body: some View {
        Group {
            if applyDefaultPadding {
                content
                    .padding(style.defaultPadding)
            } else {
                content
            }
        }
        .glassBackground(style)
    }
}

// MARK: - Convenience Initializers

extension GlassSurface {

    /// Creates a prominent glass surface (bottom bars, primary panels).
    static func prominent(
        padding: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> GlassSurface {
        GlassSurface(.prominent, padding: padding, content: content)
    }

    /// Creates a regular glass surface (cards, sheets).
    static func regular(
        padding: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> GlassSurface {
        GlassSurface(.regular, padding: padding, content: content)
    }

    /// Creates a subtle glass surface (pills, small chrome).
    static func subtle(
        padding: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> GlassSurface {
        GlassSurface(.subtle, padding: padding, content: content)
    }
}
