//
//  TodoListInteractor.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation

protocol TodoListInteractorInputProtocol: AnyObject {
    func fetchTodos()
    func deleteTodo(_ id: Int)
    func updateTodo(_ todo: TodoItem)
    func loadInitialData()
}

protocol TodoListInteractorOutputProtocol: AnyObject {
    func didFetchTodos(_ todos: [TodoItem])
    func didFail(with error: Error)
    func didDeleteTodo(with id: Int)
    func didUpdateTodo(_ todo: TodoItem)
}

class TodoListInteractor: TodoListInteractorInputProtocol {
    weak var presenter: TodoListInteractorOutputProtocol?
    var networkService: NetworkServiceProtocol
    var databaseService: DatabaseServiceProtocol
    
    init(networkService: NetworkServiceProtocol, databaseService: DatabaseServiceProtocol) {
        self.networkService = networkService
        self.databaseService = databaseService
    }
    
    func fetchTodos() {
        databaseService.fetchTodos { [weak self] result in
            print("iteractor:fetchtodos")
            switch result {
            case .success(let todos):
                self?.presenter?.didFetchTodos(todos)
            case .failure(let error):
                self?.presenter?.didFail(with: error)
            }
        }
    }
    
    func deleteTodo(_ id: Int) {
        databaseService.deleteTodo(id) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.didDeleteTodo(with: id)
            case .failure(let error):
                self?.presenter?.didFail(with: error)
            }
        }
    }
    
    func updateTodo(_ todo: TodoItem) {
        databaseService.updateTodo(todo) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.didUpdateTodo(todo)
            case .failure(let error):
                self?.presenter?.didFail(with: error)
            }
        }
    }
    
    func loadInitialData() {
        databaseService.fetchTodos { [weak self] result in
            switch result {
            case .success(let todos):
                if todos.isEmpty {
                    self?.loadTodosFromAPI()
                } else {
                    self?.presenter?.didFetchTodos(todos)
                }
            case .failure:
                self?.loadTodosFromAPI()
            }
        }
    }
    
    private func loadTodosFromAPI() {
        networkService.fetchTodos { [weak self] result in
            switch result {
            case .success(let todos):
                self?.databaseService.saveTodos(todos) { saveResult in
                    switch saveResult {
                    case .success:
                        self?.fetchTodos()
                    case .failure(let error):
                        self?.presenter?.didFail(with: error)
                    }
                }
            case .failure(let error):
                self?.presenter?.didFail(with: error)
            }
        }
    }
}
