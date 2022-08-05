//
//  AllTasksCell.swift
//  Todo-List
//
//  Created by Aleksandr on 05.08.2022.
//

//MARK: - Сделать константы для констреинтов + календарик перед дедлайном
import UIKit

enum EclipseStatus {
    case done
    case normal
    case falledDeadline
}
class AllTaskCell: UITableViewCell {
    let taskDescriptionLabel =  UILabel()
    let eclipse = UIButton()
    let shevronImageView = UIImageView()
    let deadlineLabel = UILabel()
    var isDone = false
    var eclipseStatus: EclipseStatus = .normal
    var displayMode: DisplayMode = .lightMode
    var delegate: UpdateEclipse?
    var currentTask: TodoItem?
    var deadlineText = ""
    var id = ""
    
    
    var labelBottomConstraint: NSLayoutConstraint?
    
    
    static let identifier = "AllTaskCell"
    override func prepareForReuse() {
        super.prepareForReuse()
        eclipseStatus = .normal
        currentTask = nil
        isDone = false
        deadlineText = ""
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: AllTaskCell.identifier)
        shevronImageViewConfigure()
        eclipseConfigure()
        labelConfigure()
    }
    
    func deadlineLabelConfigure(withText: String) {
        if !deadlineText.isEmpty {
            contentView.addSubview(deadlineLabel)
            deadlineLabel.font = CustomFont.subhead
            deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate ([
                deadlineLabel.topAnchor.constraint(equalTo: taskDescriptionLabel.bottomAnchor),
                deadlineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17),
                deadlineLabel.leadingAnchor.constraint(equalTo: taskDescriptionLabel.leadingAnchor),
            ])
            
        deadlineLabel.text = withText
        }
    }
    
    func shevronImageViewConfigure() {
        contentView.addSubview(shevronImageView)
        shevronImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            shevronImageView.widthAnchor.constraint(equalToConstant: 7),
            shevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        shevronImageView.image = UIImage(named: "shevron")
        shevronImageView.contentMode = .scaleAspectFit
    }
    func labelConfigure() {
        contentView.addSubview(taskDescriptionLabel)
        taskDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                taskDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
                taskDescriptionLabel.leadingAnchor.constraint(equalTo: eclipse.trailingAnchor, constant: 10),
                taskDescriptionLabel.trailingAnchor.constraint(equalTo: shevronImageView.leadingAnchor, constant: -10)
            ])
        labelBottomConstraint = taskDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -17)
        labelBottomConstraint?.isActive = true
        
        taskDescriptionLabel.font = CustomFont.body
        taskDescriptionLabel.numberOfLines = 3
    }
    func eclipseConfigure() {
        contentView.addSubview(eclipse)
        eclipse.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eclipse.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            eclipse.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            eclipse.widthAnchor.constraint(equalToConstant: 24),
            eclipse.heightAnchor.constraint(equalToConstant: 24)
        ])
        eclipse.addTarget(self, action: #selector(updateEclipse), for: .touchUpInside)
    }
    
    @objc func updateEclipse() {
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
        guard let prevItem = currentTask else { return }
        let item = TodoItem(id: prevItem.id, text: prevItem.text, important: prevItem.important, deadline: prevItem.deadLine, isTaskComplete: isDone, addTaskDate: prevItem.addTaskDate, changeTaskDate: prevItem.changeTaskDate)
        delegate?.updateEclipse(item: item)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Доделать deadline label & text
    
    func fillData(task: TodoItem, currentIndexpath: Int, displayMode: DisplayMode) {
        deadlineText = ""
        var eclipseStatus = EclipseStatus.normal
        if task.isTaskComplete {
            eclipseStatus = .done
        } else {
            eclipseStatus = .normal
        }
        
        taskDescriptionLabel.text = task.text
        self.displayMode = displayMode
        self.eclipseStatus = eclipseStatus
        self.currentTask = task
        

        
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
        if let deadline = task.deadLine {
            self.deadlineText = Date.currentDateFormatForDeadline(date: deadline)
        }

        if !deadlineText.isEmpty {
            labelBottomConstraint?.isActive = false
            deadlineLabelConfigure(withText: deadlineText)
            
        } else {
            deadlineLabel.removeFromSuperview()
            labelBottomConstraint?.isActive = true
//            labelBottomConstraint = taskDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//            labelBottomConstraint?.isActive = true
        }
//        label.preferredMaxLayoutWidth = bounds.width

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
//        backgroundColor = CustomColor(displayMode: displayMode).backSecondary
//        contentView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        taskDescriptionLabel.textColor = CustomColor(displayMode: displayMode).labelPrimary
        eclipse.layer.cornerRadius = 12
    }
}
