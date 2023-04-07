//
//  CalendarView.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import SwiftUI

struct CalendarView: View {
  @State var logText: String = log

  var body: some View {
    VStack {
      Text(logText)
        .padding()
      Button("add example") {
        logExampleFile(str: "Example")
        logText = log
      }
      .padding()
      .buttonStyle(.bordered)
      Button("clear") {
        deleteExampleFile()
        logText = log
      }
      .padding()
      .buttonStyle(.bordered)
    }
  }
}
private var log: String {
  return readExampleFile() ?? "<empty>"
}

struct CalendarView_Previews: PreviewProvider {
  static var previews: some View {
    CalendarView()
  }
}
