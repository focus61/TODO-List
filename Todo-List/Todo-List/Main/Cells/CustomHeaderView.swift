//
//  CustomHeaderView.swift
//  Todo-List
//
//  Created by Aleksandr on 05.08.2022.
//

import UIKit
protocol ShowAndHideDoneTasksDelegate {
    func show(newItem: [TodoItem])
    func hide(newItem: [TodoItem])
}

final class CustomHeaderView: UITableViewHeaderFooterView {
    static let identifier = "CustomHeaderView"
    private let countTaskLabel = UILabel()
    var delegate: ShowAndHideDoneTasksDelegate?
    private let showHideButton = UIButton()
    private var isShow = true
    private var allTask = [TodoItem]()
    private let showHideButtonWidth: CGFloat = 100
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: CustomHeaderView.identifier)
        countTaskLabelConfigure()
        showHideButtonConfigure()
        let color = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).blue
        })
        showHideButton.setTitleColor(color, for: .normal)
        countTaskLabel.textColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).labelTertiary
        })
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
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showHideButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            showHideButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WindowInsetConstants.trailing.value),
            showHideButton.widthAnchor.constraint(equalToConstant: showHideButtonWidth)
        ])
        showHideButton.contentVerticalAlignment = .center
        showHideButton.contentHorizontalAlignment = .right
        showHideButton.addTarget(self, action: #selector(showHide), for: .touchUpInside)
    }
    
    @objc private func showHide() {
        if isShow {
            delegate?.show(newItem: allTask)
        } else {
            let newArray = allTask.filter { $0.isTaskComplete == false }
            delegate?.hide(newItem: newArray)
        }
        isShow.toggle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomHeaderView {
    func fillData(countTaskComplete: Int, allTask: [TodoItem], isShowButton: Bool) {
        if isShowButton {
            showHideButton.setTitle("Показать", for: .normal)
        } else {
            showHideButton.setTitle("Скрыть", for: .normal)
        }
        isShow = isShowButton
        countTaskLabel.text = "Выполнено - \(countTaskComplete)"
        self.allTask = allTask
    }
}
