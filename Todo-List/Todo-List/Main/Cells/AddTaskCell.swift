//
//  AddTaskCell.swift
//  Todo-List
//
//  Created by Aleksandr on 06.08.2022.
//

import UIKit

final class AddTaskCell: UITableViewCell {
    private let newTaskLabel = UILabel()
    static let identifier = "AddTaskCell"
    private let leftInsetSizeButton: CGFloat = 24
    lazy var leftInset = InsetConstants.horizontalInsetBetweenElements.value + WindowInsetConstants.leading.value + leftInsetSizeButton
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: AddTaskCell.identifier)
        labelConfigure()
        colorsConfigure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func colorsConfigure() {
        backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        contentView.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        newTaskLabel.textColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).supportSeparator
        })
    }
    private func labelConfigure() {
        contentView.addSubview(newTaskLabel)
        newTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newTaskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: InsetConstants.verticalInsetBetweenElements.value),
            newTaskLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor),
            newTaskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -InsetConstants.verticalInsetBetweenElements.value),
            newTaskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftInset)
        ])
        newTaskLabel.text = "Новое"
        newTaskLabel.font = CustomFont.body
    }
    
    func fillData() {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
