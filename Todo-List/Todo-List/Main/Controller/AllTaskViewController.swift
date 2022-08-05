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
protocol Show {
    func show()
}
protocol UpdateEclipse {
    func updateEclipse(item: TodoItem)
}
protocol Hide {
    func hide()
}
class AllTaskViewController: UITableViewController {
    var allTask = [TodoItem]()
    let fileCache = FileCache()
    let button = UIButton(type: .custom)
    var isLoad = false
    var displayMode: DisplayMode = .lightMode
    var counter = 1
    override func viewDidLoad() {
        super.viewDidLoad()
//        displayMode = traitCollection.userInterfaceStyle == .dark ? .darkMode : .lightMode
        view.addSubview(button)

        configure()
        getData()
        self.navigationController?.view.addSubview(button)
    }

    private func configure() {
        configureNavigationItem()
        buttonConfigure()
        tableViewConfigure()
//        configureTableView()
    }
    func buttonConfigure() {
        let image = UIImage(named: "Union")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
    }
    func updateLayer() {
        
//        let shadowPath0 = UIBezierPath(roundedRect: button.bounds, cornerRadius: 25)
//        let layer0 = CALayer()
//        layer0.shadowPath = shadowPath0.cgPath
//        layer0.shadowColor = UIColor(red: 0, green: 0.287, blue: 0.6, alpha: 0.6).cgColor
//        layer0.shadowOpacity = 1
//        layer0.shadowRadius = 20
//        layer0.shadowOffset = CGSize(width: 0, height: 8)
//        layer0.bounds = button.bounds
//        layer0.position = button.center
//        button.layer.addSublayer(layer0)
        
        button.frame.origin = CGPoint(x: view.center.x - 25, y: view.frame.height - 100)
        button.frame.size = CGSize(width: 44, height: 44)
        button.layer.cornerRadius = 22
    }

    func tableViewConfigure() {
        tableView.register(AllTaskCell.self, forCellReuseIdentifier: AllTaskCell.identifier)
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: CustomHeaderView.identifier)
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
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
            let alert = Helpers.shared.addAlert(title: "Внимание", message: loadErrorMessage)
            present(alert, animated: true, completion: nil)
        } catch {
            let alert = Helpers.shared.addAlert(title: "Внимание", message: "Произошла ошибка")
            present(alert, animated: true, completion: nil)
        }
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
        
        navigationController?.pushViewController(vc, animated: true)
//        navigationController?.present(vc, animated: true, completion: nil)
    }
}
extension AllTaskViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTask.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AllTaskCell.identifier, for: indexPath) as? AllTaskCell else { return UITableViewCell() }
        let item = allTask[indexPath.row]
        cell.taskDescriptionLabel.preferredMaxLayoutWidth = tableView.bounds.width
        cell.fillData(task: item, currentIndexpath: indexPath.row, displayMode: displayMode)
        cell.delegate = self
        cell.layoutIfNeeded()
        return cell
    }
    @objc func changeEclipseStatus(_ sender: UIButton) {
    }
    
}

extension AllTaskViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = allTask[indexPath.row]
        let vc = CurrentTaskViewController()
        vc.currentItem = item
        vc.isChange = true
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeaderView.identifier) as? CustomHeaderView else { return nil }
        let count = allTask.filter { $0.isTaskComplete }.count
        print(count)
        header.fillData(countTaskComplete: count, displayMode: displayMode)
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
extension AllTaskViewController: Update{
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
extension AllTaskViewController: Show {
    func show() {
        self.tableView.reloadData()
    }
}







