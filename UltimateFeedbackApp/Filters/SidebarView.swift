//
//  SidebarView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/25/23.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var vm: ViewModel
    let smartFilters: [Filter] = [.all, .recent]

    init(dc: DataController) {
        let vm = ViewModel(dc: dc)
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        List(selection: $vm.dc.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            
            Section("Tags") {
                ForEach(vm.tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: vm.rename, delete: vm.delete)
                }
                .onDelete(perform: vm.delete)
            }
        }
        .toolbar {
            SidebarViewToolbar(showingAwards: $vm.showingAwards)
        }
        .alert("Rename tag", isPresented: $vm.renamingTag) {
            Button("OK", action: vm.completeRename)
            Button("Cancel", role: .cancel) {}
            TextField("New name", text: $vm.tagName)
        }
        .navigationTitle("Filters")
        .sheet(isPresented: $vm.showingAwards, content: AwardsView.init)
    }
}

#Preview {
    SidebarView(dc: .preview)
}
