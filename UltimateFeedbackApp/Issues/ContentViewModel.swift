//
//  ContentViewModel.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 2/5/25.
//

import Foundation

extension ContentView {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        var dc: DataController

        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
            dc[keyPath: keyPath]
        }

        subscript<Value>(dynamicMember keyPath:
            ReferenceWritableKeyPath<DataController, Value>) -> Value
        {
            get { dc[keyPath: keyPath] }
            set { dc[keyPath: keyPath] = newValue }
        }

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
