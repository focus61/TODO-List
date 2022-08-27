//
//  NetworkError.swift
//  Todo-List
//
//  Created by Aleksandr on 25.08.2022.
//

import Foundation

enum NetworkError: Error {
    case incorrectUrl
    case internetError
    case serverError(code: Int)
}
extension NetworkError {
    private func codeDescription(code: Int) -> String {
        switch code {
        case 400:
            return "Неверно сформирован запрос"
        case 401:
            return "Ошибка авторизации"
        case 404:
            return "Элемент на сервере не найден"
        default:
            return "Ошибка сервера"
        }
    }
}
extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incorrectUrl:
            return NSLocalizedString(
                "Некорректный URL",
                comment: "bad url"
            )
        case .internetError:
            return NSLocalizedString(
                "Ошибка интернет соединения",
                comment: "badConnect"
            )
        case .serverError(let errorCode):
            let codeDescription = codeDescription(code: errorCode)
            return NSLocalizedString(
                codeDescription + " (Ошибка \(errorCode))",
                comment: "serverError"
            )
        }
    }
}
