//
//  TodoDetailPresenter.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation

protocol TodoDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSaveTodo(title: String, description: String?)
}

class TodoDetailPresenter: TodoDetailPresenterProtocol, ObservableObject {
    var interactor: TodoDetailInteractorInputProtocol?
    var router: TodoDetailRouterProtocol?
    
    var todo: TodoItem?
    var isEditing: Bool { todo != nil }
    
    func viewDidLoad() {
        if isEditing {
            interactor?.fetchTodo()
        }
    }
    
    func didSaveTodo(title: String, description: String?) {
        interactor?.saveTodo(title: title, description: description)
    }
}

extension TodoDetailPresenter: TodoDetailInteractorOutputProtocol {
    func didFetchTodo(_ todo: TodoItem) {
        DispatchQueue.main.async {
            self.todo = todo
        }
    }
    
    func didSaveTodo(_ todo: TodoItem) {
        DispatchQueue.main.async {
            self.router?.dismiss()
        }
    }
    
    func didFail(with error: Error) {
        print("ToDo Detail error: \(error)")
    }
}
