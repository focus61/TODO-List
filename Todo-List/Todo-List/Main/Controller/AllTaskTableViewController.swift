//
//  AllTaskViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 02.08.2022.
//
import UIKit

protocol WorkWithFileCache {
    func saveDataInFileCache()
    func loadDataInFileCache()
}
// (- Доделать ориентацию детально...). (todo)
final class AllTaskTableViewController: UITableViewController {
    private var allTask: [TodoItem] {
        let currentItems = fileCache.todoItems.map { $0.value }.sorted(by: { val1, val2 in
            val1.addTaskDate < val2.addTaskDate
        })
        let filterItems = currentItems.filter { !$0.isTaskComplete }
        if filterItems.count == currentItems.count {
            isFiltered = true
            isNameShowButtonForHeader = true
        }
        isDoneCount = currentItems.count - filterItems.count
        if isFiltered {
            return filterItems
        } else {
            return currentItems
        }
    }
    private var isDoneCount = 0
    private var isFiltered = true
    private let fileCache = FileCache()
    private let button: UIButton = .init(frame: .zero)
    private var isNameShowButtonForHeader = true
    private let addItemCellCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(changeOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        self.navigationController?.view.addSubview(button)
        changeColors()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.button.isHidden = true
    }
    
    @objc private func changeOrientation() {
        button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
    }
    
    private func configure() {
        configureNavigationItem()
        buttonConfigure()
        tableViewConfigure()
    }
    
    private func buttonConfigure() {
        let image = UIImage(named: "Union")
        self.navigationController?.view.addSubview(button)
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
        button.layer.shadowColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).blue
        }).withAlphaComponent(0.9).cgColor
    }
    
    private func tableViewConfigure() {
        tableView.register(AllTaskCell.self, forCellReuseIdentifier: AllTaskCell.identifier)
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomHeaderView.identifier)
        tableView.register(AddTaskCell.self, forCellReuseIdentifier: AddTaskCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getData() {
        loadDataInFileCache()
    }
    
    private func configureNavigationItem() {
        title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func changeColors() {
        tableView.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backPrimary
        })
        button.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).blue
        })
    }
    
    @objc private func addTask() {
        presentNewTaskScreen()
    }
    
    private func presentNewTaskScreen() {
        let currentTaskViewController = CurrentTaskViewController()
        currentTaskViewController.delegate = self
        let navCont = UINavigationController(rootViewController: currentTaskViewController)
        navigationController?.present(navCont, animated: true, completion: nil)
    }
    
    private func presentCurrentTaskScreen(item: TodoItem?) -> UINavigationController {
        let currentTaskViewController = CurrentTaskViewController()
        currentTaskViewController.currentItem = item
        currentTaskViewController.isChange = true
        currentTaskViewController.delegate = self
        let navCont = UINavigationController(rootViewController: currentTaskViewController)
        return navCont
    }
}
// MARK: - Table view data source -
extension AllTaskTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allTask.isEmpty
//            && filteredAllTask.isEmpty
        {
            return addItemCellCount
        }
        return allTask.count + addItemCellCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == allTask.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddTaskCell.identifier, for: indexPath)
            guard let addTaskCell = cell as? AddTaskCell else { return cell }
            addTaskCell.fillData()
            return addTaskCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AllTaskCell.identifier, for: indexPath)
            guard let allTaskCell = cell as? AllTaskCell else { return cell }
            let item = allTask[indexPath.row]
            allTaskCell.fillData(task: item, currentIndexpath: indexPath.row)
            allTaskCell.delegate = self
            return allTaskCell
        }
    }
}
// MARK: - Table view delegate -
extension AllTaskTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == allTask.count {
            presentNewTaskScreen()
        } else {
            let item = allTask[indexPath.row]
            self.navigationController?.present(presentCurrentTaskScreen(item: item),
                                               animated: true,
                                               completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isDoneCount == 0 { return 0 }
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeaderView.identifier)
        guard let customHeader = header as? CustomHeaderView else { return nil }
        customHeader.fillData(countTaskComplete: isDoneCount, allTask: allTask, isShowButton: isNameShowButtonForHeader)
        customHeader.delegate = self
        return customHeader
    }
}
// MARK: - Leading & Trailing swipe -
extension AllTaskTableViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, _ in
            guard let self = self else { return }
            var itemId = ""
            self.tableView.beginUpdates()
            itemId = self.allTask[indexPath.row].id
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.fileCache.deleteTask(id: itemId)
            self.saveDataInFileCache()
            self.getData()
            self.tableView.endUpdates()
        }
        let infoAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            guard let self = self else { return }
            let item = self.allTask[indexPath.row]
            self.navigationController?.present(self.presentCurrentTaskScreen(item: item),
                                               animated: true,
                                               completion: nil)
        }
        infoAction.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).grayLight
        })
        infoAction.image = UIImage(systemName: "info.circle")
        deleteAction.image = UIImage(systemName: "trash")
        let actions = UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        return actions
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentTask = allTask[indexPath.row]
        let doneAction = UIContextualAction(style: .normal, title: nil) {[weak self] _, _, _ in
            guard let self = self else { return }
            let isDone = true
            let item = currentTask.withComplete(isDone)
            self.fileCache.deleteTask(id: item.id)
            self.fileCache.addTask(item: item)
            self.saveDataInFileCache()
            self.getData()
            self.tableView.reloadData()
        }
        doneAction.image = UIImage(named: "done")
        doneAction.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).green

        })
        let actions = UISwipeActionsConfiguration(actions: [doneAction])
        return actions
    }
}
// MARK: - UIContextMenuConfiguration -
extension AllTaskTableViewController {
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = allTask[indexPath.row]
        let actionProvider: UIContextMenuActionProvider = { _ in
            let editMenu = UIMenu(title: "Редактирование", children: [
                UIAction(title: "Копировать текст") { _ in
                    UIPasteboard.general.string = item.text
                },
                UIAction(title: "Дублировать задачу") { [ weak self ] _ in
                    guard let self = self else { return }
                    let newItem = TodoItem(text: item.text, important: item.important, addTaskDate: Date.now)
                    self.fileCache.addTask(item: newItem)
                    self.saveDataInFileCache()
                    self.getData()
                    self.tableView.reloadData()
                }
            ])
            return UIMenu(title: "Действия", children: [ editMenu ])
        }
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { () -> UIViewController? in
                return self.presentCurrentTaskScreen(item: item)
            },
            actionProvider: actionProvider)
    }
// swiftlint:disable line_length
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)
// swiftlint:enable line_length
    {
        guard let destinationViewController = animator.previewViewController else {
            return
        }
        animator.addAnimations {
            self.show(destinationViewController, sender: self)
        }
    }
}
// MARK: - Delegate methods -
extension AllTaskTableViewController: UpdateAllTasksDelegate {
    func updateTask(item: TodoItem) {
        fileCache.addTask(item: item)
        saveDataInFileCache()
        getData()
        self.tableView.reloadData()
    }
    
    func deleteTask(id: String) {
        self.fileCache.deleteTask(id: id)
        saveDataInFileCache()
        getData()
        self.tableView.reloadData()

    }
}

extension AllTaskTableViewController: UpdateStatusTaskDelegate {
    func updateEclipse(item: TodoItem) {
        fileCache.deleteTask(id: item.id)
        fileCache.addTask(item: item)
        saveDataInFileCache()
        getData()
        self.tableView.reloadData()
    }
}

extension AllTaskTableViewController: ShowAndHideDoneTasksDelegate {
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

extension AllTaskTableViewController: WorkWithFileCache {
    func saveDataInFileCache() {
        do {
            try fileCache.saveToFile(FileCache.fileName)
        } catch FileCacheError.saveError(let saveErrorMessage) {
            let alert = addAlert(title: "Внимание", message: saveErrorMessage)
            present(alert, animated: true, completion: nil)
        } catch {
            let alert = addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func loadDataInFileCache() {
        do {
            try fileCache.loadFromFile(FileCache.fileName)
        } catch FileCacheError.loadError(let loadErrorMessage) {
            if !(allTask.isEmpty && fileCache.todoItems.isEmpty) {
                let alert = addAlert(title: "Внимание", message: loadErrorMessage)
                present(alert, animated: true, completion: nil)
            }
        } catch {
            let alert = addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
    }
}
