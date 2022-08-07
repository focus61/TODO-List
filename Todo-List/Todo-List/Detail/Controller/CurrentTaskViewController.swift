//
//  ViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 30.07.2022.
//

import UIKit
protocol UpdateDateWithDatePicker {
    func update(currentDate: Date)
}
//DOIT - Keyboard will show etc.
final class CurrentTaskViewController: UIViewController {
    private var displayMode: DisplayMode = .lightMode
    private let fileCache = FileCache()
    var currentItem: TodoItem?
    private var todoItemId = ""
    var delegate: Update?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var tableViewWithCalendarConstraint: NSLayoutConstraint?
    private var cancelBarItem = UIBarButtonItem()
    private var saveBarItem = UIBarButtonItem()
    private let startHeightTextView: CGFloat = 120
    private let calendarHeight: CGFloat = 332
    private let textView: UITextView = .init(frame: .zero)
    private var textViewHeight: NSLayoutConstraint?
    private var heightKeyboard: CGFloat = 0
    private var deadlineIsOff = true
    private var calendarIsOff = true
    private var changedDeadlineDate: Date?
    private var importantValue: Int?
    private var addTaskDate: Date?
    var hideHeight: CGFloat = 0
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
    private var counter = 1
    private var isShowKeyboard = false
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        if isChange {
            getData()
        }
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func updateTextView(param: Notification) {
        let info = param.userInfo
        if let keyboardRect = info?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.heightKeyboard = keyboardRect.height
            if (self.view.bounds.height - textView.contentSize.height - view.safeAreaInsets.top - 50) <= heightKeyboard {
                if param.name ==  UIResponder.keyboardWillShowNotification {
                    let keyboardSize = keyboardRect.size
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
        counter = 1
    }
    
    private func textViewConfigure() {
        containerView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
        ])
        textViewHeight = textView.heightAnchor.constraint(equalToConstant: startHeightTextView)
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
            tableView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20)
        ])
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 112)
        tableViewHeightConstraint?.isActive = true
        tableViewWithCalendarConstraint = tableView.heightAnchor.constraint(equalToConstant: 112 + calendarHeight)
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func deleteButtonConfigure() {
        containerView.addSubview(deleteButton)
        if text.isEmpty { deleteButton.isEnabled = false }
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            deleteButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
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
    
    private func loadData() {
        do {
            try fileCache.loadFromFile(FileCache.fileName)
        } catch FileCacheError.loadError(let loadErrorMessage) {
            if !fileCache.todoItems.isEmpty {
                let alert = Helpers.shared.addAlert(title: "Внимание", message: loadErrorMessage)
                present(alert, animated: true, completion: nil)
            }
        } catch {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func getData() {
        guard let item = currentItem else { return }
        self.todoItemId = item.id
        switch item.important {
            case .important:           self.importantValue = 2
            case .basic:               self.importantValue = 1
            case .unimportant:         self.importantValue = 0
        }
        if let itemDeadline = item.deadLine {
            self.changedDeadlineDate = itemDeadline
            self.deadlineIsOff = false
        }
        self.textView.text = item.text
        addTaskDate = item.addTaskDate
        self.text = item.text
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.height > startHeightTextView {
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
        fileCache.addTask(item: newItem)
        do {
            try fileCache.saveToFile(FileCache.fileName)
            let alert = UIAlertController(title: nil, message: "Задача сохранена", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) {[weak self] _ in
                self?.delegate?.updateDate()
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        } catch FileCacheError.saveError(let saveErrorMessage) {
            if !fileCache.todoItems.isEmpty {
                let alert = Helpers.shared.addAlert(title: "Внимание", message: saveErrorMessage)
                present(alert, animated: true, completion: nil)
            }
        } catch  {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func deleteTask() {
        do {
            self.fileCache.deleteTask(id: self.todoItemId)
            try fileCache.saveToFile(FileCache.fileName)
            let alert = UIAlertController(title: nil, message: "Задача удалена", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.delegate?.updateDate()
                self?.navigationController?.popToRootViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        } catch FileCacheError.saveError(let saveErrorMessage) {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: saveErrorMessage)
            present(alert, animated: true, completion: nil)
        } catch  {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func cancelTarget() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func tapForEndEditing() {
        view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayMode = traitCollection.userInterfaceStyle == .dark ? .darkMode : .lightMode
        if counter == 1 {
            tableView.reloadData()
        }
        colorChangeSettings()
    }
//    MARK: -Changed color for display mode
    private func colorChangeSettings() {
        cancelBarItem.tintColor = CustomColor(displayMode: displayMode).blue
        saveBarItem.tintColor = CustomColor(displayMode: displayMode).blue
        view.backgroundColor = CustomColor(displayMode: displayMode).backPrimary
        textView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        tableView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        deleteButton.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        deleteButton.titleLabel?.tintColor =  CustomColor(displayMode: displayMode).red
        if !isChange {
            textView.textColor = CustomColor(displayMode: displayMode).labelTertiary
        } else {
            textView.textColor = CustomColor(displayMode: displayMode).labelPrimary
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
            if estimatedSize.height >= startHeightTextView {
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
        if !isChange && textView.textColor == CustomColor(displayMode: displayMode).labelTertiary {
            self.textView.text = nil
            isChange = true
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
            cell.fillData(displayMode: displayMode, segmentedValue: importantValue ?? 1)
            cell.importantSegmentControl.addTarget(self, action: #selector(segmentImportantTarget(sender:)), for: .valueChanged)
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DeadlineDateTableViewCell.identifier, for: indexPath) as? DeadlineDateTableViewCell else { return UITableViewCell() }
            var fillDate = Date.tomorrow
            if let changedDate = self.changedDeadlineDate {
                fillDate = changedDate
            }
            
            cell.fillData(displayMode: displayMode, deadlineIsOff: deadlineIsOff, deadlineDate: fillDate, calendarIsOff: calendarIsOff)
            cell.deadlineSwitch.addTarget(self, action: #selector(changeSwitchValue), for: .valueChanged)
            if !deadlineIsOff {
                cell.changeDeadlineButton.addTarget(self, action: #selector(addCalendarForDeadline), for: .touchUpInside)
            }
            return cell
        }
        if !calendarIsOff {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: indexPath) as? CalendarCell else {return UITableViewCell()}
            
            cell.delegate = self
            cell.fillData(displayMode: displayMode, changedDeadlineDate: changedDeadlineDate ?? Date.now)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !calendarIsOff && indexPath.row == 2 {
            return calendarHeight
        }
        return 56
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
             scrollView.contentSize.height += calendarHeight
             containerViewHeightConstraint?.constant += calendarHeight
         } else {
             UIView.animate(withDuration: 0.4) { [weak self] in
                 guard let self = self else {return}
                 self.tableViewWithCalendarConstraint?.isActive = false
                 self.tableViewHeightConstraint?.isActive = true
                 self.view.layoutIfNeeded()
             }
             scrollView.contentSize.height -= calendarHeight
             containerViewHeightConstraint?.constant -= calendarHeight
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
            scrollView.contentSize.height -= calendarHeight
            containerViewHeightConstraint?.constant -= calendarHeight
            containerViewHeightConstraint?.isActive = true
        }
        if calendarIsOff && deadlineIsOff {
            changedDeadlineDate = nil
        }
        view.layoutIfNeeded()
        tableView.reloadData()
    }
}

extension CurrentTaskViewController: UpdateDateWithDatePicker {
    func update(currentDate: Date) {
        self.changedDeadlineDate = currentDate
        self.tableView.reloadData()
    }
}
