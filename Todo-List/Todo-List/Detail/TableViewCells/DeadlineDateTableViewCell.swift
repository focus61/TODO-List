//
//  DeadlineDateTableViewCell.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import UIKit
final class DeadlineDateTableViewCell: UITableViewCell {
    static let identifier = "DeadlineDateTableViewCell"
    private let deadlineLabel: UILabel = .init(frame: .zero)
    let deadlineSwitch: UISwitch = .init(frame: .zero)
    let changeDeadlineButton: UIButton = .init(type: .system)
    private var displayMode: DisplayMode = .lightMode
    private var deadlineIsOff = true
    private var constrainsLabel: [NSLayoutConstraint] = []
    private var constrainsButton: [NSLayoutConstraint] = []
    private var currentDateString = ""
    private var calendarIsOff = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ImportantTableViewCell.identifier)
        viewConfigure()
    }
    
    func fillData(displayMode: DisplayMode, deadlineIsOff: Bool, deadlineDate: Date, calendarIsOff: Bool) {
        if !deadlineIsOff {
            deadlineSwitch.isOn = true
        }
        self.displayMode = displayMode
        self.deadlineIsOff = deadlineIsOff
        
        if !deadlineIsOff {
            currentDateString = Date.currentDateFormatForDeadline(date: deadlineDate)
        }
        self.calendarIsOff = calendarIsOff
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        deadlineLabel.textColor = CustomColor(displayMode: displayMode).labelPrimary
        changeDeadlineButtonConfigure(deadlineIsOff: deadlineIsOff)
        labelConstraintsConfigure(deadlineIsOff: deadlineIsOff)
        if calendarIsOff {
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        deadlineSwitch.backgroundColor = CustomColor(displayMode: displayMode).backPrimary
        deadlineSwitch.layer.cornerRadius = 16.0
    }
    
    private func viewConfigure() {
        labelConfigure()
        changeDeadlineButtonConfigure(deadlineIsOff: deadlineIsOff)
        switchConfigure()
        selectionStyle = .none
    }
    
    private func labelConstraintsConfigure(deadlineIsOff: Bool) {
        NSLayoutConstraint.deactivate(constrainsLabel)
        if deadlineIsOff {
            constrainsLabel = [
                deadlineLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                deadlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                deadlineLabel.widthAnchor.constraint(equalToConstant: 100)
            ]
        } else {
            constrainsLabel = [
                deadlineLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -22),
                deadlineLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
                deadlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                deadlineLabel.widthAnchor.constraint(equalToConstant: 100)
            ]
        }
        NSLayoutConstraint.activate(constrainsLabel)
    }
    
    private func labelConfigure() {
        contentView.addSubview(deadlineLabel)
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        deadlineLabel.text = "Сделать до"
    }
    
    private func switchConfigure() {
        contentView.addSubview(deadlineSwitch)
        deadlineSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deadlineSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deadlineSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func changeDeadlineButtonConfigure(deadlineIsOff: Bool) {
        if !deadlineIsOff {
            contentView.addSubview(changeDeadlineButton)
            changeDeadlineButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                changeDeadlineButton.topAnchor.constraint(equalTo: contentView.centerYAnchor),
                changeDeadlineButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
                changeDeadlineButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11),
                changeDeadlineButton.widthAnchor.constraint(equalToConstant: 200)
            ])
            changeDeadlineButton.setTitle(currentDateString, for: .normal)
            changeDeadlineButton.titleLabel?.font = CustomFont.footnote
            changeDeadlineButton.contentVerticalAlignment = .center
            changeDeadlineButton.contentHorizontalAlignment = .left
        } else {
            changeDeadlineButton.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
