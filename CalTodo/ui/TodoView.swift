//
//  TodoView.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import SwiftUI

struct TodoView: View {
  var body: some View {
    #if SWIFT_ONE
      VStack {
        Button("Request permission") {
          getPermission()
        }
        .padding()
        .buttonStyle(.bordered)
        Button("Create notification") {
          createManyNotification()
        }
        .padding()
        .buttonStyle(.bordered)
        Button("Create Vibration") {
          vibrateBomb()
        }
        .padding()
        .buttonStyle(.bordered)
      }
    #else
      TodoListView()
    #endif
  }
}

struct TodoView_Previews: PreviewProvider {
  static var previews: some View {
    TodoView()
  }
}
