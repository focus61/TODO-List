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
    let revision: Int32?
}

struct NetworkModelForOneItem: Codable {
    let element: NetworkTodoItem
    let revision: Int32?
}

/*
{
  "element": {
    "id": "shit",
    "text": "blablabla",
    "importance": "low",
    "deadline": 1660744172,
    "done": true,
    "created_at": 1660744172,
    "changed_at": 1660744172,
    "last_updated_by": "fuck"
  },
  "revision": 0
}
*/

struct NetworkTodoItem: Codable {
    let id: String
    let text: String
    let important: String
    let deadline: Int64?
    let done: Bool
    let color: String?
    let createdAt: Int64
    let changedAt: Int64
    let lastUpdatedBy: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case text = "text"
        case important = "importance"
        case deadline = "deadline"
        case done = "done"
        case color = "color"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
    
    func parseToItem() -> TodoItem {
        var itemImportant: ImportantType = .basic
        switch important {
        case "low" : itemImportant = .unimportant
        case "basic" : itemImportant = .basic
        case "important" : itemImportant = .important
        default:
            break
        }
        var itemDeadline: Date?
        if let deadline = deadline {
            itemDeadline = convertDate(withInt: deadline)
        }
        return TodoItem(id: id,
                        text: text,
                        important: itemImportant,
                        deadline: itemDeadline,
                        isTaskComplete: done,
                        addTaskDate: convertDate(withInt: createdAt),
                        changeTaskDate: convertDate(withInt: changedAt))
    }
    
    private func convertDate(withInt: Int64) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(withInt))
    }
}
