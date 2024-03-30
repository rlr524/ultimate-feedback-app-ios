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
    // If the user makes a change to an issue then very quickly brings up multitasking and
    // exits the app, we need to make sure their data is definitely safe rather than waiting a few
    // seconds for the sleep to finish. This can be done by watching for a scene phase change in
    // our main App struct, first by adding a new property there. It sounds like we’re covering a
    // fairly unlikely scenario, but as Doug Linder once said: “a good programmer is the kind of
    // person who looks both ways before crossing a one-way street.” Use the @Environment
    // property wrapper to pull in the key path of the scenePhase property, which provides the
    // value of the operational state of a scene.
    @Environment(\.scenePhase) var scenePhase
    
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
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    dataController.save()
                }
            }
        }
    }
}
