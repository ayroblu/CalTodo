//
//  TodoListView.swift
//  CalTodo
//
//  Created by Ben Lu on 09/04/2023.
//

import SwiftUI

struct TodoListView: View {
  @State var todos: [Todo] = [
    Todo(title: "Make the TodoListView", status: "done"),
    Todo(title: "Editable like reminders"),
    Todo(
      title: "What happens if this text is really long and overflows? Whatever overflowing means"),
    Todo(title: "Laundry tidy"),
    Todo(title: "Physical mail"),
    Todo(title: "Food"),
    Todo(title: "Archery"),
    Todo(title: "Emails"),
    Todo(title: "Decide on how to do grouping, perhaps simply a thin colored border on one side?"),
    Todo(
      title:
        "Need to open todo with more detail, maybe shouldn't use textinput here. Need to show the pivot icon?"
    ),
    Todo(title: "Clean my screen"),
    Todo(title: "Add actions to notifications"),
    Todo(title: "Read through reading list"),
    Todo(title: "Make the TodoListView"),
    Todo(title: "Make the TodoListView"),
  ]
  var body: some View {
    NavigationView {
      List {
        ForEach($todos) { $todo in
          NavigationLink {
            List {
              Section {
                TextField(
                  "Todo Text",
                  text: $todo.title, axis: .vertical
                )
              }
              DatePicker(
                "Start Date", selection: $todo.startDate)
              Section {
                TextField(
                  "Notes",
                  text: $todo.notes, axis: .vertical
                )
                .lineLimit(10, reservesSpace: true)
              }
            }
            .listStyle(.grouped)
          } label: {
            HStack(alignment: .firstTextBaseline) {
              if todo.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                  .onTapGesture {
                    todo.status = "todo"
                  }
                  .opacity(0.5)
                Text(todo.title)
                  .strikethrough()
                  .opacity(0.5)
              } else {
                Image(systemName: "circle")
                  .onTapGesture {
                    todo.status = "done"
                  }
                TextField(
                  "Todo tasks",
                  text: $todo.title, axis: .vertical
                )
              }
            }
          }
        }
        .onDelete(perform: delete)
      }
      .navigationTitle("Todo List")
      .listStyle(.grouped)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            print("Pressed")
          } label: {
            Image(systemName: "arrow.uturn.backward")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            print("Pressed")
          } label: {
            Image(systemName: "arrow.uturn.forward")
          }
        }
      }
    }
  }
  private func delete(at offsets: IndexSet) {
    todos.remove(atOffsets: offsets)
  }
}

struct TodoListView_Previews: PreviewProvider {
  static var previews: some View {
    TodoListView()
  }
}
