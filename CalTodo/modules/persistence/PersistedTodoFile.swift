//
//  PersistedTodoFile.swift
//  CalTodo
//
//  Created by Ben Lu on 06/04/2023.
//

import Foundation

let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let url = documentsDirectory.appendingPathComponent("todos.json")

struct Todo: Codable {
  var status: String
  var title: String
  var startIsoDate: String
  var endIsoDate: String
}

func loadTodos() -> [Todo]? {
  do {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    let jsonData = try decoder.decode([Todo].self, from: data)
    return jsonData
  } catch {
    print("error:\(error)")
  }
  return nil
}
func saveTodos(todos: [Todo]) {
  let encoder = JSONEncoder()
  do {
    let data = try encoder.encode(todos)
    try data.write(to: url)
  } catch {
    print(error)
  }
}

let exampleUrl = documentsDirectory.appendingPathComponent("example.txt")
func logExampleFile(str: String) {
  let formatter = DateFormatter()
  formatter.dateFormat = "HH:mm:ss"
  let timestamp = formatter.string(from: Date())
  let logMessage = (timestamp + ": " + str + "\n")
  appendExampleFile(str: logMessage)
}
func appendExampleFile(str: String) {
  if let handle = try? FileHandle(forWritingTo: exampleUrl) {
    handle.seekToEndOfFile()
    handle.write(str.data(using: .utf8)!)
    handle.closeFile()
  } else {
    try? str.write(to: exampleUrl, atomically: true, encoding: .utf8)
  }
}

func readExampleFile() -> String? {
  let input = try? String(contentsOf: exampleUrl)
  return input
}

func deleteExampleFile() {
  try? FileManager.default.removeItem(at: exampleUrl)
}
