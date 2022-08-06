//
//  CustomHeaderView.swift
//  Todo-List
//
//  Created by Aleksandr on 05.08.2022.
//

import UIKit

final class CustomHeaderView: UITableViewHeaderFooterView {
    static let identifier = "CustomHeaderView"
    private let countTaskLabel = UILabel()
    var delegate: ShowAndHide?
    private let showHideButton = UIButton(type: .system)
    private var displayMode: DisplayMode = .lightMode
    private var isShow = true
    private var allTask = [TodoItem]()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: CustomHeaderView.identifier)
        countTaskLabelConfigure()
        showHideButtonConfigure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let color = CustomColor(displayMode: displayMode).blue
        showHideButton.setTitleColor(color, for: .normal)
        countTaskLabel.textColor = CustomColor(displayMode: displayMode).labelTertiary
    }
    
    private func countTaskLabelConfigure() {
        contentView.addSubview(countTaskLabel)
        countTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countTaskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            countTaskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WindowInsetConstants.trailing.value)
        ])
        countTaskLabel.font = CustomFont.subhead
    }
    
    private func showHideButtonConfigure() {
        contentView.addSubview(showHideButton)
        showHideButton.setTitle("Показать", for: .normal)
        showHideButton.setTitleColor(.blue, for: .normal)
        showHideButton.setTitleColor(.gray, for: .highlighted)
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showHideButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            showHideButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WindowInsetConstants.trailing.value),
            showHideButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        showHideButton.contentVerticalAlignment = .center
        showHideButton.contentHorizontalAlignment = .right
        showHideButton.addTarget(self, action: #selector(showHide), for: .touchUpInside)
    }
    
    @objc private func showHide() {
        isShow.toggle()
        if !isShow {
            showHideButton.setTitle("Скрыть", for: .normal)
            delegate?.show(newItem: allTask)
        } else {
            let newArray = allTask.filter { $0.isTaskComplete == false }
            showHideButton.setTitle("Показать", for: .normal)
            delegate?.hide(newItem: newArray)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomHeaderView {
    func fillData(countTaskComplete: Int, displayMode: DisplayMode, allTask: [TodoItem]) {
        countTaskLabel.text = "Выполнено - \(countTaskComplete)"
        self.allTask = allTask
        self.displayMode = displayMode
    }
}
