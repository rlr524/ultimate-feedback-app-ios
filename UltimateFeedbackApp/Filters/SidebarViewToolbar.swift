//
//  SidebarViewToolbar.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 11/18/24.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dc: DataController
    // Need to use @Binding here because we're referring to a value type
    // property that is created and owned somewhere else (SidebarView in this case).
    @Binding var showingAwards: Bool

    var body: some View {
        #if DEBUG
            Button {
                dc.deleteAll()
                dc.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
        #endif

        Button(action: dc.newTag) {
            Label("Add tag", systemImage: "plus")
        }

        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
    }
}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
}
