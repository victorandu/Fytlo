//
//  GlassStyle.swift
//  fytloapp
//
//  Fytlo Design System - Liquid Glass
//

import SwiftUI

// MARK: - GlassStyle

/// Defines the visual hierarchy for glass surfaces in Fytlo.
/// Each style maps to specific corner radius, stroke, and material intensity.
enum GlassStyle: CaseIterable {

    /// Primary panels, bottom action bars, prominent UI.
    /// Largest corner radius, most visible material.
    case prominent

    /// Cards, sheets, modal content areas.
    /// Medium corner radius, standard material.
    case regular

    /// Pills, small chrome elements, segmented controls.
    /// Smallest corner radius, subtle material.
    case subtle

    // MARK: - Corner Radius

    var cornerRadius: CGFloat {
        switch self {
        case .prominent: return 24
        case .regular:   return 16
        case .subtle:    return 14
        }
    }

    // MARK: - Stroke

    var strokeWidth: CGFloat {
        switch self {
        case .prominent: return 0.5
        case .regular:   return 0.5
        case .subtle:    return 0.33
        }
    }

    var strokeColor: Color {
        // Subtle white highlight for glass edge effect
        Color.white.opacity(0.2)
    }

    // MARK: - Shadow

    var shadowRadius: CGFloat {
        switch self {
        case .prominent: return 16
        case .regular:   return 10
        case .subtle:    return 4
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .prominent: return 0.12
        case .regular:   return 0.08
        case .subtle:    return 0.05
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .prominent: return 8
        case .regular:   return 4
        case .subtle:    return 2
        }
    }

    // MARK: - Padding Defaults (optional convenience)

    var defaultPadding: EdgeInsets {
        switch self {
        case .prominent:
            return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        case .regular:
            return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        case .subtle:
            return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        }
    }
}
