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
    private var displayMode: DisplayMode = .lightMode
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: AddTaskCell.identifier)
        labelConfigure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        contentView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        newTaskLabel.textColor = CustomColor(displayMode: displayMode).supportSeparator
    }
    
    private func labelConfigure() {
        contentView.addSubview(newTaskLabel)
        newTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        let leftInset = InsetConstants.horizontalInsetBetweenElements.value + WindowInsetConstants.leading.value + leftInsetSizeButton
        NSLayoutConstraint.activate([
            newTaskLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: InsetConstants.verticalInsetBetweenElements.value),
            newTaskLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor),
            newTaskLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -InsetConstants.verticalInsetBetweenElements.value),
            newTaskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftInset)
        ])
        newTaskLabel.text = "Новое"
        newTaskLabel.font = CustomFont.body
    }
    
    func fillData(displayMode: DisplayMode) {
        self.displayMode = displayMode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
