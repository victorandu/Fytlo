//
//  WelcomeView.swift
//  FytloUI
//
//  Created by Fytlo.
//

import SwiftUI

// MARK: - WelcomeView

struct WelcomeView: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 24)

            VStack(spacing: 10) {
                Text("Try on fits in seconds")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 8) {
                    bulletRow("Full-body photo required")
                    bulletRow("One swap at a time")
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 360)
            .padding(.horizontal, 24)

            Spacer(minLength: 24)

            Button {
                vm.goToBodyUpload()
            } label: {
                Text("Start")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Fytlo")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Bullet Row

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.secondary)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WelcomeView(vm: {
            let vm = AppViewModel()
            return vm
        }())
    }
}
