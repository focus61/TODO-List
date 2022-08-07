//
//  AllTaskViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 02.08.2022.
//

import UIKit
protocol Update {
    func updateDate()
}
protocol ShowAndHide {
    func show(newItem: [TodoItem])
    func hide(newItem: [TodoItem])
}
protocol UpdateEclipse {
    func updateEclipse(item: TodoItem)
}

class AllTaskViewController: UITableViewController {
    private var allTask = [TodoItem]()
    private var filteredAllTask = [TodoItem]()
    private var isFiltered = true
    private let fileCache = FileCache()
    private let button = UIButton()
    private var isLoad = false
    private var isNameShowButtonForHeader = true
    private var displayMode: DisplayMode = .lightMode
    private var counter = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        configure()
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(changeOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.navigationController?.view.addSubview(button)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.button.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayMode = traitCollection.userInterfaceStyle == .dark ? .darkMode : .lightMode
        if counter == 1 {
            tableView.reloadData()
            counter = 0
        }
        view.setNeedsDisplay()
        changeColors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.button.isHidden = true
    }
    
    @objc private func changeOrientation() {
        let buttonSize = CGSize(width: 44, height: 44)
        if UIDevice.current.orientation.isLandscape {
            button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
            button.frame.size = buttonSize
        } else {
            button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
            button.frame.size = buttonSize
        }
    }
    
    private func configure() {
        configureNavigationItem()
        buttonConfigure()
        tableViewConfigure()
    }
    private func buttonConfigure() {
        let image = UIImage(named: "Union")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
    }
    private func updateLayer() {
        let buttonSize = CGSize(width: 44, height: 44)
        button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
        button.frame.size = buttonSize
        button.layer.cornerRadius = buttonSize.height / 2
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 7
        button.layer.shadowOpacity = 0.6
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowColor = CustomColor(displayMode: .lightMode).blue.withAlphaComponent(0.9).cgColor
    }
    
    private func tableViewConfigure() {
        tableView.register(AllTaskCell.self, forCellReuseIdentifier: AllTaskCell.identifier)
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomHeaderView.identifier)
        tableView.register(AddTaskCell.self, forCellReuseIdentifier: AddTaskCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getData() {
        print("Get data")
        do {
            try fileCache.loadFromFile(FileCache.fileName)
            self.allTask = fileCache.todoItems.map { $0.value }.sorted(by: { val1, val2 in
                val1.addTaskDate < val2.addTaskDate
            })
        } catch FileCacheError.loadError(let loadErrorMessage) {
            if !(allTask.isEmpty && fileCache.todoItems.isEmpty) {
                let alert = Helpers.shared.addAlert(title: "Внимание", message: loadErrorMessage)
                present(alert, animated: true, completion: nil)
            }
        } catch {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
        self.filteredAllTask = allTask.filter { !$0.isTaskComplete }
        if allTask.count == filteredAllTask.count { isFiltered = true }
        if filteredAllTask.count == allTask.count { isNameShowButtonForHeader = true }
    }
    
    private func configureNavigationItem() {
        title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        counter = 1
    }
    
    private func changeColors() {
        tableView.backgroundColor = CustomColor(displayMode: displayMode).backPrimary
        button.backgroundColor = CustomColor(displayMode: displayMode).blue
    }
    
    @objc private func addTask() {
        let vc = CurrentTaskViewController()
        vc.delegate = self
        let navCont = UINavigationController(rootViewController: vc)
        navigationController?.present(navCont, animated: true, completion: nil)
    }
}
//MARK: - Table view data source -
extension AllTaskViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allTask.isEmpty && filteredAllTask.isEmpty {
            return 1
        }
        if isFiltered {
            return filteredAllTask.count + 1
        }
        return allTask.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var allItem = [TodoItem]()
        if isFiltered {
            allItem = filteredAllTask
        } else {
            allItem = allTask
        }
        if indexPath.row == allItem.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddTaskCell.identifier, for: indexPath) as? AddTaskCell else { return UITableViewCell() }
            cell.fillData(displayMode: displayMode)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AllTaskCell.identifier, for: indexPath) as? AllTaskCell else { return UITableViewCell() }
            let item = allItem[indexPath.row]
            cell.fillData(task: item, currentIndexpath: indexPath.row, displayMode: displayMode, tableViewWidth: tableView.bounds.width)
            cell.delegate = self
            return cell
        }
    }
}
//MARK: - Table view delegate -
extension AllTaskViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var itemArray = [TodoItem]()
        if isFiltered {
            itemArray = filteredAllTask
        } else {
            itemArray = allTask
        }
        if indexPath.row == itemArray.count {
            let vc = CurrentTaskViewController()
            vc.delegate = self
            let navCont = UINavigationController(rootViewController: vc)
            navigationController?.present(navCont, animated: true, completion: nil)
        } else {
            let item = itemArray[indexPath.row]
            let vc = CurrentTaskViewController()
            vc.currentItem = item
            vc.isChange = true
            vc.delegate = self
            let navCont = UINavigationController(rootViewController: vc)
            navigationController?.present(navCont, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let count = allTask.filter { $0.isTaskComplete }.count
        if count == 0 { return 0 }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeaderView.identifier) as? CustomHeaderView else { return nil }
        let count = allTask.filter { $0.isTaskComplete }.count
        header.fillData(countTaskComplete: count, displayMode: displayMode, allTask: allTask, isShowButton: isNameShowButtonForHeader)
        header.delegate = self
        return header
    }
}
//MARK: - Leading & Trailing swipe -
extension AllTaskViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var itemArray = [TodoItem]()
        if isFiltered {
            itemArray = filteredAllTask
            if indexPath.row == filteredAllTask.count { return nil }
        } else {
            itemArray = allTask
            if indexPath.row == allTask.count { return nil }
        }
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _,_,_ in
            guard let self = self else { return }
            var itemId = ""
            if self.isFiltered {
                itemId = self.filteredAllTask[indexPath.row].id
                self.filteredAllTask.remove(at: indexPath.row)
                self.allTask.removeAll { $0.id == itemId }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                itemId = self.allTask[indexPath.row].id
                self.allTask.remove(at: indexPath.row)
                self.filteredAllTask.removeAll { $0.id == itemId }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            self.fileCache.deleteTask(id: itemId)
            do {
                try self.fileCache.saveToFile(FileCache.fileName)
            } catch FileCacheError.saveError(let saveErrorMessage) {
                let alert = Helpers.shared.addAlert(title: "Внимание", message: saveErrorMessage)
                self.present(alert, animated: true, completion: nil)
            } catch  {
                let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
                self.present(alert, animated: true, completion: nil)
            }
            self.getData()
            self.tableView.reloadData()
        }
        let infoAction = UIContextualAction(style: .normal, title: nil) { [weak self] _,_,_ in
            guard let self = self else { return }
            let item = itemArray[indexPath.row]
            let vc = CurrentTaskViewController()
            vc.currentItem = item
            vc.isChange = true
            vc.delegate = self
            let navCont = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navCont, animated: true, completion: nil)
        }
        infoAction.backgroundColor = CustomColor(displayMode: .lightMode).grayLight
        infoAction.image = UIImage(systemName: "info.circle")
        deleteAction.image = UIImage(systemName: "trash")
        let actions = UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        return actions
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var itemArray = [TodoItem]()
        if isFiltered {
            itemArray = filteredAllTask
            if indexPath.row == filteredAllTask.count { return nil }
        } else {
            itemArray = allTask
            if indexPath.row == allTask.count { return nil }
        }
        let currentTask = itemArray[indexPath.row]
        let doneAction = UIContextualAction(style: .normal, title: nil) {[weak self] _,_,_ in
            guard let self = self else { return }
            let isDone = true
            let item = TodoItem(id: currentTask.id, text: currentTask.text, important: currentTask.important, deadline: currentTask.deadLine, isTaskComplete: isDone, addTaskDate: currentTask.addTaskDate, changeTaskDate: currentTask.changeTaskDate)
            self.fileCache.deleteTask(id: item.id)
            self.fileCache.addTask(item: item)
            do {
                try self.fileCache.saveToFile(FileCache.fileName)
            } catch FileCacheError.saveError(let saveErrorMessage) {
                let alert = Helpers.shared.addAlert(title: "Внимание", message: saveErrorMessage)
                self.present(alert, animated: true, completion: nil)
            } catch  {
                let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
                self.present(alert, animated: true, completion: nil)
            }
            self.getData()
            self.tableView.reloadData()
        }
        doneAction.image = UIImage(named: "done")
        doneAction.backgroundColor = CustomColor(displayMode: .lightMode).green
        let actions = UISwipeActionsConfiguration(actions: [doneAction])
        return actions
    }
}
//MARK: - UIContextMenuConfiguration -
extension AllTaskViewController {
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        var itemArray = [TodoItem]()
        if isFiltered {
            itemArray = filteredAllTask
            if indexPath.row == filteredAllTask.count { return nil }
        } else {
            itemArray = allTask
            if indexPath.row == allTask.count { return nil }
        }
        let item = itemArray[indexPath.row]
        let actionProvider: UIContextMenuActionProvider = { _ in
            let editMenu = UIMenu(title: "Редактирование", children: [
                UIAction(title: "Копировать текст") { _ in
                    UIPasteboard.general.string = item.text
                },
                UIAction(title: "Дублировать задачу") { [ weak self ] _ in
                    guard let self = self else { return }
                    let newItem = TodoItem(text: item.text, important: item.important, addTaskDate: Date.now)
                    self.fileCache.addTask(item: newItem)
                    do {
                        try self.fileCache.saveToFile(FileCache.fileName)
                    } catch FileCacheError.saveError(let saveErrorMessage) {
                        let alert = Helpers.shared.addAlert(title: "Внимание", message: saveErrorMessage)
                        self.present(alert, animated: true, completion: nil)
                    } catch  {
                        let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.getData()
                    self.tableView.reloadData()
                }
            ])
            return UIMenu(title: "Действия", children: [ editMenu ])
        }
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { () -> UIViewController? in
                let vc = CurrentTaskViewController()
                vc.currentItem = item
                vc.isChange = true
                vc.delegate = self
                let navCont = UINavigationController(rootViewController: vc)
                return navCont
            },
            actionProvider: actionProvider)
    }
    
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let destinationViewController = animator.previewViewController else {
            return
        }
        animator.addAnimations {
            self.show(destinationViewController, sender: self)
        }
    }
}
//MARK: - Delegate methods -
extension AllTaskViewController: Update {
    func updateDate() {
        getData()
        self.tableView.reloadData()
    }
}

extension AllTaskViewController: UpdateEclipse {
    func updateEclipse(item: TodoItem) {
        fileCache.deleteTask(id: item.id)
        fileCache.addTask(item: item)
        do {
            try fileCache.saveToFile(FileCache.fileName)
        } catch FileCacheError.saveError(let saveErrorMessage) {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: saveErrorMessage)
            present(alert, animated: true, completion: nil)
        } catch  {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
        getData()
        self.tableView.reloadData()
    }
}

extension AllTaskViewController: ShowAndHide {
    func show(newItem: [TodoItem]) {
        self.isNameShowButtonForHeader = false
        self.isFiltered = false
        self.tableView.reloadData()
    }
    
    func hide(newItem: [TodoItem]) {
        self.isFiltered = true
        self.isNameShowButtonForHeader = true
        self.tableView.reloadData()
    }
}







