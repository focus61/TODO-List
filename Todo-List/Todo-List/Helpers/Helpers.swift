//
//  Helpers.swift
//  Todo-List
//
//  Created by Aleksandr on 03.08.2022.
//

import UIKit
class Helpers {
    static let shared = Helpers()
    func addAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
}
