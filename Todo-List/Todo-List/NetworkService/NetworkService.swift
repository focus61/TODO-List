//
//  NetworkService.swift
//  Todo-List
//
//  Created by Aleksandr on 14.08.2022.
//

import Foundation

protocol NetworkServiceProtocol: AnyObject {
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
}

class NetworkService { }
