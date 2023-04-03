//
//  ContentView.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
