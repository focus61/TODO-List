//
//  FileCache.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import Foundation
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
        print(documentDirectory,"\n", newFolder, "\n", file)
        var JSONArray = [[String: Any]]()
        for item in todoItems {
            guard let json = item.value.json as? [String: Any] else {return}
            JSONArray.append(json)
        }
        guard let writeToFile = try? JSONSerialization.data(withJSONObject: JSONArray, options: [.prettyPrinted]) else {return}
        try? writeToFile.write(to: file)
    }
    
    public func loadFromFile(_ fileName: String) {
        let newFolderName = "Testing Folder"
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let newFolder = documentDirectory.appendingPathComponent(newFolderName)
        let file = newFolder.appendingPathComponent(fileName)
        var loadArray = [String : TodoItem]()
        guard let data = try? Data(contentsOf: file),
              let JSONArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        else {return}
        for json in JSONArray {
                if let item = TodoItem.parse(json: json) {
                    let id = item.identifier
                    loadArray[id] = item
                }
            }
        self.todoItems = loadArray
    }
    public func removeFile(_ fileName: String) {
        let newFolderName = "Testing Folder"
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let newFolder = documentDirectory.appendingPathComponent(newFolderName)
        let file = newFolder.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: file)
        self.todoItems = [:]
    }
}
