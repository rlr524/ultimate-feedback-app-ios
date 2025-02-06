//
//  ContentViewModel.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 2/5/25.
//

import Foundation
import CoreData

extension ContentView {
    class ViewModel: ObservableObject {
        var dc: DataController

        init(dc: DataController) {
            self.dc = dc
        }

        func delete(_ offsets: IndexSet) {
            let issues = dc.issuesForSelectedFilter()

            for offset in offsets {
                let item = issues[offset]
                dc.delete(item)
            }
        }
    }
}
