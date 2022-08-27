//
//  AllTaskViewController.swift
//  Todo-List
//
//  Created by Aleksandr on 02.08.2022.
//
import UIKit
import CocoaLumberjack

protocol WorkWithFileCache {
    func saveDataInFileCache(isBeginUpdates: Bool)
    func loadDataInFileCache(handler: @escaping ([TodoItem]) -> Void)
}

final class AllTaskTableViewController: UITableViewController {
    private var currentItems = [TodoItem]()
    private let activityIndiicatorView: UIActivityIndicatorView = .init(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    private var allTask: [TodoItem] {
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
        loggerConfigure()
        configure()
        activityConfigure()
        loadDataInFileCache { items in
            self.currentItems = items
            self.tableView.reloadData()
        }
        
        let net = NetworkService()
        net.getAllTodoItems { result in
            switch result {
            case .failure(let err): print(err.localizedDescription)
            case .success(let item): print(item)
            }
        }
        
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
        activityIndiicatorView.frame.size = CGSize(width: 25, height: 25)
        activityIndiicatorView.center = view.center
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.button.isHidden = true
    }
    
    @objc private func changeOrientation() {
        button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
    }
    
    private func activityConfigure() {
        self.navigationController?.view.addSubview(activityIndiicatorView)
        tableView.isHidden = true
        activityIndiicatorView.isHidden = false
        activityIndiicatorView.startAnimating()
        activityIndiicatorView.hidesWhenStopped = true
    }
    
    private func loggerConfigure() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
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
            itemId = self.allTask[indexPath.row].id
            self.fileCache.deleteTask(id: itemId)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveDataInFileCache(isBeginUpdates: true)

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
    }
    
    func deleteTask(id: String) {
        self.fileCache.deleteTask(id: id)
        saveDataInFileCache()
    }
}

extension AllTaskTableViewController: UpdateStatusTaskDelegate {
    func updateStatus(item: TodoItem) {
        fileCache.deleteTask(id: item.id)
        fileCache.addTask(item: item)
        saveDataInFileCache()
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
    
    func saveDataInFileCache(isBeginUpdates: Bool = false) {
        tableView.isHidden = true
        activityIndiicatorView.isHidden = false
        activityIndiicatorView.startAnimating()
        fileCache.save(to: FileCache.fileName) { result in
            switch result {
            case .failure(let saveErrorMessage):
                let alert = self.addAlert(title: "Внимание", message: saveErrorMessage.localizedDescription)
                DDLogError("Error")
                self.present(alert, animated: true, completion: nil)
            case .success:
                self.loadDataInFileCache { items in
                    self.currentItems = items
                    if !isBeginUpdates {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    func loadDataInFileCache(handler: @escaping ([TodoItem]) -> Void) {
        fileCache.load(from: FileCache.fileName) { result in
            switch result {
            case .success(let items):
                self.activityIndiicatorView.stopAnimating()
                self.tableView.isHidden = false
                handler(items)
            case .failure(let loadErrorMessage):
                if !(self.allTask.isEmpty && self.fileCache.todoItems.isEmpty) {
                    let alert = self.addAlert(title: "Внимание", message: loadErrorMessage.localizedDescription)
                    DDLogError("Error")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
