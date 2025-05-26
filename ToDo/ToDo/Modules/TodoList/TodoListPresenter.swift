//
//  TodoListPresenter.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation

protocol TodoListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectTodo(_ todo: TodoItem) -> TodoDetailView?
    func didTapAddTodo() -> TodoDetailView?
    func didTapDeleteTodo(_ id: Int)
    func didToggleTodoCompletion(_ todo: TodoItem)
    func loadInitialData()
}

class TodoListPresenter: TodoListPresenterProtocol, ObservableObject {
    var interactor: TodoListInteractorInputProtocol?
    var router: TodoListRouterProtocol?

    init(interactor: TodoListInteractorInputProtocol, router: TodoListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    @Published var todos: [TodoItem] = []
    
    func viewDidLoad() {
        interactor?.fetchTodos()
    }
    
    func didSelectTodo(_ todo: TodoItem) -> TodoDetailView? {
        return router?.presentTodoDetail(todo)
    }
    
    func didTapAddTodo() -> TodoDetailView? {
        return router?.presentTodoDetail(nil)
    }
    
    func didTapDeleteTodo(_ id: Int) {
        interactor?.deleteTodo(id)
    }
    
    func didToggleTodoCompletion(_ todo: TodoItem) {
        var updatedTodo = todo
        updatedTodo.isCompleted.toggle()
        interactor?.updateTodo(updatedTodo)
    }
    
    func loadInitialData() {
        interactor?.loadInitialData()
    }
}

extension TodoListPresenter: TodoListInteractorOutputProtocol {
    func didFetchTodos(_ todos: [TodoItem]) {
        DispatchQueue.main.async {
            self.todos = todos
        }
    }
    
    func didFail(with error: Error) {
        print("ToDo List error: \(error)")
    }
    
    func didDeleteTodo(with id: Int) {
        DispatchQueue.main.async {
            self.todos.removeAll { $0.id == id }
        }
    }
    
    func didUpdateTodo(_ todo: TodoItem) {
        DispatchQueue.main.async {
            if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                self.todos[index] = todo
            }
        }
    }
}
