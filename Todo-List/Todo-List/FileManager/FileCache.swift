//
//  FileCache.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import Foundation
import CocoaLumberjack

enum FileCacheError: Error {
    case loadError(String)
    case saveError(String)
}

protocol FileCacheService: AnyObject {
    func save(
        to file: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )
    func addTask(item: TodoItem)
    func deleteTask(id: String)
    func updateTask(item: TodoItem)
}

final class FileCache: FileCacheService {
    static let fileName = "JSON"
    private(set) var todoItems: [String: TodoItem]
    init(todoItems: [String: TodoItem] = [:]) {
        self.todoItems = todoItems
    }
    
    func addTask(item: TodoItem) {
        todoItems[item.id] = item
    }
    
    func deleteTask(id: String) {
        todoItems.removeValue(forKey: id)
    }
    
    func updateTask(item: TodoItem) {
        todoItems.updateValue(item, forKey: item.id)
    }

    func save(to file: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let thread = DispatchQueue.init(label: "save")
        thread.async {
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                completion(.failure(FileCacheError.saveError("Ошибка сохранения в файл")))
                return
            }
            let file = documentDirectory.appendingPathComponent(file)
            let jsonArray = self.todoItems.map { _, item in
                item.json as? [String: Any]
            }
            guard let writeToFile = try? JSONSerialization.data(withJSONObject: jsonArray, options: []) else {
                completion(.failure(FileCacheError.saveError("Ошибка сохранения в файл")))
                return
            }
            DDLogInfo(Thread.current)

            guard let write = try? writeToFile.write(to: file) else {
                completion(.failure(FileCacheError.saveError("Ошибка сохранения в файл")))
                return
            }
            DispatchQueue.main.async {
                DDLogInfo(Thread.current)
                completion(.success(write))
            }
        }
    }
    
    func load(from file: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            let thread = DispatchQueue.init(label: "load")
            thread.async {
                guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let file = documentDirectory.appendingPathComponent(file)
                guard let data = try? Data(contentsOf: file),
                      let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
                else {
                    completion(.failure(FileCacheError.loadError("Ошибка загрузки из файла")))
                    return
                }
                self.todoItems = jsonArray.reduce(into: [String: TodoItem]()) {
                    if let item = TodoItem.parse(json: $1) {
                        $0[item.id] = item
                    }
                }
                DispatchQueue.main.async {
                    let loadArray = self.todoItems.map { $0.value }.sorted(by: { val1, val2 in
                        val1.addTaskDate < val2.addTaskDate
                    })
                    completion(.success(loadArray))
                }
            }
        }
    }
}
