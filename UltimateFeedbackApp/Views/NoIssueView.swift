//
//  NoIssueView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 3/27/24.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dc: DataController
    
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button(action: dc.newIssue) {
            Label("New Issue", systemImage: "square.and.pencil")
        }
    }
}

#Preview {
    NoIssueView()
}
