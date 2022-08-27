//
//  NetworkService.swift
//  Todo-List
//
//  Created by Aleksandr on 17.08.2022.
//

import Foundation
import CocoaLumberjack
protocol NetworkServiceProtocol {
    func getAllTodoItems(
        completion: @escaping (Result<[TodoItem], NetworkError>) -> Void
    )
    func addTodoItem(
        item: TodoItem,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    func getTodoItem(
        id: String,
        completion: @escaping (Result<TodoItem, NetworkError>) -> Void
    )
    func editTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, NetworkError>) -> Void
    )
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, NetworkError>) -> Void
    )
    func updateTodoItems(
        items: [TodoItem],
        completion: @escaping (Result<[String: TodoItem], NetworkError>) -> Void
    )
}
class NetworkService {
    private enum Const: String {
        case get, patch, post, put, delete
        var value: String {
            return rawValue.uppercased()
        }
    }
    private let host = "https://beta.mrdekk.ru/todobackend"
    private let list = "/list"
    private let bearerToken = "Bearer CompactAdviceOnUnwelcomeDisplays"
    var revision: Int32 = 0
    var userDefaultsSettings = UserDefaultsSettings()
    private var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 10.0
        return URLSession(configuration: sessionConfig)
    }()
}
extension NetworkService: NetworkServiceProtocol {
    func updateTodoItems(items: [TodoItem], completion: @escaping (Result<[String: TodoItem], NetworkError>) -> Void) {
        DispatchQueue.global().async {
            let networkModelTodo = items.map { $0.parseToNetworkModel() }
            let networkModel = NetworkModel(status: "ok", list: networkModelTodo, revision: self.revision)
            do {
                let jsonData = try? JSONEncoder().encode(networkModel)
                guard
                    let request = self.createrRequest(fromPenString: self.list,
                                                   withMethod: Const.patch.value,
                                                   isNeededRevision: true,
                                                   body: jsonData)
                else {
                    return
                }
                self.session.dataTask(with: request) { [weak self] data, response, error in
                    guard let self = self else { return }
                    if let error = error {
                        let currentError = self.checkError(currentError: error)
                        completion(.failure(currentError))
                    }
                    guard let data = data else { return }
                    do {
                        let json = try JSONDecoder().decode(NetworkModel.self, from: data)
                        let allItemsFromServer = json.list.reduce(into: [String: TodoItem]()) {
                            $0[$1.id] = $1.parseToItem()
                        }
                        self.revision = json.revision ?? 0
                        self.userDefaultsSettings.setRevisionValue(value: json.revision ?? 0)
                        completion(.success((allItemsFromServer)))
                    } catch {
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                        }
                    }
                }.resume()
            }
        }
    }
    
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], NetworkError>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            guard let request = self.createrRequest(fromPenString: self.list,
                                               withMethod: Const.get.value)
            else {
                completion(.failure(NetworkError.incorrectUrl))
                return
            }
            self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                if let error = error {
                    let currentError = self.checkError(currentError: error)
                    completion(.failure(currentError))
                }
                guard let data = data else { return }
                do {
                    let json = try JSONDecoder().decode(NetworkModel.self, from: data)
                    self.revision = json.revision ?? 0
                    let newItem = json.list.map { $0.parseToItem() }
                    DispatchQueue.main.async {
                        print("Success get all")
                        completion(.success(newItem))
                    }
                } catch {
                    if let httpResponse = response as? HTTPURLResponse {
                        completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                    }
                }
            }.resume()
        }
    }
    
    func getTodoItem(id: String, completion: @escaping (Result<TodoItem, NetworkError>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let request = self.createrRequest(fromPenString: self.list, withMethod: Const.get.value, isNeededRevision: false, body: nil) else { return }
            DispatchQueue.global().async {
                self.session.dataTask(with: request) { [weak self] data, response, error in
                    guard let self = self else { return }
                    if let error = error {
                        let currentError = self.checkError(currentError: error)
                        completion(.failure(currentError))
                    }
                    guard let data = data else {
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                        }
                        return
                    }
                    do {
                        let json = try JSONDecoder().decode(NetworkModelForOneItem.self, from: data)
                        DispatchQueue.main.async {
                            let getElement = json.element.parseToItem()
                            self.revision = json.revision ?? 0
                            completion(.success(getElement))
                        }
                    } catch {
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                        }
                    }
                }.resume()
            }
        }
    }
    
    func addTodoItem(item: TodoItem, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let item = item.parseToNetworkModel()
            let networkModel = NetworkModelForOneItem(element: item, revision: nil)
            do {
                guard
                    let jsonData = try? JSONEncoder().encode(networkModel),
                    let request = self.createrRequest(fromPenString: self.list,
                                                 withMethod: Const.post.value,
                                                 isNeededRevision: true,
                                                 body: jsonData)
                else {
                    completion(.failure(NetworkError.incorrectUrl))
                    return
                }
                let decode = try? JSONDecoder().decode(NetworkModelForOneItem.self, from: jsonData)
                print(decode!)
                self.session.dataTask(with: request) { [weak self] data, response, error in
                    guard let self = self else { return }
                    if let error = error {
                        let currentError = self.checkError(currentError: error)
                        completion(.failure(currentError))
                    }
                    guard let data = data  else {
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                        }
                        return
                    }
                    do {
                        let json = try JSONDecoder().decode(NetworkModelForOneItem.self, from: data)
                        DispatchQueue.main.async {
                            self.revision = json.revision ?? 0
                            self.userDefaultsSettings.setRevisionValue(value: self.revision)
                            completion(.success(()))
                        }
                    } catch {
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                        }
                    }
                }.resume()
            }
        }
    }
    
    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, NetworkError>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let networkModel = NetworkModelForOneItem(element: item.parseToNetworkModel(), revision: nil)
            do {
                guard
                    let jsonData = try? JSONEncoder().encode(networkModel),
                    let request = self.createrRequest(fromPenString: self.list + "/\(item.id)",
                                                 withMethod: Const.put.value,
                                                 isNeededRevision: true,
                                                 body: jsonData)
                else { return }
                self.session.dataTask(with: request) { [weak self] data, response, error in
                    guard let self = self else { return }
                    if let error = error {
                        let currentError = self.checkError(currentError: error)
                        completion(.failure(currentError))
                    }
                    guard let data = data else {
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                        }
                        return
                    }
                    do {
                        let json = try JSONDecoder().decode(NetworkModelForOneItem.self, from: data)
                        DispatchQueue.main.async {
                            self.revision = json.revision ?? 0
                            self.userDefaultsSettings.setRevisionValue(value: self.revision)
                            completion(.success(json.element.parseToItem()))
                        }
                    } catch {
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                        }
                    }
                }.resume()
            }
        }
    }
    
    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, NetworkError>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let request = self.createrRequest(fromPenString: self.list + "/\(id)", withMethod: Const.delete.value, isNeededRevision: true) else {
                return
            }
            self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                if let error = error {
                    let currentError = self.checkError(currentError: error)
                    completion(.failure(currentError))
                }
                guard let data = data else {
                    if let httpResponse = response as? HTTPURLResponse {
                        completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                    }
                    return
                }
                do {
                    let json = try JSONDecoder().decode(NetworkModelForOneItem.self, from: data)
                    self.revision = json.revision ?? 0
                    self.userDefaultsSettings.setRevisionValue(value: self.revision)
                    completion(.success(json.element.parseToItem()))
                } catch {
                    if let httpResponse = response as? HTTPURLResponse {
                        completion(.failure(NetworkError.serverError(code: httpResponse.statusCode)))
                    }
                }
            }.resume()
        }
    }
    
    private func checkError(currentError: Error) -> NetworkError {
        if (currentError as NSError).code == NSURLErrorTimedOut {
            return NetworkError.internetError
        } else if (currentError as NSError).code == -1002 {
            return NetworkError.incorrectUrl
        }
        return NetworkError.internetError
    }
    
    private func createrRequest(fromPenString: String, withMethod: String, isNeededRevision: Bool = false, body: Data? = nil) -> URLRequest? {
        let currentUrl = host + fromPenString
        guard let url = URL(string: currentUrl) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
        request.httpMethod = withMethod
        if isNeededRevision {
            request.addValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }
        guard let data = body else { return request }
        request.httpBody = data
        return request
    }
}
