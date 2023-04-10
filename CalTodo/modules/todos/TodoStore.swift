//
//  TodoStore.swift
//  CalTodo
//
//  Created by Ben Lu on 09/04/2023.
//

import Foundation
import SwiftUI

class TodoStore: ObservableObject {
  @Published private(set) var todoMap: [String: Todo] = [:]
  @Published private(set) var todoListIds: [String] = []
  private(set) var undoManager = UndoManager()

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
  // Interactively called by the user
  func run(action: TodoAction) {
    let rawAction = RawAction(id: UUID().uuidString, type: action)
    seenActionIdsSet.insert(rawAction.id)
    log.append(rawAction)
    perform(action: action)
  }
  // Called from disk logs
  func run(rawAction: RawAction) {
    if seenActionIdsSet.contains(rawAction.id) { return }
    seenActionIdsSet.insert(rawAction.id)
    log.append(rawAction)
    perform(action: rawAction.type)
  }

  func deleteTodo(at offsets: IndexSet) {
    // TODO: instead of running a delete per id, use the offsets for delete, but just save the ids in the log
    let ids = offsets.map { todoListIds[$0] }
    run(action: .remove(ids))
  }
  func moveTodo(from source: IndexSet, to destination: Int) {
    let ids = source.map { todoListIds[$0] }
    run(action: .move(ids, destination))
  }

  // TODO: If action is performed on child screen, remove from undo stack? Perform navigation?
  private var isUndoGrouping = false
  func undo() {
    if isUndoGrouping {
      undoManager.endUndoGrouping()
      isUndoGrouping = false
    }
    undoManager.undo()
  }
  func redo() {
    undoManager.redo()
  }

  private func perform(action: TodoAction) {
    registerUndo(action: action)
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
    case .move(let ids, let destinationIndex):
      let idsSet = Set(ids)
      let indices = todoListIds.allIndices(where: { id in idsSet.contains(id) })
      todoListIds.move(fromOffsets: indices, toOffset: min(destinationIndex, todoListIds.endIndex))
    case .remove(let ids):
      let idsSet = Set(ids)
      todoListIds.removeAll(where: { idsSet.contains($0) })
      for id in ids {
        todoMap.removeValue(forKey: id)
      }
    case .noop:
      ()
    }
  }
  private func registerUndo(action: TodoAction) {
    let undoAction = reverseAction(action)
    if !undoManager.isUndoing && !undoManager.isRedoing {
      handleGrouping(action: action)
    }
    undoManager.registerUndo(withTarget: self) { store in
      withAnimation {
        store.run(action: undoAction)
      }
    }
  }
  // TODO: Leverage this to build a buffer of log events that you can compact in memory before persisting in the log
  private var lastAction: TodoAction?
  private func handleGrouping(action: TodoAction) {
    if let lastAction = lastAction {
      if !isGroupable(action: action, previousAction: lastAction) {
        if isUndoGrouping {
          undoManager.endUndoGrouping()
          isUndoGrouping = false
        }
        undoManager.beginUndoGrouping()
        isUndoGrouping = true
      }
    } else {
      undoManager.beginUndoGrouping()
      isUndoGrouping = true
    }
    lastAction = action
  }
  private func reverseAction(_ action: TodoAction) -> TodoAction {
    switch action {
    case .insert(let todos, _):
      return .remove(todos.map { $0.id })
    case .editTitle(let id, _):
      if let title = todoMap[id]?.title {
        return .editTitle(id, title)
      }
    case .editStartDate(let id, _):
      if let startDate = todoMap[id]?.startDate {
        return .editStartDate(id, startDate)
      }
    case .editDurationMinutes(let id, _):
      if let durationMinutes = todoMap[id]?.durationMinutes {
        return .editDurationMinutes(id, durationMinutes)
      }
    case .editNotes(let id, _):
      if let notes = todoMap[id]?.notes {
        return .editNotes(id, notes)
      }
    case .editStatus(let id, _):
      if let status = todoMap[id]?.status {
        return .editStatus(id, status)
      }
    case .move(let ids, let index):
      if let id = ids.first, let undoIndex = todoListIds.firstIndex(of: id) {
        // offset 1 cause when you move an item down, it also decreases the indices by 1
        let offset = index < undoIndex ? 1 : 0
        return .move(ids, undoIndex + offset)
      }
    case .remove(let ids):
      if let id = ids.first, let index = todoListIds.firstIndex(of: id) {
        let todos = ids.compactMap({ todoMap[$0] })
        return .insert(todos, index)
      }
    case .noop:
      return .noop
    }
    return .noop
  }
  private func isGroupable(action: TodoAction, previousAction: TodoAction) -> Bool {
    switch (action, previousAction) {
    case (.editTitle(let id, _), .editTitle(let lastId, _)):
      return id == lastId
    case (.editStartDate(let id, _), .editStartDate(let lastId, _)):
      return id == lastId
    case (.editDurationMinutes(let id, _), .editDurationMinutes(let lastId, _)):
      return id == lastId
    case (.editNotes(let id, _), .editNotes(let lastId, _)):
      return id == lastId
    case (.editStatus(let id, _), .editStatus(let lastId, _)):
      return id == lastId
    default:
      return false
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
  Todo(title: "Undo and redo buttons"),
  Todo(title: "Clean the vents"),
]
private let performanceFixture: [Todo] = [Int](0...5_000).map { Todo(title: "Example: \($0)") }

enum TodoAction: Codable, Equatable {
  case insert([Todo], Int)
  case editTitle(TodoId, String)
  case editStartDate(TodoId, Date)
  case editDurationMinutes(TodoId, Int)
  case editNotes(TodoId, String)
  case editStatus(TodoId, String)
  case move([TodoId], Int)
  case remove([TodoId])
  case noop

  // https://gist.github.com/qmchenry/a3b317a8cc47bd06aeabc0ddf95ba113
  var caseName: String {
    return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
  }
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
