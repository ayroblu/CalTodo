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
            todoStore.undo()
          } label: {
            Image(systemName: "arrow.uturn.backward")
          }
          .disabled(!todoStore.undoManager.canUndo)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            todoStore.redo()
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

  @State private var tempTitle: String?
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
                }
              // UIKitTextField(text: btodoTitle)
              // there's a bug with axis that makes it twice as big when empty
              TextField("", text: btodoTitle, axis: .vertical)
                // onEditingChanged: { isFocused in
                //   if !isFocused {
                //     if let tempTitle = tempTitle {
                //       todoStore.run(action: .editTitle(todoId, tempTitle))
                //     }
                //   }
                // }
                .focused(focusedIndex, equals: index)
            }
          }
        }
      } else {
        EmptyView()
      }
    }
  }
}

// struct UIKitTextField: UIViewRepresentable {
//   @Binding var text: String
//   var placeholder: String = ""
//
//   func makeCoordinator() -> Coordinator {
//     Coordinator(text: $text)
//   }
//
//   func makeUIView(context: Context) -> UITextField {
//     let textField = UITextField()
//
//     textField.text = text
//     textField.addTarget(
//       context.coordinator, action: #selector(context.coordinator.textChanged), for: .editingChanged)
//
//     textField.delegate = context.coordinator
//     textField.placeholder = placeholder
//     // textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
//
//     return textField
//   }
//
//   func updateUIView(_ textField: UITextField, context: Context) {
//     textField.text = text
//   }
//
//   public final class Coordinator: NSObject, UITextFieldDelegate {
//     @Binding private var text: String
//
//     public init(text: Binding<String>) {
//       self._text = text
//     }
//
//     @objc func textChanged(_ sender: UITextField) {
//       guard let text = sender.text else { return }
//       self.text = text
//     }
//     @objc public func textFieldDidEndEditing(
//       _ textField: UITextField, reason: UITextField.DidEndEditingReason
//     ) {
//       // guard let text = sender.text else { return }
//       // self.text = text
//     }
//   }
// }

struct TodoListView_Previews: PreviewProvider {
  static var previews: some View {
    TodoListView()
      .environmentObject(TodoStore())
  }
}
