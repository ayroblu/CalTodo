//
//  TodoView.swift
//  CalTodo
//
//  Created by Ben Lu on 02/04/2023.
//

import SwiftUI

struct TodoView: View {
    var body: some View {
        VStack {
            Button("Request permission") {
                getPermission()
            }
            Button("Create notification") {
                createNotification()
            }
        }
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView()
    }
}
