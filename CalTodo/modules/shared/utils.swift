//
//  utils.swift
//  CalTodo
//
//  Created by Ben Lu on 10/04/2023.
//

import Foundation

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
// https://forums.swift.org/t/comparing-enum-cases-while-ignoring-associated-values/15922/7
// https://forums.swift.org/t/getting-the-name-of-a-swift-enum-value/35654/17
@_silgen_name("swift_EnumCaseName")
func _getEnumCaseName<T>(_ value: T) -> UnsafePointer<CChar>?

func getEnumCaseName<T>(for value: T) -> String? {
  if let stringPtr = _getEnumCaseName(value) {
    return String(validatingUTF8: stringPtr)
  }
  return nil
}
// if case .editTitle = action {
