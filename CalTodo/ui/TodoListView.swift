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
  @FocusState private var focusedIndex: Int?

  var body: some View {
    NavigationView {
      List {
        ForEach(Array(todoStore.todoListIds.enumerated()), id: \.element) { index, todoId in
          // ForEach(todoStore.todoListIds, id: \.self) { todoId in
          TodoItemView(todoId: todoId, index: index, focusedIndex: $focusedIndex)
        }
        .onDelete(perform: todoStore.deleteTodo)
      }
      .navigationTitle("Todo List")
      .listStyle(.grouped)
      .scrollDismissesKeyboard(.interactively)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            todoStore.undoManager.undo()
          } label: {
            Image(systemName: "arrow.uturn.backward")
          }
          .disabled(!todoStore.undoManager.canUndo)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            todoStore.undoManager.redo()
          } label: {
            Image(systemName: "arrow.uturn.forward")
          }
          .disabled(!todoStore.undoManager.canRedo)
        }

        ToolbarItemGroup(placement: .keyboard) {
          Button("New") {
            if let index = focusedIndex, let focusedId = todoStore.todoListIds[safe: index],
              let todo = todoStore.todoMap[focusedId]
            {
              if todo.title == "" {
                todoStore.deleteTodo(at: IndexSet(integer: index))
              } else {
                todoStore.run(action: .insert([Todo(title: "")], index + 1))
                DispatchQueue.main.async {
                  focusedIndex = index + 1
                }
              }
            }
          }
          Spacer()
          Button("Done") {
            UIApplication.shared.sendAction(
              #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            if let index = focusedIndex, let focusedId = todoStore.todoListIds[safe: index],
              let todo = todoStore.todoMap[focusedId], todo.title == ""
            {
              todoStore.deleteTodo(at: IndexSet(integer: index))
            }
          }
        }
      }
    }
  }
}

struct TodoItemView: View {
  let todoId: String
  let index: Int
  var focusedIndex: FocusState<Int?>.Binding

  @EnvironmentObject private var todoStore: TodoStore
  // @FocusState private var isFocused: Bool
  var todo: Todo? {
    todoStore.todoMap[todoId]
  }

  var body: some View {
    VStack {
      if let todo = todo {
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
        NavigationLink {
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
                  //                  undoManager?.registerUndo(withTarget: todoStore) { store in
                  //                    print("Running undo \(todo.status)")
                  //                    store.run(action: .editStatus(todoId, todo.status))
                  //                    undoManager?.registerUndo(withTarget: todoStore) { store in
                  //                      print("Running second undo \(todo.status)")
                  //                      store.run(action: .editStatus(todoId, "done"))
                  //                      undoManager?.registerUndo(withTarget: todoStore) { store in
                  //                        print("Running third undo \(todo.status)")
                  //                        store.run(action: .editStatus(todoId, todo.status))
                  //                      }
                  //                    }
                  //                  }
                }
              TextField(
                "Todo tasks",
                text: btodoTitle  // there's a bug with this that makes it twice as big when empty
                  , axis: .vertical
              )
              //              .onSubmit {
              //                if todo.title == "" {
              //                  todoStore.deleteTodo(at: IndexSet(integer: index))
              //                } else {
              //                  todoStore.run(action: .insert([Todo(title: "")], index + 1))
              //                  focusedIndex.wrappedValue = index + 1
              //                }
              //              }
              .focused(focusedIndex, equals: index)
              //                            .onChange(of: isFocused) { isFocused in
              //                              if !isFocused && todo.title == "" {
              //                                todoStore.deleteTodo(at: IndexSet(integer: index))
              //                              } else if isFocused && todo.title == "" {
              //                              }
              //                            }
            }
          }
        }
        //        .onChange(of: todoStore.todoMap[todoId]?.status) { newValue in
        //          print("Register todo")
        //          undoManager?.registerUndo(withTarget: todoStore) { store in
        //            print("Running undo \(todo.status)")
        //            todoStore.run(action: .editStatus(todoId, todo.status))
        //          }
        //        }
      } else {
        EmptyView()
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
