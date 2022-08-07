//
//  CustomViewForTableView.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import UIKit
final class CustomTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .plain)
        self.register(ImportantTableViewCell.self, forCellReuseIdentifier: ImportantTableViewCell.identifier)
        self.register(DeadlineDateTableViewCell.self, forCellReuseIdentifier: DeadlineDateTableViewCell.identifier)
        self.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.identifier)
        isScrollEnabled = false
        separatorStyle = .singleLine
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

