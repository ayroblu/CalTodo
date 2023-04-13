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
  @State private var sheetId: String?

  @FocusState private var focusedIndex: Int?
  @State var data: [(String, [Int])] = [
    ("hours", Array(0...24)),
    ("minutes", Array(stride(from: 0, to: 55, by: 5))),
  ]

  @State private var isDurationOpen: Bool = false

  var body: some View {
    let bisSheetPresented: Binding<Bool> = Binding(get: {
      sheetId != nil
    }) {
      sheetId = $0 ? "" : nil
    }
    NavigationView {
      List {
        ForEach(Array(todoStore.todoListIds.enumerated()), id: \.element) { index, todoId in
          TodoItemView(todoId: todoId, index: index, focusedIndex: $focusedIndex, sheetId: $sheetId)
          // TodoItemView(todoId: todoId, index: index, focusedIndex: $focusedIndex)
        }
        .onDelete(perform: todoStore.deleteTodo)
        .onMove(perform: todoStore.moveTodo)
        if focusedIndex == nil {
          Button("Add todo") {
            let index = todoStore.todoListIds.endIndex
            todoStore.run(action: .insert([Todo(title: "")], index))
            DispatchQueue.main.async {
              focusedIndex = index
            }
          }
        }
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
    .sheet(isPresented: bisSheetPresented) {
      NavigationView {
        List {
          if let todoId = sheetId, let todo = todoStore.todoMap[todoId] {
            let btodoTitle: Binding<String> = Binding(
              get: { todo.title },
              set: {
                if todo.title != $0 {
                  todoStore.run(action: .editTitle(todoId, $0))
                }
              }
            )
            let btodoNotes: Binding<String> = Binding(
              get: { todo.notes },
              set: {
                if todo.notes != $0 {
                  todoStore.run(action: .editNotes(todoId, $0))
                }
              }
            )

            Section {
              TextField(
                "Todo Text",
                text: btodoTitle, axis: .vertical
              )
            }
            let bisStartDate: Binding<Bool> = Binding(
              get: { todo.startDate != nil },
              set: {
                let startDate = $0 ? Date() : nil
                // Doesn't actually work?
                withAnimation {
                  todoStore.run(action: .editStartDate(todoId, startDate))
                }
              }
            )
            Toggle(isOn: bisStartDate) {
              Text("Start Date")
            }
            if let startDate = todo.startDate {
              let bstartDate: Binding<Date> = Binding(
                get: { startDate },
                set: {
                  todoStore.run(action: .editStartDate(todoId, $0))
                }
              )
              DatePicker("", selection: bstartDate)
            }
            Button {
              withAnimation {
                isDurationOpen.toggle()
              }
            } label: {
              HStack {
                Text("Duration")
                Spacer()
                Text(
                  "\(todo.durationMinutes >= 60 ? "\(todo.durationMinutes / 60)h " : "")\(todo.durationMinutes % 60)m"
                )
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(ListButtonStyle())
            .listRowInsets(EdgeInsets())

            let bselection: Binding<[Int]> = Binding(
              get: { [todo.durationMinutes / 60, todo.durationMinutes % 60] },
              set: {
                todoStore.run(action: .editDurationMinutes(todoId, $0[0] * 60 + $0[1]))
              })
            if isDurationOpen {
              MultiPicker(data: data, selection: bselection).frame(height: 200)
            }
            Section {
              TextField(
                "Notes",
                text: btodoNotes, axis: .vertical
              )
              .lineLimit(10, reservesSpace: true)
            }
          }
        }
        .listStyle(.insetGrouped)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") {
              sheetId = nil
            }
          }
        }
        .navigationBarTitle("Details", displayMode: .inline)
      }
    }
  }
}

struct TodoItemView: View {
  let todoId: String
  let index: Int
  var focusedIndex: FocusState<Int?>.Binding
  var sheetId: Binding<String?>

  @EnvironmentObject private var todoStore: TodoStore
  // @FocusState private var isFocused: Bool
  var todo: Todo? {
    todoStore.todoMap[todoId]
  }

  var body: some View {
    VStack {
      if let todo = todo {
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
            let btodoTitle: Binding<String> = Binding(
              get: { todo.title },
              set: {
                if todo.title != $0 {
                  todoStore.run(action: .editTitle(todoId, $0))
                }
              }
            )
            VStack {
              // there's a bug with axis that offsets it when empty
              TextField("", text: btodoTitle, axis: .vertical)
                .focused(focusedIndex, equals: index)
                .offset(y: todo.title.isEmpty ? -15 : 0)
              HStack {
                Text("\(todo.durationMinutes)m")
                Spacer()
              }
              .font(.system(size: 12))
              .opacity(0.5)
            }
          }
          Spacer(minLength: 0)
          Image(systemName: "info.circle")
            .opacity(focusedIndex.wrappedValue == index ? 1 : 0.3)
            .onTapGesture {
              sheetId.wrappedValue = todoId
            }
        }
      }
    }
  }
}
// Rewrite with this: https://github.com/laevandus/SwiftUIDateDurationPicker/blob/main/SwiftUIDateDurationPicker/SwiftUIDateDurationPicker/DateDurationPicker.swift
struct MultiPicker: View {

  typealias Label = String
  typealias Entry = Int

  let data: [(Label, [Entry])]
  @Binding var selection: [Entry]

  var body: some View {
    GeometryReader { geometry in
      HStack {
        ForEach(0..<self.data.count, id: \.self) { column in
          Picker(self.data[column].0, selection: self.$selection[column]) {
            ForEach(0..<self.data[column].1.count, id: \.self) { row in
              Text(verbatim: "\(self.data[column].1[row])")
                .tag(self.data[column].1[row])
            }
          }
          .pickerStyle(.wheel)
          .frame(
            width: geometry.size.width / CGFloat(self.data.count), height: geometry.size.height
          )
          .clipped()
        }
      }
    }
  }
}
struct ListButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .background(configuration.isPressed ? Color(red: 0.4, green: 0.4, blue: 0.4) : nil)
      .animation(.linear, value: configuration.isPressed)
    // .foregroundColor(.white)
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
