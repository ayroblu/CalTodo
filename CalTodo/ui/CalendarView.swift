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
      ScrollView {
        Text(logText)
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
      }.overlay(alignment: .bottom) {
        HStack {
          Button("add example") {
            logExampleFile(str: "Example")
            logText = log
          }
          .buttonStyle(.bordered)
          .background()
          .frame(maxWidth: .infinity)
          Button("clear") {
            deleteExampleFile()
            logText = log
          }
          .buttonStyle(.bordered)
          .background()
          .frame(maxWidth: .infinity)
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity)
      }
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
