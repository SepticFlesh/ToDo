//
//  ToDoApp.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import SwiftUI

@main
struct TodoListAppApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListRouter.createModule(
                databaseService: DatabaseService(),
                networkService: NetworkService()
            )
        }
    }
}

//@main
//struct TodoListAppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TodoListView(presenter: TodoListPresenter())
//                .onAppear {
//                    let presenter = TodoListPresenter()
//                    presenter.interactor = TodoListInteractor(
//                        networkService: NetworkService(),
//                        databaseService: DatabaseService()
//                    )
//                    presenter.router = TodoListRouter()
//                    presenter.interactor?.presenter = presenter
//                    presenter.loadInitialData()
//                }
//        }
//    }
//}
