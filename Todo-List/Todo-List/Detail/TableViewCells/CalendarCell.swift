//
//  CalendarCell.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import UIKit

protocol UpdateDateWithDatePickerDelegate {
    func update(currentDate: Date)
}

final class CalendarCell: UITableViewCell {
    static let identifier = "CalendarCell"
    private let datePicker = UIDatePicker()
    private var changedDeadlineDate: Date?
    var delegate: UpdateDateWithDatePickerDelegate?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: CalendarCell.identifier)
        datePickerConfigure()
        datePicker.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
    }
    func fillData(changedDeadlineDate: Date) {
        datePicker.minimumDate = Date.now
        self.changedDeadlineDate = changedDeadlineDate
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    private func datePickerConfigure() {
        contentView.addSubview(datePicker)
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.isUserInteractionEnabled = true
        datePicker.addTarget(self, action: #selector(getDateFromCalendar(sender:)), for: .valueChanged)
    }
    
    @objc func getDateFromCalendar(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        delegate?.update(currentDate: sender.date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
