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

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
