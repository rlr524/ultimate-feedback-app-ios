//
//  UserFilterRow.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 11/26/24.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.activeIssuesCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                // Using automatic grammar agreement, which is part of the Foundation
                // framework, to adjust "issue" to "issues" when the number of
                // issues is plural.
                .accessibilityHint("^[\(filter.activeIssuesCount) issue](inflect: true)")
        }
    }
}
