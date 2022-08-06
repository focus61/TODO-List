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
    var allTask = [TodoItem]()
    var filteredAllTask = [TodoItem]()
    var isFiltered = true
    let fileCache = FileCache()
    let button = UIButton()
    var isLoad = false
    var displayMode: DisplayMode = .lightMode
    var counter = 1
    
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
    
    @objc func changeOrientation() {
        let buttonSize = CGSize(width: 44, height: 44)
        
        if UIDevice.current.orientation.isLandscape {
            button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
            button.frame.size = buttonSize
        } else {
            button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
            button.frame.size = buttonSize
        }
}
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        let buttonSize = CGSize(width: 44, height: 44)
//        let orientation = UIDevice.current.orientation.rawValue
//        switch orientation {
//        case 1:
//            print("OK1")
//
//            print(view.center.x, view.center.y)
//
//        case 3:
//            print("OK3")
//
//
//        case 4:
//            print("OK4")
//
//            button.frame.origin = CGPoint(x: 200, y: 200)
//            button.frame.size = buttonSize
//            print(view.center.x, view.center.y)
//            view.layoutIfNeeded()
//
//
//        default: break
//
//        }
//    }

    private func configure() {
        configureNavigationItem()
        buttonConfigure()
        tableViewConfigure()
    }
    func buttonConfigure() {
        let image = UIImage(named: "Union")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
    }
    func updateLayer() {
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

    func tableViewConfigure() {
        tableView.register(AllTaskCell.self, forCellReuseIdentifier: AllTaskCell.identifier)
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomHeaderView.identifier)
        tableView.register(AddTaskCell.self, forCellReuseIdentifier: AddTaskCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.button.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLayer()
    }
    
    private func getData() {
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
    }
    
    private func configureNavigationItem() {
        title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
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
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        counter = 1
    }
    private func changeColors() {
        
        tableView.backgroundColor = CustomColor(displayMode: displayMode).backPrimary
        button.backgroundColor = CustomColor(displayMode: displayMode).blue
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.button.isHidden = true
    }
//    private func configureTableView() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.delegate = self
//        tableView.dataSource = self
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.heightAnchor.constraint(equalToConstant: 300),
//            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
//            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: <#T##CGFloat#>)
//        ])
//        tableView.layer.cornerRadius = 16
//        tableView.register(AllTaskCell.self, forCellReuseIdentifier: AllTaskCell.identifier)
//    }
    @objc func addTask() {
        let vc = CurrentTaskViewController()
        vc.delegate = self
        let navCont = UINavigationController(rootViewController: vc)
        print(navigationController?.modalPresentationStyle.rawValue)
        navigationController?.present(navCont, animated: true, completion: nil)
    }
}
extension AllTaskViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allTask.count == 0 && filteredAllTask.count == 0 {
            return 0
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
    @objc func changeEclipseStatus(_ sender: UIButton) {
    }
    
}

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
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let item = itemArray[indexPath.row]
            let vc = CurrentTaskViewController()
            vc.currentItem = item
            vc.isChange = true
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
        
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeaderView.identifier) as? CustomHeaderView else { return nil }
        let count = allTask.filter { $0.isTaskComplete }.count
        if count == 0 { return nil}
        header.fillData(countTaskComplete: count, displayMode: displayMode, allTask: allTask)
        header.delegate = self
        return header
    }
}
//MARK: - Leading & Trailing swipe -
extension AllTaskViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}
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
        self.isFiltered = false
        self.tableView.reloadData()
    }
    func hide(newItem: [TodoItem]) {
        self.isFiltered = true
        self.tableView.reloadData()
    }
}







