//
//  PersistedTodoFile.swift
//  CalTodo
//
//  Created by Ben Lu on 06/04/2023.
//

import Foundation

let url = getDocumentsDirectory().appendingPathComponent("todos.txt")

func saveTodoFile(str: String) {
  do {
    try str.write(to: url, atomically: true, encoding: .utf8)
  } catch {
    print(error.localizedDescription)
  }
}

func readTodoFile() -> String? {
  let input = try? String(contentsOf: url)
  return input
}

func getDocumentsDirectory() -> URL {
  // find all possible documents directories for this user
  let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

  // just send back the first one, which ought to be the only one
  return paths[0]
}
