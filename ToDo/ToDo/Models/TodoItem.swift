//
//  TodoItem.swift
//  ToDo
//
//  Created by DISSEMBILL on 21.05.2025.
//

import Foundation
import CoreData

struct TodoItem: Identifiable, Codable {
    let id: Int
    var title: String
    var description: String?
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: Int, title: String, description: String? = nil, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    init(from entity: TodoItemEntity) {
        self.id = Int(entity.id)
        self.title = entity.title ?? ""
        self.description = entity.taskDescription
        self.isCompleted = entity.isCompleted
        self.createdAt = entity.createdAt ?? Date()
    }
}

extension TodoItem {
    func toEntity(in context: NSManagedObjectContext) -> TodoItemEntity {
        let entity = TodoItemEntity(context: context)
        entity.id = Int64(id)
        entity.title = title
        entity.taskDescription = description
        entity.isCompleted = isCompleted
        entity.createdAt = createdAt
        return entity
    }
}
