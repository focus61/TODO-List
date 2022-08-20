//
//  NetworkService.swift
//  Todo-List
//
//  Created by Aleksandr on 17.08.2022.
//

import Foundation
protocol NetworkServiceProtocol {
    // Получить
    // Обновить
    // Получить элемент списка
    // Добавить элемент списка
    // Изменить элемент списка
    // Удалить элемент списка
    
    func getAllTodoItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )
    func editTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
    func addTodoItem(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func updateTodoItem(
        revision: Int32,
        completion: @escaping (Result<Void, Error>) -> Void
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
    private let token = "CompactAdviceOnUnwelcomeDisplays"
    private let session = URLSession.shared
}

extension NetworkService: NetworkServiceProtocol {
    func updateTodoItem(revision: Int32, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: host + list) else { return }
        var urlRequest = URLRequest(url: url)
        let token = "Bearer " + token
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        urlRequest.httpMethod = Const.patch.value
        let myBody = 
        urlRequest.httpBody = myBody
        DispatchQueue.global().async {
            self.session.dataTask(with: urlRequest) { datas, responses, error in
                guard let data = datas else {
                    return
                }
                do {
                    
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch {
                    //Обработать ошибку
                    print(error)
                }
            }.resume()

        }
    }
    
    func addTodoItem(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        let id = "/\(id)"
//        guard let url = URL(string: host + list + id) else { return }
//        var urlRequest = URLRequest(url: url)
//        let token = "Bearer " + token
//        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
//        urlRequest.setValue(<#T##value: String?##String?#>, forHTTPHeaderField: <#T##String#>)
//        urlRequest.httpMethod = Const.post.value

        
    }
    
    
    func getAllTodoItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: host + list) else { return }
        var urlRequest = URLRequest(url: url)
        let token = "Bearer " + token
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = Const.get.value
        session.dataTask(with: urlRequest) { datas, responses, error in
            guard let data = datas else {
                return
            }
            do {
                let jsonData = try self.decodeFromJson(data: data)
            } catch {
                //Обработать ошибку
                print(error)
            }
        }.resume()
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        
    }

    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        
    }
    
    private func encodeFromItem(item: NetworkTodoItem) throws -> Data? {
        let encoder = JSONEncoder()
        let upload = try? encoder.encode(item)
        return upload
    }
    
    private func decodeFromJson(data: Data) throws -> NetworkModel? {
        let decoder = JSONDecoder()
        let json = try? decoder.decode(NetworkModel.self, from: data)
        return json
    }

}
