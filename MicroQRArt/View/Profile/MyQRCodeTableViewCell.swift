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
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .content
        return label
    }()
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryContent
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryContent
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
        let paddingVertical: CGFloat = 7
        let paddingLeft: CGFloat = 16
        let paddingRight: CGFloat = 16
        let interItemSpacing: CGFloat = 12
        let verticalSpacing: CGFloat = 4
        let iconSize: CGFloat = self.bounds.height - paddingVertical * 2
        let titleX = paddingLeft + iconSize + interItemSpacing
        let titleWidth = contentView.bounds.width - titleX - paddingRight
        let titleHeight = titleLabel.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude)).height
        let urlY = paddingVertical
            + titleHeight
            + verticalSpacing
        let urlHeight = sourceLabel.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude)).height
        let dateY = paddingVertical
            + titleHeight
            + verticalSpacing
            + urlHeight
            + verticalSpacing
        let dateHeight = dateLabel.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude)).height
        // iconView
        iconView.frame = CGRect(x: paddingLeft, y: paddingVertical, width: iconSize, height: iconSize)
        // titleLabel
        titleLabel.frame = CGRect(x: titleX, y: iconView.frame.minY, width: titleWidth, height: titleHeight)
        // urlLabel
        sourceLabel.frame = CGRect(x: titleX, y: urlY, width: titleWidth, height: urlHeight)
        // dateLabel
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
