//
//  TodoDetailInteractor.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation

protocol TodoDetailInteractorInputProtocol: AnyObject {
    func fetchTodo()
    func saveTodo(title: String, description: String?)
}

protocol TodoDetailInteractorOutputProtocol: AnyObject {
    func didFetchTodo(_ todo: TodoItem)
    func didSaveTodo(_ todo: TodoItem)
    func didFail(with error: Error)
}

class TodoDetailInteractor: TodoDetailInteractorInputProtocol {
    weak var presenter: TodoDetailInteractorOutputProtocol?
    var databaseService: DatabaseServiceProtocol
    var todo: TodoItem?
    
    init(databaseService: DatabaseServiceProtocol, todo: TodoItem?) {
        self.databaseService = databaseService
        self.todo = todo
    }
    
    func fetchTodo() {
        guard let todo = todo else { return }
        presenter?.didFetchTodo(todo)
    }
    
    func saveTodo(title: String, description: String?) {
        var todo = TodoItem(id: 0, title: title, description: description)
        let completion: (Result<Void, Error>) -> Void = { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.didSaveTodo(todo)
            case .failure(let error):
                self?.presenter?.didFail(with: error)
            }
        }
        
        if var existingTodo = self.todo {
            existingTodo.title = title
            existingTodo.description = description
            todo = existingTodo
            databaseService.updateTodo(todo, completion: completion)
        } else {
            let newTodo = TodoItem(
                id: databaseService.getNewTodoId(),
                title: title,
                description: description,
                isCompleted: false,
                createdAt: Date()
            )
            todo = newTodo
            databaseService.createTodo(newTodo, completion: completion)
        }
    }
}
