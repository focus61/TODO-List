//
//  DeadlineDateTableViewCell.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import UIKit
final class DeadlineDateTableViewCell: UITableViewCell {
    private enum Consts {
        case leadingInset
        case trailingInset
        case widthDeadlineLabel
        case changeDeadlineButtonWidth
        var value: CGFloat {
            switch self {
            case .trailingInset, .leadingInset:
                return 10
            case .widthDeadlineLabel:
                return 100
            case .changeDeadlineButtonWidth:
                return 200
            }
        }
    }
    static let identifier = "DeadlineDateTableViewCell"
    private let deadlineTopPointY: CGFloat = -22
    private let changeDeadlineButtonBottom: CGFloat = -5
    private let deadlineLabel: UILabel = .init(frame: .zero)
    let deadlineSwitch: UISwitch = .init(frame: .zero)
    let changeDeadlineButton: UIButton = .init(type: .system)
    private var deadlineIsOff = true
    private var constrainsLabel: [NSLayoutConstraint] = []
    private var constrainsButton: [NSLayoutConstraint] = []
    private var currentDateString = ""
    private var calendarIsOff = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ImportantTableViewCell.identifier)
        viewConfigure()
    }
    
    func fillData(deadlineIsOff: Bool, deadlineDate: Date, calendarIsOff: Bool) {
        if !deadlineIsOff {
            deadlineSwitch.isOn = true
        }
        self.deadlineIsOff = deadlineIsOff
        
        if !deadlineIsOff {
            currentDateString = Date.currentDateFormatForDeadline(date: deadlineDate)
        }
        self.calendarIsOff = calendarIsOff
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        changeDeadlineButtonConfigure(deadlineIsOff: deadlineIsOff)
        labelConstraintsConfigure(deadlineIsOff: deadlineIsOff)
        if calendarIsOff {
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        } else {
            separatorInset = UIEdgeInsets(top: 0, left: Consts.leadingInset.value, bottom: 0, right: Consts.trailingInset.value)
        }
        deadlineSwitch.layer.cornerRadius = 16.0
    }
    
    private func colorsConfigure() {
        contentView.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        deadlineLabel.textColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).labelPrimary
        })
        deadlineSwitch.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backPrimary
        })
    }
    private func viewConfigure() {
        labelConfigure()
        changeDeadlineButtonConfigure(deadlineIsOff: deadlineIsOff)
        switchConfigure()
        selectionStyle = .none
        colorsConfigure()
    }
    
    private func labelConstraintsConfigure(deadlineIsOff: Bool) {
        NSLayoutConstraint.deactivate(constrainsLabel)
        if deadlineIsOff {
            constrainsLabel = [
                deadlineLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                deadlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Consts.leadingInset.value),
                deadlineLabel.widthAnchor.constraint(equalToConstant: Consts.widthDeadlineLabel.value)
            ]
        } else {
            constrainsLabel = [
                deadlineLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: deadlineTopPointY),
                deadlineLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
                deadlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Consts.leadingInset.value),
                deadlineLabel.widthAnchor.constraint(equalToConstant: Consts.widthDeadlineLabel.value)
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
            deadlineSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Consts.trailingInset.value)
        ])
    }
    
    private func changeDeadlineButtonConfigure(deadlineIsOff: Bool) {
        if !deadlineIsOff {
            contentView.addSubview(changeDeadlineButton)
            changeDeadlineButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                changeDeadlineButton.topAnchor.constraint(equalTo: contentView.centerYAnchor),
                changeDeadlineButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: changeDeadlineButtonBottom),
                changeDeadlineButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Consts.leadingInset.value),
                changeDeadlineButton.widthAnchor.constraint(equalToConstant: Consts.changeDeadlineButtonWidth.value)
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
