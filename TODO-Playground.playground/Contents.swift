import Foundation
/*
struct TodoItem {
    enum ImportantType {
        case unimportant
        case basic
        case important
    }
    let identifier: String
    let text: String
    let important: ImportantType
    let deadLine: Date?
    let isTaskComplete: Bool
    let addTaskDate: Date
    let changeTaskDate: Date?
    
    init(identifier: String = UUID().uuidString,
         text: String,
         important: ImportantType = .basic,
         deadline: Date? = nil,
         isTaskComplete: Bool,
         addTaskDate: Date,
         changeTaskDate: Date? = nil)
    {
        self.identifier = identifier
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
final class FileCache {
    private(set) var todoItems: [String : TodoItem]
    init(todoItems: [String : TodoItem] = [:]) {
        self.todoItems = todoItems
    }
    
    public func addTask(item: TodoItem, id: String) {
        if todoItems[id] != nil {
            return
        }
        todoItems[id] = item
    }
    
    public func deleteTask(id: String) {
        todoItems.removeValue(forKey: id)
    }
    
    public func saveToFile(_ fileName: String) {
        if todoItems.isEmpty {return}
        let newFolderName = "Testing Folder"
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let newFolder = documentDirectory.appendingPathComponent(newFolderName)
        try? FileManager.default.createDirectory(at: newFolder, withIntermediateDirectories: true)
        let file = newFolder.appendingPathComponent(fileName)
        let jsonArray = todoItems.map { key, item in
            item.json as? [String: Any]
        }
        guard let writeToFile = try? JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted]) else {return}
        try? writeToFile.write(to: file)
    }
    
    public func loadFromFile(_ fileName: String) {
        let newFolderName = "Testing Folder"
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let newFolder = documentDirectory.appendingPathComponent(newFolderName)
        let file = newFolder.appendingPathComponent(fileName)
        var loadArray = [String : TodoItem]()
        guard let data = try? Data(contentsOf: file),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        else {return}
//        let itemArray = jsonArray.map { val in
            
        
            
//        for json in JSONArray {
//                if let item = TodoItem.parse(json: json) {
//                    loadArray[item.identifier] = item
//                }
//            }
//        self.todoItems = loadArray
    }
}

//MARK: - Testing -
let first = TodoItem(text: "Первый", isTaskComplete: true, addTaskDate: Date())
let second = TodoItem(identifier: "ABCDEFG",text: "Второй", isTaskComplete: true, addTaskDate: Date())
let third = TodoItem(identifier: "VBNM",text: "Третий", isTaskComplete: true, addTaskDate: Date())
let fileCache = FileCache(todoItems: [first.identifier: first])

fileCache.addTask(item: second, id: second.identifier)
print(fileCache.todoItems)
fileCache.saveToFile("MYJSON")

//fileCache.deleteTask(id: first.identifier)
//print("AFTER DELETE\n", fileCache.todoItems)
//
//fileCache.addTask(item: third, id: third.identifier)
//print("AFTER ADD\n", fileCache.todoItems)
//
////fileCache.saveToFile("SECOND")
//print("\n\nSECOND\n\n",fileCache.todoItems)
//
fileCache.loadFromFile("MYJSON")
print("\n\nLOAD MY JSON\n\n",fileCache.todoItems)
//
//fileCache.loadFromFile("SECOND")
//print("\n\nLOAD SECOND\n\n",fileCache.todoItems)
//
//fileCache.deleteTask(id: second.identifier)
//fileCache.deleteTask(id: third.identifier)
//
//print("\n\nDELETE ALL\n\n",fileCache.todoItems)
//
//fileCache.loadFromFile("SECOND")
//print("\n\nLOAD SECOND\n\n",fileCache.todoItems)
//
//fileCache.saveToFile("MYJSON")


*/

var s = false
var d = false
var all = s && d {
    didSet {
        print("YES")
    }
}

