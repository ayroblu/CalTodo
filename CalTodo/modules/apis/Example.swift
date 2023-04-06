//
//  Example.swift
//  CalTodo
//
//  Created by Ben Lu on 06/04/2023.
//

import Foundation

extension URLSession {
  func fetchData<T: Decodable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) {
    self.dataTask(with: url) { (data, response, error) in
      if let error = error {
        completion(.failure(error))
      }

      if let data = data {
        do {
          let object = try JSONDecoder().decode(T.self, from: data)
          completion(.success(object))
        } catch let decoderError {
          completion(.failure(decoderError))
        }
      }
    }.resume()
  }
}
struct ToDo: Decodable {
  let userId: Int
  let id: Int
  let title: String
  let isComplete: Bool

  enum CodingKeys: String, CodingKey {
    case isComplete = "completed"
    case userId, id, title
  }
}
