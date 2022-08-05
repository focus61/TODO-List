//
//  FileCache.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import Foundation
//Сделать поправки в др файлах где идет вызов функций
enum FileCacheError: Error {
    case loadError(String)
    case saveError(String)
}
final class FileCache {
    static let fileName = "JSON"

    private(set) var todoItems: [String : TodoItem]
    init(todoItems: [String : TodoItem] = [:]) {
        self.todoItems = todoItems
    }
    
    func addTask(item: TodoItem) {
        todoItems[item.id] = item
    }
    func updateTask(item: TodoItem) {
        todoItems.updateValue(item, forKey: item.id)
    }
    
    func deleteTask(id: String) {
        todoItems.removeValue(forKey: id)
    }
    
    func saveToFile(_ fileName: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileCacheError.saveError("Ошибка сохранения в файл")
        }
        let file = documentDirectory.appendingPathComponent(fileName)
        let jsonArray = todoItems.map { _, item in
            item.json as? [String: Any]
        }
        guard let writeToFile = try? JSONSerialization.data(withJSONObject: jsonArray, options: []) else {
            throw FileCacheError.saveError("Ошибка сохранения в файл")
        }
            try? writeToFile.write(to: file)
        print("writeToFile.write(to: file)")

    }
    func loadFromFile(_ fileName: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let file = documentDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: file),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        else {
            throw FileCacheError.loadError("Ошибка загрузки из файла")
        }
        self.todoItems = jsonArray.reduce(into: [String: TodoItem]()) {
            if let item = TodoItem.parse(json: $1) {
                $0[item.id] = item
            }
        }
    }
}
