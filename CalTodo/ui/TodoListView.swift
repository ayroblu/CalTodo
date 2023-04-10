//
//  TodoListView.swift
//  CalTodo
//
//  Created by Ben Lu on 09/04/2023.
//

import SwiftUI

struct TodoListView: View {
  @EnvironmentObject private var todoStore: TodoStore
  @State private var textInput: String = ""

  var body: some View {
    NavigationView {
      List {
        ForEach(todoStore.todoListIds, id: \.self) { todoId in
          TodoItemView(todoId: todoId)
        }
        .onDelete(perform: todoStore.deleteTodo)
      }
      .navigationTitle("Todo List")
      .listStyle(.grouped)
      .scrollDismissesKeyboard(.immediately)
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
}

struct TodoItemView: View {
  @EnvironmentObject private var todoStore: TodoStore
  var todoId: String
  var todo: Todo {
    todoStore.todoMap[todoId]!
  }

  var body: some View {
    let btodoTitle: Binding<String> = Binding(
      get: { todo.title },
      set: {
        todoStore.run(action: .editTitle(todoId, $0))
      }
    )
    let btodoNotes: Binding<String> = Binding(
      get: { todo.notes },
      set: {
        todoStore.run(action: .editNotes(todoId, $0))
      }
    )
    let btodoStartDate: Binding<Date> = Binding(
      get: { todo.startDate ?? Date() },
      set: {
        todoStore.run(action: .editStartDate(todoId, $0))
      }
    )
    return NavigationLink {
      List {
        Section {
          TextField(
            "Todo Text",
            text: btodoTitle, axis: .vertical
          )
        }
        DatePicker(
          "Start Date", selection: btodoStartDate)
        Section {
          TextField(
            "Notes",
            text: btodoNotes, axis: .vertical
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
              todoStore.run(action: .editStatus(todoId, "todo"))
            }
            .opacity(0.5)
          Text(todo.title)
            .strikethrough()
            .opacity(0.5)
        } else {
          Image(systemName: "circle")
            .onTapGesture {
              todoStore.run(action: .editStatus(todoId, "done"))
            }
          TextField(
            "Todo tasks",
            text: btodoTitle, axis: .vertical  // there's a bug with this that makes it twice as big when empty
          )
        }
      }
    }
  }
}

struct TodoListView_Previews: PreviewProvider {
  static var previews: some View {
    TodoListView()
      .environmentObject(TodoStore())
  }
}
