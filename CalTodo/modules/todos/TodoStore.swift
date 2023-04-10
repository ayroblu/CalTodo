//
//  TodoStore.swift
//  CalTodo
//
//  Created by Ben Lu on 09/04/2023.
//

import Foundation

class TodoStore: ObservableObject {
  @Published private(set) var todoMap: [String: Todo] = [:]
  @Published private(set) var todoListIds: [String] = []

  init(
    todoMap: [String: Todo] = Dictionary(
      uniqueKeysWithValues: performanceFixture.map { ($0.id, $0) }),
    todoListIds: [String] = performanceFixture.map { $0.id }
  ) {
    self.todoMap = todoMap
    self.todoListIds = todoListIds
  }

  func run(action: TodoAction) {
    switch action {
    case .insert(let index, let todos):
      todoListIds.insert(contentsOf: todos.map { $0.id }, at: min(index, todoListIds.endIndex))
    case .editTitle(let id, let title):
      todoMap[id]?.title = title
    case .editStartDate(let id, let startDate):
      todoMap[id]?.startDate = startDate
    case .editDurationMinutes(let id, let durationMinutes):
      todoMap[id]?.durationMinutes = durationMinutes
    case .editNotes(let id, let notes):
      todoMap[id]?.notes = notes
    case .editStatus(let id, let status):
      todoMap[id]?.status = status
    case .remove(let ids):
      let idsSet = Set(ids)
      todoListIds.removeAll(where: { idsSet.contains($0) })
      for id in ids {
        todoMap.removeValue(forKey: id)
      }
    }
  }

  func deleteTodo(at offsets: IndexSet) {
    let ids = offsets.map { todoListIds[$0] }
    run(action: .remove(ids))
  }
}
private let todoFixture = [
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
private let performanceFixture: [Todo] = [Int](0...5_000).map { Todo(title: "Example: \($0)") }

enum TodoAction: Codable, Equatable {
  case insert(Int, [Todo])
  case editTitle(TodoId, String)
  case editStartDate(TodoId, Date)
  case editDurationMinutes(TodoId, Int)
  case editNotes(TodoId, String)
  case editStatus(TodoId, String)
  case remove([TodoId])
}
typealias TodoId = String

struct RawAction: Codable {
  let id: String
  let type: TodoAction
}
func getTodoActions(from text: String) -> [TodoAction] {
  do {
    guard let data = text.data(using: .utf8) else { return [] }
    let rawActions: [RawAction] = try JSONDecoder().decode([RawAction].self, from: data)
    return rawActions.map { $0.type }
  } catch {
    print("error:\(error)")
  }
  return []
}
//func saveTodos(todos: [Todo]) {
//  let encoder = JSONEncoder()
//  do {
//    let data = try encoder.encode(todos)
//    try data.write(to: url)
//  } catch {
//    print(error)
//  }
//}
