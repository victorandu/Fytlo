//
//  GarmentSlotCard.swift
//  fytloapp
//
//  Created by Victor Jr on 12/17/25.
//

import SwiftUI
import UIKit

// MARK: - GarmentSlot

enum GarmentSlot: Equatable {
    case top
    case bottom

    var title: String {
        switch self {
        case .top: return "Top"
        case .bottom: return "Bottom"
        }
    }

    var emptySubtitle: String {
        switch self {
        case .top: return "Add a top"
        case .bottom: return "Add a bottom"
        }
    }

    var iconName: String {
        switch self {
        case .top: return "tshirt"
        case .bottom: return "figure.walk" // closest widely-available SF Symbol
        }
    }

    var accessibilitySlotName: String {
        switch self {
        case .top: return "Top slot"
        case .bottom: return "Bottom slot"
        }
    }
}

// MARK: - GarmentSlotCard

struct GarmentSlotCard: View {
    let slot: GarmentSlot
    let image: UIImage?
    let isLocked: Bool
    let actionTitle: String
    let onTap: () -> Void
    let onLockedTap: (() -> Void)?

    private var subtitleText: String {
        if image == nil {
            return slot.emptySubtitle
        } else {
            return "Selected"
        }
    }

    private var effectiveTap: (() -> Void)? {
        if isLocked {
            return onLockedTap
        } else {
            return onTap
        }
    }

    private var lockedSuffixA11y: String {
        isLocked ? " Locked. One swap at a time." : ""
    }

    var body: some View {
        let tapAction = effectiveTap

        HStack(alignment: .center, spacing: 14) {
            thumbnail

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(slot.title)
                        .font(.headline)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                }

                Text(subtitleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    tapAction?()
                } label: {
                    Text(actionTitle)
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .disabled(tapAction == nil)
                .opacity(tapAction == nil ? 0.6 : 1.0)
                .accessibilityLabel(Text(actionTitle))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.black.opacity(isLocked ? 0.10 : 0.06), lineWidth: 1)
        )
        .opacity(isLocked ? 0.72 : 1.0)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(slot.accessibilitySlotName). \(subtitleText). Button: \(actionTitle).\(lockedSuffixA11y)"))
        .accessibilityHint(Text(isLocked ? "Tap to learn why this slot is locked." : "Tap to choose an image for this slot."))
    }

    // MARK: Thumbnail

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemBackground))

            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Image(systemName: slot.iconName)
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .frame(width: 72, height: 72) // reasonable fixed size; doesn't constrain text
        .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview("GarmentSlotCard") {
    VStack(spacing: 14) {
        GarmentSlotCard(
            slot: .top,
            image: nil,
            isLocked: false,
            actionTitle: "Upload",
            onTap: {},
            onLockedTap: { }
        )

        GarmentSlotCard(
            slot: .bottom,
            image: UIImage(systemName: "photo"),
            isLocked: true,
            actionTitle: "Change",
            onTap: {},
            onLockedTap: { }
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
