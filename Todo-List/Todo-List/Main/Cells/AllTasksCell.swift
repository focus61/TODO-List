//
//  AllTasksCell.swift
//  Todo-List
//
//  Created by Aleksandr on 05.08.2022.
//

import UIKit

enum CurrentTaskStatus {
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
protocol UpdateEclipseStatusDelegate {
    func updateEclipse(item: TodoItem)
}

final class AllTaskCell: UITableViewCell {
    static let identifier = "AllTaskCell"
    private let taskDescriptionLabel: UILabel = .init(frame: .zero)
    private let taskStatusButton: UIButton = .init(frame: .zero)
    private let shevronImageView: UIImageView = .init(frame: .zero)
    private let deadlineLabel: UILabel = .init(frame: .zero)
    private let horizontalStackViewImageImportantAndLabel: UIStackView = .init(frame: .zero)
    private let verticalStackViewImageDeadlineAndLabel: UIStackView = .init(frame: .zero)
    private let importantImageView: UIImageView = .init(frame: .zero)
    private var isDone = false
    private var currentTaskStatus: CurrentTaskStatus = .normal
    var delegate: UpdateEclipseStatusDelegate?
    private var currentTask: TodoItem?
    private var deadlineText = ""
    private let stackViewSpacing: CGFloat = 5
    private let imageSize = CGSize(width: 15, height: 15)
    private lazy var insetForSeparator = taskStatusButton.frame.size.width + InsetConstants.horizontalInsetBetweenElements.value + WindowInsetConstants.leading.value
    private let statusButtonSize = CGSize(width: 24, height: 24)

    override func prepareForReuse() {
        super.prepareForReuse()
        deadlineText = ""
        taskDescriptionLabel.attributedText = nil
        taskDescriptionLabel.text = nil
        currentTaskStatus = .normal
        taskStatusButton.layer.borderColor = nil
        taskStatusButton.backgroundColor = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: AllTaskCell.identifier)
        shevronImageViewConfigure()
        taskStatusButtonConfigure()
        mainStackViewConfigure()
        colorsConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        taskStatusButton.layer.cornerRadius = 12
        separatorInset = UIEdgeInsets(top: 0, left: insetForSeparator, bottom: 0, right: 0)
    }

    private func colorsConfigure() {
        deadlineLabel.textColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).supportSeparator
        })
        backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        contentView.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        taskDescriptionLabel.textColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).labelPrimary
        })
    }
    @objc private func updateEclipse() {
        isDone.toggle()
        if !isDone {
            taskStatusButton.setTitle("", for: .normal)
            taskStatusButton.backgroundColor = .clear
            taskStatusButton.layer.borderWidth = 1.5
            taskStatusButton.layer.borderColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).supportSeparator
            }).cgColor
        } else {
            taskStatusButton.backgroundColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).green
            })
            taskStatusButton.layer.borderWidth = 0
            taskStatusButton.setTitle("✓", for: .normal)
            taskStatusButton.titleLabel?.font = CustomFont.footnote
            taskStatusButton.setTitleColor(.white, for: .normal)
        }
        if let deadlineIsFalled = currentTask?.deadLine {
            if deadlineIsFalled < Date.now.endOfDay && currentTaskStatus == .normal {
                taskStatusButton.setTitle("", for: .normal)
                taskStatusButton.backgroundColor = UIColor(dynamicProvider: { trait in
                    return CustomColor(trait: trait).red
                }).withAlphaComponent(0.6)
                taskStatusButton.layer.borderColor = UIColor(dynamicProvider: { trait in
                    return CustomColor(trait: trait).red
                }).cgColor
                taskStatusButton.layer.borderWidth = 1.5
            }
        }
        guard let prevItem = currentTask else { return }
        delegate?.updateEclipse(item: prevItem.withComplete(isDone))
    }
}
// MARK: - Configure view
extension AllTaskCell {
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
    
    private func mainStackViewConfigure() {
        contentView.addSubview(horizontalStackViewImageImportantAndLabel)
        horizontalStackViewImageImportantAndLabel.axis = .horizontal
        horizontalStackViewImageImportantAndLabel.spacing = stackViewSpacing
        horizontalStackViewImageImportantAndLabel.addArrangedSubview(importantImageView)
        horizontalStackViewImageImportantAndLabel.addArrangedSubview(verticalStackViewImageDeadlineAndLabel)
        horizontalStackViewImageImportantAndLabel.alignment = .center
        horizontalStackViewImageImportantAndLabel.distribution = .fill
        horizontalStackViewImageImportantAndLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                horizontalStackViewImageImportantAndLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: InsetConstants.verticalInsetBetweenElements.value),
                horizontalStackViewImageImportantAndLabel.trailingAnchor.constraint(equalTo: shevronImageView.leadingAnchor, constant: -InsetConstants.horizontalInsetBetweenElements.value),
                horizontalStackViewImageImportantAndLabel.leadingAnchor.constraint(equalTo: taskStatusButton.trailingAnchor, constant: InsetConstants.horizontalInsetBetweenElements.value),
                horizontalStackViewImageImportantAndLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -InsetConstants.verticalInsetBetweenElements.value)
            ])
        importantImageViewConfigure()
        verticalStackViewConfigure()
    }
    
    private func verticalStackViewConfigure() {
        verticalStackViewImageDeadlineAndLabel.axis = .vertical
        verticalStackViewImageDeadlineAndLabel.spacing = stackViewSpacing
        verticalStackViewImageDeadlineAndLabel.distribution = .fillProportionally
        verticalStackViewImageDeadlineAndLabel.alignment = .fill
        verticalStackViewImageDeadlineAndLabel.addArrangedSubview(taskDescriptionLabel)
        verticalStackViewImageDeadlineAndLabel.addArrangedSubview(deadlineLabel)
        labelConfigure()
    }
    
    private func deadlineLabelConfigure(withText: String) {
        guard
            let image = UIImage(systemName: "calendar")
        else { return }
        deadlineLabel.font = CustomFont.subhead
        deadlineLabel.attributedText = addTextWithImage(with: withText, and: image)
    }
    
    private func labelConfigure() {
        taskDescriptionLabel.font = CustomFont.body
        taskDescriptionLabel.numberOfLines = 3
    }
    private func importantImageViewConfigure() {
        importantImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importantImageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            importantImageView.heightAnchor.constraint(equalToConstant: imageSize.height)
        ])
        importantImageView.contentMode = .scaleAspectFit
    }
    private func taskStatusButtonConfigure() {
        contentView.addSubview(taskStatusButton)
        taskStatusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taskStatusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            taskStatusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WindowInsetConstants.leading.value),
            taskStatusButton.widthAnchor.constraint(equalToConstant: statusButtonSize.width),
            taskStatusButton.heightAnchor.constraint(equalToConstant: statusButtonSize.height)
        ])
        taskStatusButton.addTarget(self, action: #selector(updateEclipse), for: .touchUpInside)
    }
    private func addTextWithImage(with text: String, and image: UIImage) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString()
        let attachment = NSTextAttachment(image: image)
        let attrAttachment = NSAttributedString(attachment: attachment)
        let text = NSAttributedString(string: text)
        mutableString.append(attrAttachment)
        mutableString.append(text)
        return mutableString
    }
}
//MARK: - Fill Data
extension AllTaskCell {
    func fillData(task: TodoItem, currentIndexpath: Int) {
        var eclipseStatus = CurrentTaskStatus.normal
        self.isDone = task.isTaskComplete
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
            taskStatusButton.backgroundColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).green
            })
            taskStatusButton.layer.borderWidth = 0
            taskStatusButton.setTitle("✓", for: .normal)
            taskStatusButton.titleLabel?.font = CustomFont.footnote
            taskStatusButton.setTitleColor(.white, for: .normal)
        case .normal:
            taskStatusButton.setTitle("", for: .normal)
            taskStatusButton.backgroundColor = .clear
            taskStatusButton.layer.borderWidth = 1.5
            taskStatusButton.layer.borderColor = UIColor(dynamicProvider: { trait in
                return .gray
            }).cgColor
        case .falledDeadline:
            taskStatusButton.setTitle("", for: .normal)
            taskStatusButton.backgroundColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).red
            }).withAlphaComponent(0.6)
            taskStatusButton.layer.borderColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).red
            }).cgColor
            taskStatusButton.layer.borderWidth = 1.5
        }
        self.currentTaskStatus = eclipseStatus
        if !deadlineText.isEmpty {
            deadlineLabel.isHidden = false
            deadlineLabelConfigure(withText: deadlineText)
        } else {
            deadlineLabel.isHidden = true
        }
        
        switch task.important {
        case .important:
            importantImageView.image = UIImage(named: "importantImage")
            importantImageView.isHidden = false
        case .basic:
            importantImageView.isHidden = true
        case .unimportant:
            importantImageView.image = UIImage(named: "unimportantImage")
            importantImageView.isHidden = false
        }
        layoutIfNeeded()
    }
}
