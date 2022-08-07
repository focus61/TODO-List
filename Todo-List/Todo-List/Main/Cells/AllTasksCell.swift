//
//  AllTasksCell.swift
//  Todo-List
//
//  Created by Aleksandr on 05.08.2022.
//

import UIKit

enum EclipseStatus {
    case done
    case normal
    case falledDeadline
}

enum InsetConstants {
    case horizontalInsetBetweenElements
    case horizontalSpaceBetweenImageAndLabel
    case verticalInsetBetweenElements
    var value: CGFloat {
        switch self {
            case .horizontalInsetBetweenElements : return 10
            case .horizontalSpaceBetweenImageAndLabel: return 5
            case .verticalInsetBetweenElements: return 17
        }
    }
}

final class AllTaskCell: UITableViewCell {
    static let identifier = "AllTaskCell"
    private let taskDescriptionLabel =  UILabel()
    private let eclipse = UIButton()
    private let shevronImageView = UIImageView()
    private let deadlineLabel = UILabel()
    private var isDone = false
    private var eclipseStatus: EclipseStatus = .normal
    private var displayMode: DisplayMode = .lightMode
    var delegate: UpdateEclipse?
    private var currentTask: TodoItem?
    private var deadlineText = ""
    private var labelBottomConstraint: NSLayoutConstraint?
    private var labelLeadingConstraint: NSLayoutConstraint?
    private let importantImageView = UIImageView()
    private let littleCalendar = UIImageView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deadlineText = ""
        taskDescriptionLabel.attributedText = nil
        taskDescriptionLabel.text = nil
        eclipseStatus = .normal
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: AllTaskCell.identifier)
        shevronImageViewConfigure()
        eclipseConfigure()
        labelConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch eclipseStatus {
        case .done:
            eclipse.backgroundColor = CustomColor(displayMode: displayMode).green
        case .normal:
            eclipse.layer.borderColor = CustomColor(displayMode: displayMode).supportSeparator.cgColor
        case .falledDeadline:
            eclipse.backgroundColor = (CustomColor(displayMode: displayMode).red).withAlphaComponent(0.6)
            eclipse.layer.borderColor = CustomColor(displayMode: displayMode).red.cgColor
            eclipse.layer.borderWidth = 1.5
        }
        deadlineLabel.textColor = CustomColor(displayMode: displayMode).supportSeparator
        littleCalendar.tintColor = CustomColor(displayMode: displayMode).supportSeparator
        backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        contentView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        taskDescriptionLabel.textColor = CustomColor(displayMode: displayMode).labelPrimary
        eclipse.layer.cornerRadius = 12
        
        let value = eclipse.frame.size.width + InsetConstants.horizontalInsetBetweenElements.value + WindowInsetConstants.leading.value
        separatorInset = UIEdgeInsets(top: 0, left: value, bottom: 0, right: 0)
    }
    
    @objc private func updateEclipse() {
        isDone.toggle()
        if !isDone {
            eclipse.setTitle("", for: .normal)
            eclipse.backgroundColor = .clear
            eclipse.layer.borderWidth = 1.5
            eclipse.layer.borderColor = CustomColor(displayMode: displayMode).supportSeparator.cgColor
        } else {
            eclipse.backgroundColor = CustomColor(displayMode: displayMode).green
            eclipse.layer.borderWidth = 0
            eclipse.setTitle("✓", for: .normal)
            eclipse.titleLabel?.font = CustomFont.footnote
            eclipse.setTitleColor(.white, for: .normal)
        }
        if let deadlineIsFalled = currentTask?.deadLine {
            if deadlineIsFalled < Date.now.endOfDay && eclipseStatus == .normal {
                eclipse.setTitle("", for: .normal)
                eclipse.backgroundColor = (CustomColor(displayMode: displayMode).red).withAlphaComponent(0.6)
                eclipse.layer.borderColor = CustomColor(displayMode: displayMode).red.cgColor
                eclipse.layer.borderWidth = 1.5
            }
        }
        guard let prevItem = currentTask else { return }
        let item = TodoItem(id: prevItem.id, text: prevItem.text, important: prevItem.important, deadline: prevItem.deadLine, isTaskComplete: isDone, addTaskDate: prevItem.addTaskDate, changeTaskDate: prevItem.changeTaskDate)
        delegate?.updateEclipse(item: item)
    }
}
// MARK: - Configure view
extension AllTaskCell {
    private func deadlineLabelConfigure(withText: String) {
        if !deadlineText.isEmpty {
            contentView.addSubview(deadlineLabel)
            deadlineLabel.font = CustomFont.subhead
            deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(littleCalendar)
            littleCalendar.translatesAutoresizingMaskIntoConstraints = false
            littleCalendar.contentMode = .scaleAspectFit
            littleCalendar.image = UIImage(named: "littleCalendar")
            let sizeLittleCalendar = CGSize(width: 15, height: 15)
            NSLayoutConstraint.activate ([
                littleCalendar.leadingAnchor.constraint(equalTo: taskDescriptionLabel.leadingAnchor),
                littleCalendar.centerYAnchor.constraint(equalTo: deadlineLabel.centerYAnchor),
                littleCalendar.widthAnchor.constraint(equalToConstant: sizeLittleCalendar.width),
                littleCalendar.heightAnchor.constraint(equalToConstant: sizeLittleCalendar.height),

                deadlineLabel.topAnchor.constraint(equalTo: taskDescriptionLabel.bottomAnchor),
                deadlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -InsetConstants.verticalInsetBetweenElements.value),
                deadlineLabel.leadingAnchor.constraint(equalTo: littleCalendar.trailingAnchor, constant: InsetConstants.horizontalSpaceBetweenImageAndLabel.value)
            ])
        deadlineLabel.text = withText
        }
    }
    
    private func shevronImageViewConfigure() {
        contentView.addSubview(shevronImageView)
        shevronImageView.translatesAutoresizingMaskIntoConstraints = false
        let shevronSize = CGSize(width: 7, height: 12)
        NSLayoutConstraint.activate([
            shevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -WindowInsetConstants.trailing.value),
            shevronImageView.widthAnchor.constraint(equalToConstant: shevronSize.width),
            shevronImageView.heightAnchor.constraint(equalToConstant: shevronSize.height)
        ])
        shevronImageView.image = UIImage(named: "shevron")
        shevronImageView.contentMode = .scaleAspectFit
    }
    
    private func labelConfigure() {
        contentView.addSubview(taskDescriptionLabel)
        taskDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                taskDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: InsetConstants.verticalInsetBetweenElements.value),
                taskDescriptionLabel.trailingAnchor.constraint(equalTo: shevronImageView.leadingAnchor, constant: -InsetConstants.horizontalInsetBetweenElements.value)
            ])
        labelLeadingConstraint = taskDescriptionLabel.leadingAnchor.constraint(equalTo: eclipse.trailingAnchor, constant: InsetConstants.horizontalInsetBetweenElements.value)
        labelLeadingConstraint?.isActive = true
        labelBottomConstraint = taskDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -InsetConstants.verticalInsetBetweenElements.value)
        labelBottomConstraint?.isActive = true
        labelBottomConstraint?.priority = .defaultHigh
        taskDescriptionLabel.font = CustomFont.body
        taskDescriptionLabel.numberOfLines = 3
    }
    
    private func eclipseConfigure() {
        contentView.addSubview(eclipse)
        let eclipseSize = CGSize(width: 24, height: 24)
        eclipse.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eclipse.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            eclipse.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WindowInsetConstants.leading.value),
            eclipse.widthAnchor.constraint(equalToConstant: eclipseSize.width),
            eclipse.heightAnchor.constraint(equalToConstant: eclipseSize.height)
        ])
        eclipse.addTarget(self, action: #selector(updateEclipse), for: .touchUpInside)
    }
    
    private func importantImageViewConfigure() {
        contentView.addSubview(importantImageView)
        let sizeImage = CGSize(width: 15, height: 15)
        importantImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importantImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importantImageView.leadingAnchor.constraint(equalTo: eclipse.trailingAnchor, constant: InsetConstants.horizontalInsetBetweenElements.value),
            importantImageView.widthAnchor.constraint(equalToConstant: sizeImage.width),
            importantImageView.heightAnchor.constraint(equalToConstant: sizeImage.height)
        ])
        importantImageView.contentMode = .scaleAspectFit
    }
}

//MARK: - Fill Data
extension AllTaskCell {
    func fillData(task: TodoItem, currentIndexpath: Int, displayMode: DisplayMode, tableViewWidth: CGFloat) {
        taskDescriptionLabel.preferredMaxLayoutWidth = tableViewWidth
        var eclipseStatus = EclipseStatus.normal
        self.isDone = task.isTaskComplete
        self.displayMode = displayMode
        self.currentTask = task
        let attributeString = NSMutableAttributedString(string: task.text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        
        if isDone {
            taskDescriptionLabel.attributedText = attributeString
            eclipseStatus = .done
        } else {
            
            taskDescriptionLabel.text = task.text
            eclipseStatus = .normal
        }
        
        var falledDeadline = false
        if let deadline = task.deadLine {
            self.deadlineText = Date.currentDateFormatForDeadline(date: deadline)
            
            if deadline.timeIntervalSince1970 < Date.now.timeIntervalSince1970 {
                falledDeadline = true
            }
        }
        
        if eclipseStatus == .normal && falledDeadline {
            eclipseStatus = .falledDeadline
        }
        switch eclipseStatus {
        case .done:
            eclipse.backgroundColor = CustomColor(displayMode: displayMode).green
            eclipse.layer.borderWidth = 0
            eclipse.setTitle("✓", for: .normal)
            eclipse.titleLabel?.font = CustomFont.footnote
            eclipse.setTitleColor(.white, for: .normal)
        case .normal:
            eclipse.setTitle("", for: .normal)
            eclipse.backgroundColor = .clear
            eclipse.layer.borderWidth = 1.5
            eclipse.layer.borderColor = CustomColor(displayMode: displayMode).supportSeparator.cgColor
        case .falledDeadline:
            eclipse.setTitle("", for: .normal)
            eclipse.backgroundColor = (CustomColor(displayMode: displayMode).red).withAlphaComponent(0.6)
            eclipse.layer.borderColor = CustomColor(displayMode: displayMode).red.cgColor
            eclipse.layer.borderWidth = 1.5
        }
        self.eclipseStatus = eclipseStatus
        if !deadlineText.isEmpty {
            labelBottomConstraint?.isActive = false
            labelBottomConstraint?.priority = .defaultHigh
            deadlineLabelConfigure(withText: deadlineText)
        } else {
            littleCalendar.removeFromSuperview()
            deadlineLabel.removeFromSuperview()
            labelBottomConstraint?.isActive = true
            labelBottomConstraint?.priority = .defaultHigh
        }
        
        switch task.important {
        case .important:
            labelLeadingConstraint?.isActive = false
            importantImageViewConfigure()
            importantImageView.image = UIImage(named: "importantImage")
            labelLeadingConstraint = taskDescriptionLabel.leadingAnchor.constraint(equalTo: importantImageView.trailingAnchor, constant: InsetConstants.horizontalSpaceBetweenImageAndLabel.value)
            labelLeadingConstraint?.isActive = true
        case .basic:
            labelLeadingConstraint?.isActive = false
            importantImageView.removeFromSuperview()
            labelLeadingConstraint = taskDescriptionLabel.leadingAnchor.constraint(equalTo: eclipse.trailingAnchor, constant: InsetConstants.horizontalInsetBetweenElements.value)
            labelLeadingConstraint?.isActive = true
            break
        case .unimportant:
            labelLeadingConstraint?.isActive = false
            importantImageViewConfigure()
            importantImageView.image = UIImage(named: "unimportantImage")
            labelLeadingConstraint = taskDescriptionLabel.leadingAnchor.constraint(equalTo: importantImageView.trailingAnchor, constant: InsetConstants.horizontalSpaceBetweenImageAndLabel.value)
            labelLeadingConstraint?.isActive = true
        }
    }
}
