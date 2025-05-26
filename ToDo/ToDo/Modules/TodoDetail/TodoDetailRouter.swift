//
//  TodoDetailRouter.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation

protocol TodoDetailRouterProtocol: AnyObject {
    func dismiss()
}

class TodoDetailRouter: TodoDetailRouterProtocol {
    var view: TodoDetailView?

    static func createModule(with todo: TodoItem?) -> TodoDetailView {
        let view = TodoDetailView(presenter: TodoDetailPresenter())
        let presenter = view.presenter
        let interactor = TodoDetailInteractor(
            databaseService: DatabaseService(),
            todo: todo
        )
        let router = TodoDetailRouter()
        router.view = view
        
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        if todo != nil {
            presenter.todo = todo
        }
        return view
    }
    
    func dismiss() {
        print("Dismiss ToDo Detail View")
    }
}
