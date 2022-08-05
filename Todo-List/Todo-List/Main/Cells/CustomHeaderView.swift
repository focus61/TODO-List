//
//  CustomHeaderView.swift
//  Todo-List
//
//  Created by Aleksandr on 05.08.2022.
//

import UIKit


class CustomHeaderView: UITableViewHeaderFooterView {
    static let identifier = "CustomHeaderView"
    let countTaskLabel = UILabel()
    var delegate: Show?
    let showHideButton = UIButton(type: .system)
    var displayMode: DisplayMode = .lightMode
    var isShow = true
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: CustomHeaderView.identifier)
        contentView.addSubview(countTaskLabel)
        countTaskLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countTaskLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            countTaskLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 17),
            countTaskLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        countTaskLabel.font = CustomFont.subhead
 
        contentView.addSubview(showHideButton)
        showHideButton.setTitle("Показать", for: .normal)
        showHideButton.setTitleColor(.blue, for: .normal)
        showHideButton.setTitleColor(.gray, for: .highlighted)

        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showHideButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            showHideButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            showHideButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        showHideButton.contentVerticalAlignment = .center
        showHideButton.contentHorizontalAlignment = .right
        showHideButton.addTarget(self, action: #selector(showHide), for: .touchUpInside)
    }
    @objc func showHide() {
        isShow.toggle()
        if !isShow {
            showHideButton.setTitle("Скрыть", for: .normal)
        } else {
            showHideButton.setTitle("Показать", for: .normal)
        }

        delegate?.show()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let color = CustomColor(displayMode: displayMode).blue
        showHideButton.setTitleColor(color, for: .normal)
        countTaskLabel.textColor = CustomColor(displayMode: displayMode).labelTertiary
    }
    func fillData(countTaskComplete: Int, displayMode: DisplayMode) {
        countTaskLabel.text = "Выполнено - \(countTaskComplete)"
        self.displayMode = displayMode
    }
}

