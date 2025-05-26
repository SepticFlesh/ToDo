//
//  DatabaseService.swift
//  ToDo
//
//  Created by DISSEMBILL on 21.05.2025.
//

import Foundation
import CoreData

protocol DatabaseServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func saveTodos(_ todos: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void)
    func createTodo(_ todo: TodoItem, completion: @escaping (Result<Void, Error>) -> Void)
    func updateTodo(_ todo: TodoItem, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTodo(_ id: Int, completion: @escaping (Result<Void, Error>) -> Void)
    func getNewTodoId() -> Int
}

class DatabaseService: DatabaseServiceProtocol {
    private let coreDataStack = CoreDataStack.shared
    private static var maxTodoId = 0
    
    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        coreDataStack.context.perform {
            let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            
            do {
                let entities = try self.coreDataStack.context.fetch(request)
                let todos = entities.map { TodoItem(from: $0) }
                DatabaseService.maxTodoId = todos.map { $0.id }.max() ?? 0
                completion(.success(todos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func saveTodos(_ todos: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataStack.context.perform {
            // First, delete all existing todos
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TodoItemEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.coreDataStack.context.execute(deleteRequest)
                
                // Then save new todos
                for todo in todos {
                    _ = todo.toEntity(in: self.coreDataStack.context)
                }
                
                try self.coreDataStack.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func createTodo(_ todo: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataStack.context.perform {
            _ = todo.toEntity(in: self.coreDataStack.context)
            do {
                try self.coreDataStack.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateTodo(_ todo: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataStack.context.perform {
            let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", todo.id)
            
            do {
                if let entity = try self.coreDataStack.context.fetch(request).first {
                    entity.title = todo.title
                    entity.taskDescription = todo.description
                    entity.isCompleted = todo.isCompleted
                    entity.createdAt = todo.createdAt
                    
                    try self.coreDataStack.context.save()
                    completion(.success(()))
                } else {
                    completion(.failure(DatabaseError.todoNotFound))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteTodo(_ id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataStack.context.perform {
            let request: NSFetchRequest<TodoItemEntity> = TodoItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                if let entity = try self.coreDataStack.context.fetch(request).first {
                    self.coreDataStack.context.delete(entity)
                    try self.coreDataStack.context.save()
                    completion(.success(()))
                } else {
                    completion(.failure(DatabaseError.todoNotFound))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getNewTodoId() -> Int {
        DatabaseService.maxTodoId += 1
        return DatabaseService.maxTodoId
    }
}

enum DatabaseError: Error {
    case todoNotFound
}
