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
    private enum Consts {
        case trailingInset
        case leadingInset
        case importantLabelWidth
        
        var value: CGFloat {
            switch self {
            case .trailingInset, .leadingInset:
                return 10
            case .importantLabelWidth:
                return 100
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ImportantTableViewCell.identifier)
        viewConfigure()
    }
    
    func fillData(segmentedValue: Int) {
        self.importantSegmentControl.selectedSegmentIndex = segmentedValue
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    private func colorsConfigure() {
        contentView.backgroundColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).backSecondary
        })
        importantLabel.textColor = UIColor(dynamicProvider: { trait in
            return CustomColor(trait: trait).labelPrimary
        })
    }
    private func viewConfigure() {
        labelConfigure()
        importantSegmentControlConfigure()
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        colorsConfigure()
    }
    
    private func labelConfigure() {
        contentView.addSubview(importantLabel)
        importantLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importantLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importantLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Consts.leadingInset.value),
            importantLabel.widthAnchor.constraint(equalToConstant: Consts.importantLabelWidth.value)
        ])
        importantLabel.text = "Важность"
        
    }
    private func importantSegmentControlConfigure() {
        contentView.addSubview(importantSegmentControl)
        importantSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            importantSegmentControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importantSegmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Consts.trailingInset.value)
        ])
        let uninportantImage = UIImage(named: "unimportantImage")
        importantSegmentControl.insertSegment(with: uninportantImage, at: 0, animated: true)
        importantSegmentControl.insertSegment(withTitle: "нет", at: 1, animated: true)
        importantSegmentControl.insertSegment(withTitle: "‼️", at: 2, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
