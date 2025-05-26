//
//  NetworkService.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.global(qos: .background).async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let response = try decoder.decode(TodosResponse.self, from: data)
                    let todos = response.todos.map { todo in
                        TodoItem(
                            id: todo.id,
                            title: todo.todo,
                            isCompleted: todo.completed,
                            createdAt: Date()
                        )
                    }
                    completion(.success(todos))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

private struct TodosResponse: Codable {
    let todos: [TodoResponse]
}

private struct TodoResponse: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
