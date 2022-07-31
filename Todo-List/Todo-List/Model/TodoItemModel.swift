//
//  TodoItemModel.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import Foundation
enum ImportantType {
    case unimportant
    case basic
    case important
}
struct TodoItem {
    let identifier: String?
    let text: String
    let important: ImportantType
    let deadLine: Date?
    let isTaskComplete: Bool
    let addTaskDate: Date
    let changeTaskDate: Date?
    
    init(identifier: String? = UUID().uuidString,
         text: String,
         important: ImportantType = .basic,
         deadline: Date? = nil,
         isTaskComplete: Bool,
         addTaskDate: Date,
         changeTaskDate: Date? = nil)
    {
        if identifier == nil {
            self.identifier = UUID().uuidString
        } else {
            self.identifier = identifier
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
            let json = try? JSONSerialization.data(withJSONObject: json),
            let jsonSerilization = try? JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let identifier = jsonSerilization["identifier"] as? String,
            let text = jsonSerilization["text"] as? String,
            let isTaskCompleteValue = jsonSerilization["isTaskComplete"] as? Int,
            let addTaskDateValue = jsonSerilization["addTaskDate"] as? TimeInterval
        else {return nil}

        let isTaskComplete = isTaskCompleteValue == 0 ? false : true

        let addTaskDate = Date(timeIntervalSince1970: addTaskDateValue)
        
        var important: ImportantType = .basic
        if let importantValue = jsonSerilization["important"] as? Int {
            important = importantValue == 0 ? .important : .unimportant
        }
        
        var deadline: Date?
        if let deadlineValue = jsonSerilization["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineValue)
        }
        
        var changeTaskDate: Date?
        if let changeTaskDateValue = jsonSerilization["changeTaskDate"] as? TimeInterval {
            changeTaskDate = Date(timeIntervalSince1970: changeTaskDateValue)
        }
        let newObject = TodoItem(identifier: identifier,
                                 text: text,
                                 important: important,
                                 deadline: deadline,
                                 isTaskComplete: isTaskComplete,
                                 addTaskDate: addTaskDate,
                                 changeTaskDate: changeTaskDate)

        return newObject
    }
    
    public var json: Any? {
        let isTaskCompleteValue = isTaskComplete ? 0 : 1
        var object: [String: Any] = ["identifier" : "\(identifier)",
                                     "text": "\(text)",
                                     "isTaskComplete": isTaskCompleteValue,
                                     "addTaskDate": addTaskDate.timeIntervalSince1970
                                    ]
        switch important {
            case .important:        object["important"] = 0
            case .unimportant:      object["important"] = 1
            default: break
        }
        
        if let changeTaskDate = changeTaskDate {
            object["changeTaskDate"] = changeTaskDate.timeIntervalSince1970
        }
        
        if let deadLine = deadLine  {
            object["deadline"] = deadLine.timeIntervalSince1970
        }
        return object
    }
}
