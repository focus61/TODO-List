//
//  UIViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 13.08.2022.
//

import UIKit

extension UIViewController {
    func addAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
}
