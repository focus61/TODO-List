//
//  CalendarCell.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import UIKit
final class CalendarCell: UITableViewCell {
    static let identifier = "CalendarCell"
    let datePicker = UIDatePicker()
    private var displayMode: DisplayMode = .lightMode
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: CalendarCell.identifier)
        datePickerConfigure()
    }
    func fillData(displayMode: DisplayMode) {
        self.displayMode = displayMode
        datePicker.minimumDate = Date.now
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        datePicker.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
    }
    private func datePickerConfigure() {
        datePicker.backgroundColor = .red
        contentView.addSubview(datePicker)
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        print(datePicker.subviews)
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
