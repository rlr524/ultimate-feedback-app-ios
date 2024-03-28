//
//  NoIssueView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 3/27/24.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue") {
            // make a new issue
        }
    }
}

#Preview {
    NoIssueView()
}
