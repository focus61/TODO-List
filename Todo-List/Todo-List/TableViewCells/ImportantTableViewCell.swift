//
//  ImportantTableViewCell.swift
//  Todo-List
//
//  Created by Aleksandr on 31.07.2022.
//

import UIKit
final class ImportantTableViewCell: UITableViewCell {
    static let identifier = "ImportantTableViewCell"
    private let importantLabel: UILabel = .init(frame: .zero)
    let importantSegmentControl: UISegmentedControl = .init(frame: .zero)
    private var displayMode: DisplayMode = .lightMode
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ImportantTableViewCell.identifier)
        viewConfigure()
    }
    func fillData(displayMode: DisplayMode, segmentedValue: Int) {
        self.displayMode = displayMode
        
        self.importantSegmentControl.selectedSegmentIndex = segmentedValue
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = CustomColor(displayMode: displayMode).backSecondary
        importantLabel.textColor = CustomColor(displayMode: displayMode).labelPrimary
        importantSegmentControl.backgroundColor = CustomColor(displayMode: displayMode).supportOverlay
    }
    private func viewConfigure() {
        labelConfigure()
        importantSegmentControlConfigure()
        
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    }
    private func labelConfigure() {
        contentView.addSubview(importantLabel)
        importantLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importantLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importantLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            importantLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        importantLabel.text = "Важность"
        
    }
    private func importantSegmentControlConfigure() {
        contentView.addSubview(importantSegmentControl)
        importantSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importantSegmentControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importantSegmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            importantSegmentControl.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -160)
        ])
        var uninportantImage = UIImage(named: "unimportantImage")?.withRenderingMode(.alwaysTemplate)
        let uninportantImageColor = CustomColor(displayMode: displayMode).gray
        uninportantImage = uninportantImage?.withTintColor(uninportantImageColor)
        var importantImage = UIImage(named: "importantImage")?.withRenderingMode(.alwaysTemplate)
        let importantImageColor = CustomColor(displayMode: displayMode).red
        importantImage = importantImage?.withTintColor(importantImageColor)
        importantSegmentControl.insertSegment(with: uninportantImage, at: 0, animated: false)
        importantSegmentControl.insertSegment(withTitle: "нет", at: 1, animated: false)
        importantSegmentControl.insertSegment(with: importantImage, at: 2, animated: false)
        
    }
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UISegmentedControl{
    func selectedSegmentTintColor(_ color: UIColor) {
        self.setTitleTextAttributes([.foregroundColor: color], for: .selected)
    }
    func unselectedSegmentTintColor(_ color: UIColor) {
        self.setTitleTextAttributes([.foregroundColor: color], for: .normal)
    }
}
