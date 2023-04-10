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

  func todoStoreInitialisation() throws {
    //    let todoStore = TodoStore(todoMap: [:], todoListIds: [])
    let todoActions = getTodoActions(from: rawJson)
    XCTAssertEqual(todoActions, rawActions)
  }

}

private let rawJson = """
  [
  {"id": "1", "type": "insert", "index": 0, "todo": { "title": "My title" }},
  {"id": "123", "type": "editTitle", "todoId": "todo-1", "title": "New title"},
  ]
  """
private let rawActions = [
  TodoAction.insert(0, [Todo(id: "todo-1", title: "My title")]),
  TodoAction.editTitle("todo-1", "New title"),
]
private let storedTodoListId = ["todo-1"]
private let storedTodoMap = ["todo-1": Todo(id: "todo-1", title: "My title")]
