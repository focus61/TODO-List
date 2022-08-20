//
//  NetworkModel.swift
//  Todo-List
//
//  Created by Aleksandr on 17.08.2022.
//

import Foundation

struct NetworkModel: Codable {
    let status: String
    let list: [NetworkTodoItem]
    let revision: Int32
}
struct NetworkTodoItem: Codable {
    let id: String
    let text: String
    let important: String
    let deadline: Int
    let done: Bool
    let color: String?
    let createdAt: Int
    let changedAt: Int
    let lastUpdatedBy: Int
    
    private enum CodingKe: String, CodingKey {
        case id = "id"
        case text = "text"
        case importance = "importance"
        case deadline = "deadline"
        case done = "done"
        case color = "color"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"

    }
}
