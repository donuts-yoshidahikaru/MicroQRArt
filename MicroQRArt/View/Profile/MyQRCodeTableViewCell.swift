//
//  MyQRCodeTableViewCell.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit

class MyQRCodeTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let iconView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .content
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryContent
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryContent
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.background
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(dateLabel)
        let selectedBG = UIView()
        selectedBG.backgroundColor = UIColor.subtleContent
        selectedBackgroundView = selectedBG
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let paddingTop: CGFloat = 8
        let paddingLeft: CGFloat = 16
        let iconSize: CGFloat = 56
        let paddingRight: CGFloat = 16
        let interItemSpacing: CGFloat = 12
        let verticalSpacing: CGFloat = 4
        // iconView
        iconView.frame = CGRect(x: paddingLeft, y: paddingTop, width: iconSize, height: iconSize)
        // titleLabel
        let titleX = iconView.frame.maxX + interItemSpacing
        let titleWidth = contentView.bounds.width - titleX - paddingRight
        let titleHeight = titleLabel.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude)).height
        titleLabel.frame = CGRect(x: titleX, y: iconView.frame.minY, width: titleWidth, height: titleHeight)
        // urlLabel
        let urlY = titleLabel.frame.maxY + verticalSpacing
        let urlHeight = sourceLabel.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude)).height
        sourceLabel.frame = CGRect(x: titleX, y: urlY, width: titleWidth, height: urlHeight)
        // dateLabel
        let dateY = sourceLabel.frame.maxY + verticalSpacing
        let dateHeight = dateLabel.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude)).height
        dateLabel.frame = CGRect(x: titleX, y: dateY, width: titleWidth, height: dateHeight)
    }
    // MARK: - Public Methodsa
    /// - Parameters:
    ///   - title: タイトル
    ///   - source: URL文字列
    ///   - date: 作成日
    public func configure(title: String, source: String, date: String) {
        titleLabel.text = title
        sourceLabel.text = source
        dateLabel.text = date
    }
}
