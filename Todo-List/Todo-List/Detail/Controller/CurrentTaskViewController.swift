//
//  ViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 30.07.2022.
//

import UIKit


protocol UpdateAllTasksDelegate {
    func updateTask(item: TodoItem)
    func deleteTask(id: String)
}
//DOIT - Keyboard will show etc.
final class CurrentTaskViewController: UIViewController {
    private enum Consts {
        case startHeightTextView
        case calendarHeight
        case heightRow
        case tableViewStartHeight
        case deleteButtonHeight
        var value: CGFloat {
            switch self {
            case .startHeightTextView:
                return 120
            case .calendarHeight:
                return 332
            case .heightRow:
                return 56
            case .tableViewStartHeight:
                return 112
            case .deleteButtonHeight:
                return 56
            }
        }
    }
    var currentItem: TodoItem?
    private var todoItemId = ""
    var delegate: UpdateAllTasksDelegate?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var tableViewWithCalendarConstraint: NSLayoutConstraint?
    private var cancelBarItem = UIBarButtonItem()
    private var saveBarItem = UIBarButtonItem()
    private let textView: UITextView = .init(frame: .zero)
    private var textViewHeight: NSLayoutConstraint?
    private var heightKeyboard: CGFloat = 0
    private var deadlineIsOff = true
    private var calendarIsOff = true
    private var changedDeadlineDate: Date?
    private var importantValue: Int?
    private var addTaskDate: Date?
    private var hideHeight: CGFloat = 0
    private lazy var text = "" {
        willSet {
            if newValue == "" {
                self.saveBarItem.isEnabled = false
                self.deleteButton.isEnabled = false
            } else {
                self.saveBarItem.isEnabled = true
                self.deleteButton.isEnabled = true
            }
        }
    }
    private let tableView: CustomTableView = .init(frame: .zero)
    private let deleteButton: UIButton = .init(type: .system)
    private let scrollView: UIScrollView = .init(frame: .zero)
    private let containerView: UIView = .init(frame: .zero)
    private var containerViewHeightConstraint: NSLayoutConstraint?
    var isChange = false
    private var isShowKeyboard = false
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        if isChange {
            getData()
        }
        colorChangeSettings()

        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func updateTextView(param: Notification) {
        let info = param.userInfo
        if let keyboardRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.heightKeyboard = keyboardRect.height
            if (self.view.bounds.height - textView.contentSize.height - view.safeAreaInsets.top - 50) <= heightKeyboard {
                if param.name ==  UIResponder.keyboardWillShowNotification {
                    _ = keyboardRect.size
                    containerView.frame.origin.y -= keyboardRect.height
                } else {
                    if hideHeight == 0 {
                        containerView.frame.origin.y += keyboardRect.height
                    } else {
                        containerView.frame.origin.y += hideHeight
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureView() {
        navigationItemConfigure()
        scrollViewConfigure()
        textViewConfigure()
        tableViewConfigure()
        deleteButtonConfigure()
    }
    
    private func scrollViewConfigure() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.widthAnchor.constraint(equalToConstant: self.view.bounds.width)
        ])
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: self.view.bounds.height)
        containerViewHeightConstraint?.isActive = true
        scrollView.isUserInteractionEnabled = true
        containerView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapForEndEditing))
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    }
    
    private func textViewConfigure() {
        containerView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: WindowInsetConstants.top.value),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -WindowInsetConstants.trailing.value),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: WindowInsetConstants.leading.value),
        ])
        textViewHeight = textView.heightAnchor.constraint(equalToConstant: Consts.startHeightTextView.value)
        textViewHeight?.isActive = true
        textView.font = CustomFont.body
        textView.text = "Что надо сделать?"
        textView.layer.cornerRadius = 16
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func tableViewConfigure() {
        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: WindowInsetConstants.bottom.value),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -WindowInsetConstants.trailing.value),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: WindowInsetConstants.leading.value)
        ])
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: Consts.tableViewStartHeight.value)
        tableViewHeightConstraint?.isActive = true
        tableViewWithCalendarConstraint = tableView.heightAnchor.constraint(equalToConstant: Consts.tableViewStartHeight.value + Consts.calendarHeight.value)
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func deleteButtonConfigure() {
        containerView.addSubview(deleteButton)
        if text.isEmpty { deleteButton.isEnabled = false }
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: WindowInsetConstants.bottom.value),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -WindowInsetConstants.trailing.value),
            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: WindowInsetConstants.leading.value),
            deleteButton.heightAnchor.constraint(equalToConstant: Consts.deleteButtonHeight.value)
        ])
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.titleLabel?.font = CustomFont.body
        deleteButton.layer.cornerRadius = 16
        deleteButton.addTarget(self, action: #selector(deleteTask), for: .touchUpInside)
    }
    
    private func navigationItemConfigure() {
        title = "Дело"
        navigationItem.largeTitleDisplayMode = .never
        cancelBarItem = UIBarButtonItem(title: "Отменить", style: .done, target: self, action: #selector(cancelTarget))
        navigationItem.leftBarButtonItem = cancelBarItem
        saveBarItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveBarItem
        saveBarItem.isEnabled = false
    }
    
    private func getData() {
        guard let item = currentItem else { return }
        self.todoItemId = item.id
        switch item.important {
        case .important:
            self.importantValue = 2
        case .basic:
            self.importantValue = 1
        case .unimportant:
            self.importantValue = 0
        }
        if let itemDeadline = item.deadLine {
            self.changedDeadlineDate = itemDeadline
            self.deadlineIsOff = false
        }
        self.isChange = true
        self.textView.text = item.text
        addTaskDate = item.addTaskDate
        self.text = item.text
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.height > Consts.startHeightTextView.value {
            textViewHeight?.isActive = false
            textViewHeight?.constant = estimatedSize.height
            textViewHeight?.isActive = true
        }
    }
    
    @objc private func saveTask() {
        let itemText = self.text
        var itemImportant: ImportantType = .basic
        if importantValue == 0 {
            itemImportant = .unimportant
        } else if importantValue == 2 {
            itemImportant = .important
        }
        var itemDeadline: Date?
        if deadlineIsOff && calendarIsOff {
            itemDeadline = nil
        } else if !deadlineIsOff {
            if changedDeadlineDate != nil {
                itemDeadline = changedDeadlineDate
            } else {
                itemDeadline = Date.tomorrow
            }
        } else {
            itemDeadline = changedDeadlineDate
        }
        let isTaskComplete = currentItem?.isTaskComplete ?? false
        let changeTaskDate: Date? = isChange ? Date.now : nil
        let newItem = TodoItem(id: todoItemId, text: itemText, important: itemImportant, deadline: itemDeadline, isTaskComplete: isTaskComplete, addTaskDate: addTaskDate ?? Date.now, changeTaskDate: changeTaskDate)
        self.delegate?.updateTask(item: newItem)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteTask() {
        self.delegate?.deleteTask(id: currentItem?.id ?? "")
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelTarget() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func tapForEndEditing() {
        view.endEditing(true)
    }
    
//    MARK: -Changed color for display mode
    private func colorChangeSettings() {
        cancelBarItem.tintColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).blue
        })
        saveBarItem.tintColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).blue
        })
        view.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backPrimary
        })
        
        textView.backgroundColor =  UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        
        tableView.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        deleteButton.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        
        deleteButton.titleLabel?.tintColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).red
        })
        
        if !isChange {
            textView.textColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).labelTertiary
            })
        } else {
            textView.textColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).labelPrimary
            })
        }
    }
}
//MARK: - textViewDidChange - textViewDidBeginEditing
extension CurrentTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if isChange {
            guard let text = textView.text else {return}
            self.text = text
            let size = CGSize(width: view.frame.width, height: .infinity)
            let textFrameSize = textView.frame.size
            let estimatedSize = textView.sizeThatFits(size)
            if estimatedSize.height >= Consts.startHeightTextView.value {
                textViewHeight?.isActive = false
                textViewHeight?.constant = estimatedSize.height
                textViewHeight?.isActive = true
                if (self.view.bounds.height - textView.contentSize.height - view.safeAreaInsets.top - 50) <= heightKeyboard {
                    let heightSize = estimatedSize.height - textFrameSize.height
                    hideHeight += heightSize
                    containerView.frame.origin.y -= heightSize
                    scrollView.contentSize.height += heightSize
                    containerViewHeightConstraint?.isActive = false
                    containerViewHeightConstraint?.constant = scrollView.contentSize.height
                    containerViewHeightConstraint?.isActive = true
                }
                
                if deleteButton.frame.origin.y >= view.frame.height - deleteButton.frame.size.height - 20 {
                    let heightSize = estimatedSize.height - textFrameSize.height
                    scrollView.contentSize.height += heightSize
                    containerViewHeightConstraint?.isActive = false
                    containerViewHeightConstraint?.constant = scrollView.contentSize.height
                    containerViewHeightConstraint?.isActive = true
                } 
                view.layoutIfNeeded()
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !isChange {
            self.textView.text = nil
            isChange = true
            textView.textColor = nil
            textView.textColor = UIColor(dynamicProvider: { trait in
                return CustomColor(trait: trait).labelPrimary
            })
        }
        if (self.view.bounds.height - textView.contentSize.height - view.safeAreaInsets.top - 50) <= heightKeyboard {
            
        }
        
    }
}
//MARK: - TableView Config
extension CurrentTaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if calendarIsOff {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImportantTableViewCell.identifier, for: indexPath) as? ImportantTableViewCell else { return UITableViewCell() }
            cell.fillData(segmentedValue: importantValue ?? 1)
            cell.importantSegmentControl.addTarget(self, action: #selector(segmentImportantTarget(sender:)), for: .valueChanged)
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DeadlineDateTableViewCell.identifier, for: indexPath) as? DeadlineDateTableViewCell else { return UITableViewCell() }
            var fillDate = Date.tomorrow
            if let changedDate = self.changedDeadlineDate {
                fillDate = changedDate
            }
            
            cell.fillData(deadlineIsOff: deadlineIsOff, deadlineDate: fillDate, calendarIsOff: calendarIsOff)
            cell.deadlineSwitch.addTarget(self, action: #selector(changeSwitchValue), for: .valueChanged)
            if !deadlineIsOff {
                cell.changeDeadlineButton.addTarget(self, action: #selector(addCalendarForDeadline), for: .touchUpInside)
            }
            return cell
        }
        if !calendarIsOff {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: indexPath) as? CalendarCell else {return UITableViewCell()}
            
            cell.delegate = self
            cell.fillData(changedDeadlineDate: changedDeadlineDate ?? Date.now)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !calendarIsOff && indexPath.row == 2 {
            return Consts.calendarHeight.value
        }
        return Consts.heightRow.value
    }
    
//  MARK: - Table view Action/Target
    @objc private func segmentImportantTarget(sender: UISegmentedControl) {
        self.importantValue = sender.selectedSegmentIndex
    }
    
    @objc private func addCalendarForDeadline() {
        containerViewHeightConstraint?.isActive = false
         if calendarIsOff {
             UIView.animate(withDuration: 0.4) { [weak self] in
                 guard let self = self else {return}
                 self.tableViewHeightConstraint?.isActive = false
                 self.tableViewWithCalendarConstraint?.isActive = true
                 self.view.layoutIfNeeded()
             }
             scrollView.contentSize.height += Consts.calendarHeight.value
             containerViewHeightConstraint?.constant += Consts.calendarHeight.value
         } else {
             UIView.animate(withDuration: 0.4) { [weak self] in
                 guard let self = self else {return}
                 self.tableViewWithCalendarConstraint?.isActive = false
                 self.tableViewHeightConstraint?.isActive = true
                 self.view.layoutIfNeeded()
             }
             scrollView.contentSize.height -= Consts.calendarHeight.value
             containerViewHeightConstraint?.constant -= Consts.calendarHeight.value
         }
        containerViewHeightConstraint?.isActive = true
        view.layoutIfNeeded()
        calendarIsOff.toggle()
        tableView.reloadData()
    }
    
    @objc private func changeSwitchValue() {
        deadlineIsOff.toggle()
        if deadlineIsOff && !calendarIsOff {
            containerViewHeightConstraint?.isActive = false
            calendarIsOff.toggle()
            changedDeadlineDate = nil
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let self = self else {return}
                self.tableViewWithCalendarConstraint?.isActive = false
                self.tableViewHeightConstraint?.isActive = true
                self.view.layoutIfNeeded()
            }
            scrollView.contentSize.height -= Consts.calendarHeight.value
            containerViewHeightConstraint?.constant -= Consts.calendarHeight.value
            containerViewHeightConstraint?.isActive = true
        }
        if calendarIsOff && deadlineIsOff {
            changedDeadlineDate = nil
        }
        view.layoutIfNeeded()
        tableView.reloadData()
    }
}

extension CurrentTaskViewController: UpdateDateWithDatePickerDelegate {
    func update(currentDate: Date) {
        self.changedDeadlineDate = currentDate
        self.tableView.reloadData()
    }
}
