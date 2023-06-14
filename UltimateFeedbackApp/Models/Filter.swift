//
//  Filter.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/25/23.
//

import Foundation

struct Filter: Identifiable, Hashable {
    static var all = Filter(id: UUID(), name: "All Issues", icon: "tray")
    static var recent = Filter(id: UUID(), name: "Recent Issues", icon: "clock",
                               minModificationDate: .now.addingTimeInterval(86400 * -7))
    
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
