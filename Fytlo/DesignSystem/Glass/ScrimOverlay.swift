//
//  ScrimOverlay.swift
//  fytloapp
//
//  Fytlo Design System - Liquid Glass
//  Gradient overlay for text readability over images.
//

import SwiftUI

// MARK: - ScrimOverlay

/// A gradient overlay that improves text readability over images.
///
/// By default, creates a bottom-to-clear gradient (darker at bottom).
/// Use this behind text that sits over photos or busy backgrounds.
///
/// Usage:
/// ```swift
/// ZStack(alignment: .bottom) {
///     Image("photo")
///     ScrimOverlay()
///     Text("Caption").foregroundStyle(.white)
/// }
/// ```
struct ScrimOverlay: View {

    let edge: Edge
    let color: Color
    let intensity: Double
    let height: CGFloat?

    /// Creates a scrim overlay.
    /// - Parameters:
    ///   - edge: The edge where the scrim is darkest (.bottom or .top). Default is `.bottom`.
    ///   - color: The scrim color. Default is `.black`.
    ///   - intensity: The maximum opacity of the scrim (0.0-1.0). Default is `0.5`.
    ///   - height: Optional fixed height. If nil, expands to fill available space.
    init(
        edge: Edge = .bottom,
        color: Color = .black,
        intensity: Double = 0.5,
        height: CGFloat? = nil
    ) {
        self.edge = edge
        self.color = color
        self.intensity = min(max(intensity, 0), 1)
        self.height = height
    }

    var body: some View {
        gradient
            .frame(height: height)
            .allowsHitTesting(false)
    }

    private var gradient: LinearGradient {
        let opaqueStop = color.opacity(intensity)
        let clearStop = color.opacity(0)

        switch edge {
        case .bottom:
            // Dark at bottom, fades to clear at top
            return LinearGradient(
                colors: [clearStop, opaqueStop],
                startPoint: .top,
                endPoint: .bottom
            )
        case .top:
            // Dark at top, fades to clear at bottom
            return LinearGradient(
                colors: [opaqueStop, clearStop],
                startPoint: .top,
                endPoint: .bottom
            )
        case .leading:
            // Dark at leading, fades to clear
            return LinearGradient(
                colors: [opaqueStop, clearStop],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .trailing:
            // Dark at trailing, fades to clear
            return LinearGradient(
                colors: [clearStop, opaqueStop],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - Convenience Initializers

extension ScrimOverlay {

    /// A standard bottom scrim for text over images.
    static var bottom: ScrimOverlay {
        ScrimOverlay(edge: .bottom, intensity: 0.5)
    }

    /// A lighter bottom scrim.
    static var bottomLight: ScrimOverlay {
        ScrimOverlay(edge: .bottom, intensity: 0.3)
    }

    /// A standard top scrim (e.g., for status bar area).
    static var top: ScrimOverlay {
        ScrimOverlay(edge: .top, intensity: 0.4)
    }
}

// MARK: - View Modifier

extension View {

    /// Applies a scrim overlay behind this view for improved readability.
    /// - Parameters:
    ///   - edge: The edge where the scrim is darkest.
    ///   - intensity: The maximum opacity of the scrim.
    /// - Returns: A view with the scrim applied as a background.
    func scrimBackground(
        edge: Edge = .bottom,
        intensity: Double = 0.5
    ) -> some View {
        self.background(
            ScrimOverlay(edge: edge, intensity: intensity)
        )
    }
}
