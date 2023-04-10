//
//  CalTodoApp.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import SwiftUI

@main
struct CalTodoApp: App {
  let persistenceController = PersistenceController.shared
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) var scenePhase

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .inactive {
        print("Inactive")
      } else if newPhase == .active {
        print("Active")
        let center = UNUserNotificationCenter.current()
        // TODO: Use saved / specific identifiers
        //        center.getPendingNotificationRequests(completionHandler: { requests in
        //          print(requests.count)
        //        })
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
      } else if newPhase == .background {
        print("Background")
      }
    }
  }
}
