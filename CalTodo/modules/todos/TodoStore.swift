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

  // There are 2 cases to care about, need to make sure all actions are in the log and seenActionIdsSet
  private(set) var log: [RawAction] = []
  private var seenActionIdsSet = Set<String>()
  func run(action: TodoAction) {
    let rawAction = RawAction(id: UUID().uuidString, type: action)
    seenActionIdsSet.insert(rawAction.id)
    log.append(rawAction)
    perform(action: action)
  }
  func run(rawAction: RawAction) {
    if seenActionIdsSet.contains(rawAction.id) { return }
    seenActionIdsSet.insert(rawAction.id)
    log.append(rawAction)
    run(action: rawAction.type)
  }

  func deleteTodo(at offsets: IndexSet) {
    let ids = offsets.map { todoListIds[$0] }
    run(action: .remove(ids))
  }

  private func perform(action: TodoAction) {
    switch action {
    case .insert(let todos, let index):
      todoListIds.insert(
        contentsOf: todos.map { $0.id }, at: min(index, todoListIds.endIndex))
      for todo in todos {
        todoMap[todo.id] = todo
      }
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
  case insert([Todo], Int)
  case editTitle(TodoId, String)
  case editStartDate(TodoId, Date)
  case editDurationMinutes(TodoId, Int)
  case editNotes(TodoId, String)
  case editStatus(TodoId, String)
  case remove([TodoId])
}
typealias TodoId = String

struct RawAction: Codable, Equatable {
  let id: String
  let type: TodoAction
}
func decodeTodoActions(from text: String) -> [RawAction] {
  do {
    guard let data = text.data(using: .utf8) else { return [] }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let rawActions: [RawAction] = try decoder.decode([RawAction].self, from: data)
    return rawActions
  } catch {
    print("error:\(error)")
  }
  return []
}
func encodeTodoActions(_ todoActions: [RawAction]) -> String {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  do {
    let data = try encoder.encode(todoActions)
    let str = String(decoding: data, as: UTF8.self)
    return str
  } catch {
    print(error)
  }
  return ""
}
