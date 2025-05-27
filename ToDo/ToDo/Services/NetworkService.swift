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
    var session: URLSession
    var endPoint = "https://dummyjson.com/todos"
    
    init() {
        self.session = URLSession.shared
    }
    
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: endPoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            DispatchQueue.global(qos: .background).async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                if data.isEmpty {
                    completion(.failure(NetworkError.noData))
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
