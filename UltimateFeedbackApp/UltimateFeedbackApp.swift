//
//  UltimateFeedbackAppApp.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/20/23.
//

import SwiftUI

@main
struct UltimateFeedbackAppApp: App {
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
        }
    }
}
