//
//  AwardsView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 7/13/24.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dc: DataController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    var awardTitle: String {
        if dc.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(award.description)
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }

    func color(for award: Award) -> Color {
        dc.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }

    func label(for award: Award) -> LocalizedStringKey {
        dc.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
    }
}

#Preview {
    AwardsView()
}
