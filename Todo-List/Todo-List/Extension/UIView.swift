//
//  UIView.swift
//  Todo-List
//
//  Created by Aleksandr on 06.08.2022.
//

import UIKit

extension UILabel {
    func createImageWithLabelView(imageView: UIImageView) {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 15),
            imageView.widthAnchor.constraint(equalToConstant: 10),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
//            label.topAnchor.constraint(equalTo: view.topAnchor),
//            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
//            label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
