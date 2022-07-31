//
//  TextViewCollectionItem.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import UIKit
class TextViewCollectionItem: UICollectionViewCell {
    static let identifier = "TextViewCollectionItem"
    let textView: UITextView = .init(frame: .zero)
    var isHeightCalculated = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        textViewConfigure()
        contentView.backgroundColor = .blue
    }
    
    func textViewConfigure() {
        contentView.addSubview(textView)
        textView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        textView.backgroundColor = .green
        textView.font = CustomFont.body
        textView.text = "Что надо сделать?"
        textView.layer.cornerRadius = 20
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .blue
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

        required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
