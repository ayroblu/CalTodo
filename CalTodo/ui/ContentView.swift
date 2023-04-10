//
//  ContentView.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import CoreData
import SwiftUI

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @StateObject private var todoStore: TodoStore = TodoStore()

  var body: some View {
    TabView {
      TodoView()
        .tabItem {
          Label("Todos", systemImage: "checklist")
        }
      CalendarView()
        .tabItem {
          Label("Calendar", systemImage: "calendar")
        }
      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
    }
    .environmentObject(todoStore)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environment(
      \.managedObjectContext, PersistenceController.preview.container.viewContext
    )
    .environmentObject(TodoStore())
  }
}
