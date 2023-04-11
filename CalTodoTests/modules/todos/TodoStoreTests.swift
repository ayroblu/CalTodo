//
//  TodoStoreTests.swift
//  CalTodoTests
//
//  Created by Ben Lu on 10/04/2023.
//

import XCTest

final class TodoStoreTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testEncodeAndDecodeActions() throws {
    let str = encodeTodoActions(rawActions)
    XCTAssertEqual(str, rawJson.replacing(/\s+/, with: ""))
    let todoActions = decodeTodoActions(from: str)
    XCTAssertEqual(todoActions, rawActions)
  }

  func testDecodingIntoStore() throws {
    let todoStore = TodoStore(todoMap: [:], todoListIds: [])
    for rawAction in rawActions {
      todoStore.run(rawAction: rawAction)
    }
    XCTAssertEqual(todoStore.todoListIds, storedTodoListId)
    XCTAssertEqual(todoStore.todoMap, storedTodoMap)
  }

  func testInvalidJsonShouldReturnNothing() throws {
    let todoActions = decodeTodoActions(from: invalidJson)
    XCTAssertEqual(todoActions, [])
  }

  func testExtraPropertyJsonIgnored() throws {
    let todoActions = decodeTodoActions(from: extraPropertyJson)
    XCTAssertEqual(todoActions, singleTodoActions)
  }

  func testInvalidDatePropertyJsonReturnsNothing() throws {
    let todoActions = decodeTodoActions(from: invalidDateJson)
    XCTAssertEqual(todoActions, [])
  }
}

private let rawJson = """
  [
  {"id": "1", "type": {"insert": {"_0": [
    { "status": "todo", "id": "todo-1", "title": "My-title", "notes": "" },
    { "status": "done", "id": "todo-2", "title": "Second", "notes": "" },
    { "status": "done", "id": "todo-3", "title": "Third", "notes": "" }
  ], "_1": 0}}},
  {"id": "2", "type": {"editTitle": {"_0": "todo-1", "_1": "New-title"}}},
  {"id": "3", "type": {"editStartDate": {"_0": "todo-1", "_1": "2023-04-10T02:46:12Z"}}},
  {"id": "4", "type": {"editDurationMinutes": {"_0": "todo-1", "_1": 30}}},
  {"id": "5", "type": {"editNotes": {"_0": "todo-1", "_1": "note"}}},
  {"id": "6", "type": {"editStatus": {"_0": "todo-1", "_1": "done"}}},
  {"id": "7", "type": {"remove": {"_0": ["todo-2"]}}}
  ]
  """
private let isodate = ISO8601DateFormatter().date(from: "2023-04-10T02:46:12Z")!
private let rawActions = [
  RawAction(
    id: "1",
    type: TodoAction.insert(
      [
        Todo(id: "todo-1", title: "My-title"),
        Todo(id: "todo-2", title: "Second", status: "done"),
        Todo(id: "todo-3", title: "Third", status: "done"),
      ], 0)),
  RawAction(id: "2", type: TodoAction.editTitle("todo-1", "New-title")),
  RawAction(id: "3", type: TodoAction.editStartDate("todo-1", isodate)),
  RawAction(id: "4", type: TodoAction.editDurationMinutes("todo-1", 30)),
  RawAction(id: "5", type: TodoAction.editNotes("todo-1", "note")),
  RawAction(id: "6", type: TodoAction.editStatus("todo-1", "done")),
  RawAction(id: "7", type: TodoAction.remove(["todo-2"])),
]
private let storedTodoListId = ["todo-1", "todo-3"]
private let storedTodoMap = [
  "todo-1": Todo(
    id: "todo-1", title: "New-title", status: "done", startDate: isodate, durationMinutes: 30,
    notes: "note"),
  "todo-3": Todo(id: "todo-3", title: "Third", status: "done"),
]
private let invalidJson = """
  {"id": "1", "type": {"insert": {"_0": [
    { "status": "todo", "id": "todo-1", "title": "My-title", "notes": "" },
  ], "_1": 0}}}
  """
private let extraPropertyJson = """
  [
  {"id": "1", "type": {"insert": {"_0": [
    { "status": "todo", "id": "todo-1", "title": "My-title", "notes": "", "extra": "todo" }
  ], "_1": 0}}},
  ]
  """
private let singleTodoActions = [
  RawAction(
    id: "1",
    type: TodoAction.insert(
      [
        Todo(id: "todo-1", title: "My-title")
      ], 0))
]
private let invalidDateJson = """
  [
  {"id": "1", "type": {"insert": {"_0": [
    { "status": "todo", "id": "todo-1", "title": "My-title", "notes": "", "startDate": "2023-04-10 02:46:12Z" }
  ], "_1": 0}}},
  ]
  """
