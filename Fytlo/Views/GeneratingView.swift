//
//  GeneratingView.swift
//  fytloapp
//
//  Created by Victor Jr on 12/17/25.
//

import SwiftUI

// MARK: - GeneratingView

struct GeneratingView: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer(minLength: 24)

                ProgressView()
                    .progressViewStyle(.circular)

                VStack(spacing: 8) {
                    Text("Trying your fit…")
                        .font(.title3)
                        .multilineTextAlignment(.center)

                    Text("Usually takes 10–30 seconds")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Text("Plain background and good lighting helps.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .navigationTitle("Generating")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GeneratingView(vm: AppViewModel())
    }
}
