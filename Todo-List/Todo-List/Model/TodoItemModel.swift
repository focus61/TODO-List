//
//  TodoItemModel.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import Foundation
import UIKit
enum ImportantType {
    case unimportant
    case basic
    case important
}

struct TodoItem {
    let id: String
    let text: String
    let important: ImportantType
    let deadLine: Date?
    let isTaskComplete: Bool
    let addTaskDate: Date
    let changeTaskDate: Date?
    init(id: String = UUID().uuidString,
         text: String,
         important: ImportantType = .basic,
         deadline: Date? = nil,
         isTaskComplete: Bool = false,
         addTaskDate: Date,
         changeTaskDate: Date? = nil) {
        if id.isEmpty {
            self.id = UUID().uuidString
        } else {
            self.id = id
        }
        self.text = text
        self.important = important
        self.deadLine = deadline
        self.isTaskComplete = isTaskComplete
        self.addTaskDate = addTaskDate
        self.changeTaskDate = changeTaskDate
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard
            let json = json as? [String: Any],
            let identifier = json["identifier"] as? String,
            let text = json["text"] as? String,
            let isTaskCompleteValue = json["isTaskComplete"] as? Bool,
            let addTaskDateValue = json["addTaskDate"] as? TimeInterval
        else { return nil }

        let isTaskComplete = isTaskCompleteValue

        let addTaskDate = Date(timeIntervalSince1970: addTaskDateValue)
        
        var important: ImportantType = .basic
        if let importantValue = json["important"] as? Int {
            important = importantValue == 0 ? .important : .unimportant
        }
        
        var deadline: Date?
        if let deadlineValue = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineValue)
        }
        
        var changeTaskDate: Date?
        if let changeTaskDateValue = json["changeTaskDate"] as? TimeInterval {
            changeTaskDate = Date(timeIntervalSince1970: changeTaskDateValue)
        }
        let newObject = TodoItem(id: identifier,
                                 text: text,
                                 important: important,
                                 deadline: deadline,
                                 isTaskComplete: isTaskComplete,
                                 addTaskDate: addTaskDate,
                                 changeTaskDate: changeTaskDate)

        return newObject
    }
    
    var json: Any {
        let isTaskCompleteValue = isTaskComplete // исправлено
        var object: [String: Any] = ["identifier": id,
                                     "text": text,
                                     "isTaskComplete": isTaskCompleteValue,
                                     "addTaskDate": addTaskDate.timeIntervalSince1970
                                    ]
        switch important {
        case .important:
            object["important"] = 0
        case .unimportant:
            object["important"] = 1
        case .basic:
            break
        }
        if let changeTaskDate = changeTaskDate {
            object["changeTaskDate"] = changeTaskDate.timeIntervalSince1970
        }
        
        if let deadLine = deadLine {
            object["deadline"] = deadLine.timeIntervalSince1970
        }
        return object
    }
    
    func parseToNetworkModel() -> NetworkTodoItem {
        var importantString = ""
        switch important {
        case .unimportant : importantString = "low"
        case .basic  : importantString = "basic"
        case .important : importantString = "important"
        }
//        var itemDeadline: Date? = nil
//        if let deadline = deadline {
//            itemDeadline = convertDate(withInt: deadline)
//        }
        var networkDeadline: Int64?
        if let deadline = deadLine {
            networkDeadline = Int64(deadline.timeIntervalSince1970)
        }
        var changeTaskDateInt: Int64 = Int64(addTaskDate.timeIntervalSince1970)
        if let changeDate = changeTaskDate?.timeIntervalSince1970 {
            changeTaskDateInt = Int64(changeDate)
        }
        let deviceId = UIDevice.current.identifierForVendor?.uuidString

        return NetworkTodoItem(id: id,
                                       text: text,
                                       important: importantString,
                                       deadline: networkDeadline,
                                       done: isTaskComplete,
                                       color: nil,
                                       createdAt: Int64(addTaskDate.timeIntervalSince1970),
                                       changedAt: changeTaskDateInt,
                                       lastUpdatedBy: deviceId ?? "Some")
    }
}

extension TodoItem {
    func withComplete(_ isDone: Bool) -> TodoItem {
        return TodoItem(id: id, text: text, important: important, deadline: deadLine, isTaskComplete: isDone, addTaskDate: addTaskDate, changeTaskDate: changeTaskDate)
    }
}
