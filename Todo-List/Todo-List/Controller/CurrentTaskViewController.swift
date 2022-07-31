//
//  ViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 30.07.2022.
//

import UIKit

class CurrentTaskViewController: UIViewController {
    private var displayMode: DisplayMode = .lightMode
    var isChangeDisplayMode = false {
        didSet {
            tableView.reloadData()
        }
    }
    let fileCache = FileCache()

    var tableViewHeightConstraint: NSLayoutConstraint?
    var tableViewWithCalendarConstraint: NSLayoutConstraint?
    var cancelBarItem = UIBarButtonItem()
    lazy var saveBarItem = UIBarButtonItem()
    private let startHeightTextView: CGFloat = 120
    let textView: UITextView = .init(frame: .zero)
    var textViewHeight: NSLayoutConstraint?
    var heightKeyboard: CGFloat = 0
    var deadlineIsOff = true
    var calendarIsOff = true
    var changedDate: Date?
    var importantValue = 0
    lazy var text = "" {
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
    let tableView: CustomTableView = .init(frame: .zero)
    let deleteButton: UIButton = .init(type: .system)

    var isFirstUse = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    @objc func updateTextView(param: Notification) {
        guard let userInfo = param.userInfo,
              let getKeyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {return}
        let keyboardFrame = view.convert(getKeyboardRect, to: view.window)
        if param.name ==  UIResponder.keyboardWillShowNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        }
//        textView.scrollRangeToVisible(textView.selectedRange)
        print(getKeyboardRect, self.view.bounds.height)
        print(self.view.bounds.height - getKeyboardRect.size.height)
        self.heightKeyboard = getKeyboardRect.size.height
    }
    @objc func keyboardWillShow(_ notification:NSNotification) {
//        let d = notification.userInfo!
//        var r = (d[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        r = self.textView.convert(r, from:nil)
//        self.textView.contentInset.bottom = r.size.height
//        self.textView.verticalScrollIndicatorInsets.bottom = r.size.height
        print("Show")

    }

    @objc func keyboardWillHide(_ notification:NSNotification) {
        print("Hide")
//        let contentInsets = UIEdgeInsets.zero
//        self.textView.contentInset = contentInsets
//        self.textView.verticalScrollIndicatorInsets = contentInsets
    }
    private func configureView() {
        navigationItemConfigure()
        textViewConfigure()
        tableViewConfigure()
        deleteButtonConfigure()
    }
    
    private func textViewConfigure() {
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textView.heightAnchor.constraint(equalToConstant: startHeightTextView)
        ])
//        textView.contentSize.height = currentHeight
        textView.font = CustomFont.body
        textView.text = "Что надо сделать?"
        textView.layer.cornerRadius = 16
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func tableViewConfigure() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
        tableViewHeightConstraint =             tableView.heightAnchor.constraint(equalToConstant: 112)
        tableViewHeightConstraint?.isActive = true
        tableViewWithCalendarConstraint = tableView.heightAnchor.constraint(equalToConstant: 112 + 332)
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
    }

    func deleteButtonConfigure() {
        view.addSubview(deleteButton)
        if text.isEmpty { deleteButton.isEnabled = false }
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            deleteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.titleLabel?.font = CustomFont.body
        deleteButton.layer.cornerRadius = 16
    }
    
    private func navigationItemConfigure() {
        title = "Дело"
        
        cancelBarItem = UIBarButtonItem(title: "Отменить", style: .done, target: self, action: #selector(cancelTarget))
        navigationItem.leftBarButtonItem = cancelBarItem
        
        saveBarItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveBarItem
        saveBarItem.isEnabled = false

    }
    @objc func cancelTarget() {
        print("CANCEL")
//        self.dismiss(animated: true)
    }
    @objc func saveTask() {
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
            if changedDate != nil {
                itemDeadline = changedDate
            } else {
                itemDeadline = Date.tomorrow
            }
        } else {
            itemDeadline = changedDate
        }
        

        let addTaskDate = Date.now
        
        //MARK: -Еще не готово-
        let isTaskComplete = false
        let changeTaskDate: Date?
        //MARK: ---------------
        let newItem = TodoItem(identifier: nil,text: text, important: itemImportant, deadline: itemDeadline, isTaskComplete: isTaskComplete, addTaskDate: addTaskDate)
        guard let id = newItem.identifier else {return}
        print(newItem)
        fileCache.addTask(item: newItem, id: id)
        fileCache.saveToFile("NEWFILE_FORTASK")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayMode = traitCollection.userInterfaceStyle == .dark ? .darkMode : .lightMode
        tableView.reloadData()
        colorChangeSettings()

    }
    
    func colorChangeSettings() {
        cancelBarItem.tintColor = CustomColor(displayMode: displayMode).blue
        saveBarItem.tintColor = CustomColor(displayMode: displayMode).blue
        view.backgroundColor = CustomColor(displayMode: displayMode).backPrimary
        textView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        tableView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        deleteButton.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        deleteButton.titleLabel?.tintColor =  CustomColor(displayMode: displayMode).red
        if !isFirstUse {
            textView.textColor = CustomColor(displayMode: displayMode).labelTertiary
        } else {
            textView.textColor = CustomColor(displayMode: displayMode).labelPrimary
        }
    }
}
extension CurrentTaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if isFirstUse {
            guard let text = textView.text else {return}
            
            self.text = text
            let size = CGSize(width: view.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            //        print(size, "\n", estimatedSize)
            if estimatedSize.height >= startHeightTextView {
                print("SOME")
                textView.constraints.forEach { constraint in
                    if constraint.firstAttribute == .height {
                        constraint.constant = estimatedSize.height
                    }
                }
            }
        }
        
       
//        if textView.contentSize.height >= currentHeight {
////            self.textView.sizeToFit()
//        }
        if (self.view.bounds.height - textView.contentSize.height - view.safeAreaInsets.top - 50) <= self.heightKeyboard {
            print("SOME")
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !isFirstUse && textView.textColor == CustomColor(displayMode: displayMode).labelTertiary {
            self.textView.text = nil
            isFirstUse = true
        }
    }
}

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
            cell.fillData(displayMode: displayMode)
            cell.importantSegmentControl.addTarget(self, action: #selector(segmentImportantTarget(sender:)), for: .valueChanged)
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DeadlineDateTableViewCell.identifier, for: indexPath) as? DeadlineDateTableViewCell else { return UITableViewCell() }
            var fillDate = Date.tomorrow
            if let changedDate = self.changedDate {
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
            cell.datePicker.addTarget(self, action: #selector(getDateFromCalendar(sender:)), for: .valueChanged)
            if let changedDate = changedDate {
                cell.datePicker.date = changedDate
            } else {
                cell.datePicker.date = Date.now
            }
            cell.fillData(displayMode: displayMode)
            return cell
        }
        return UITableViewCell()
    }
    @objc func segmentImportantTarget(sender: UISegmentedControl) {
        self.importantValue = sender.selectedSegmentIndex
    }
    @objc func getDateFromCalendar(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        self.changedDate = sender.date
        
        self.tableView.reloadData()
        // do what you want to do with the string.
    }
    @objc func addCalendarForDeadline() {
         if calendarIsOff {
             UIView.animate(withDuration: 0.5) {
                 self.tableViewHeightConstraint?.isActive = false
                 self.tableViewWithCalendarConstraint?.isActive = true
                 self.view.layoutIfNeeded()
             }
         } else {
             UIView.animate(withDuration: 0.5) {
                 self.tableViewWithCalendarConstraint?.isActive = false
                 self.tableViewHeightConstraint?.isActive = true
                 self.view.layoutIfNeeded()
             }
         }
        calendarIsOff = !calendarIsOff
        tableView.reloadData()
    }
    @objc func changeSwitchValue() {
        deadlineIsOff = !deadlineIsOff
        if deadlineIsOff && !calendarIsOff {
            calendarIsOff = !calendarIsOff
            changedDate = nil
            UIView.animate(withDuration: 0.5) {
                self.tableViewWithCalendarConstraint?.isActive = false
                self.tableViewHeightConstraint?.isActive = true
                self.view.layoutIfNeeded()
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !calendarIsOff && indexPath.row == 2 {
            return 332
        }
        return 56
    }
    
}
