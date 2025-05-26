//
//  TodoListRouter.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation
import SwiftUI

protocol TodoListRouterProtocol: AnyObject {
    func presentTodoDetail(_ todo: TodoItem?) -> TodoDetailView?
}

class TodoListRouter: TodoListRouterProtocol {

    func presentTodoDetail(_ todo: TodoItem?) -> TodoDetailView? {
        return TodoDetailRouter.createModule(with: todo)
    }
    
    static func createModule(databaseService: DatabaseServiceProtocol,
                           networkService: NetworkServiceProtocol) -> some View {
        let interactor = TodoListInteractor(
            networkService: networkService,
            databaseService: databaseService
        )
        let router = TodoListRouter()
        let presenter = TodoListPresenter(interactor: interactor, router: router)
        let view = TodoListView(presenter: presenter)
        
        interactor.presenter = presenter
        presenter.loadInitialData()
        
        return view
    }
}
