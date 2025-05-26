//
//  TodoListView.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation
import SwiftUI
import UIKit

struct TodoListView: View {
    @ObservedObject var presenter: TodoListPresenter
    
    @State private var searchText = ""
    @State private var showingAddTodo = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(presenter.todos.filter {
                    searchText.count == 0 ? true : ($0.title + ($0.description ?? "")).uppercased().contains(searchText.uppercased())
                }) { todo in
                    TodoRowView(todo: todo) {
                        presenter.didToggleTodoCompletion(todo)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            presenter.didTapDeleteTodo(todo.id)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        ShareLink(
                            "Поделиться",
                            item: todo.description == nil ? todo.title : "\(todo.title)\n\(String(describing: todo.description))",
                            preview: SharePreview("Export \(todo.title)")
                        )
                        NavigationLink(destination: presenter.didSelectTodo(todo)) {
                            Text("Редактировать")
                            Image(systemName: "square.and.pencil")
                        }
                    }
                    .contextMenu {
                        NavigationLink(destination: presenter.didSelectTodo(todo)) {
                            Text("Редактировать")
                            Image(systemName: "square.and.pencil")
                        }
                        ShareLink(
                            "Поделиться",
                            item: todo.description == nil ? todo.title : "\(todo.title)\n\(String(describing: todo.description))",
                            preview: SharePreview("Export \(todo.title)")
                        )
                        Button(role: .destructive, action: {
                            presenter.didTapDeleteTodo(todo.id)
                        }) {
                            HStack {
                                Text("Удалить")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }
            .searchable(text: $searchText)
            .navigationTitle("Задачи")
            .toolbar {
                Button {
                    showingAddTodo = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showingAddTodo, onDismiss: {
                presenter.interactor?.fetchTodos()
            }, content: {
                presenter.didTapAddTodo()
            })
            .onAppear {
                presenter.viewDidLoad()
            }
        }
    }
}

struct TodoRowView: View {
    @Environment(\.colorScheme) var colorScheme

    let todo: TodoItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Button {
                    onToggle()
                } label: {
                    Image(systemName: todo.isCompleted ? "checkmark.circle" : "circle")
                        .foregroundColor(todo.isCompleted ? .yellow : .gray)
                }
                .buttonStyle(.plain)
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.headline)
                    .foregroundColor(todo.isCompleted ? .gray : colorScheme == .dark ? .white : .black)
                    .strikethrough(todo.isCompleted)
                
                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(todo.isCompleted ? .gray : colorScheme == .dark ? .white : .black)
                        .strikethrough(todo.isCompleted)
                }
                
                Text(todo.createdAt.formatted())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
