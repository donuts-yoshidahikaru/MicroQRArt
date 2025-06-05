//
//  MyQRCodeTableViewCell.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

// MARK: - Configuration
struct QRCodeCellConfiguration {
    let title: String
    let source: String
    let date: String
    let image: Property<UIImage?>
    
    init(title: String, source: String, date: String, image: Property<UIImage?>) {
        self.title = title
        self.source = source
        self.date = date
        self.image = image
    }
}

class MyQRCodeTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let previewImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        view.tintColor = UIColor.content
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

    // MARK: - Properties
    private let disposables = CompositeDisposable()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.background
        contentView.addSubview(previewImageView)
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

    override func prepareForReuse() {
        super.prepareForReuse()
        disposables.dispose()
        previewImageView.image = nil
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let paddingVertical: CGFloat = 7
        let paddingLeft: CGFloat = 16
        let paddingRight: CGFloat = 16
        let interItemSpacing: CGFloat = 12
        let verticalSpacing: CGFloat = 4
        let previewImageSize: CGFloat = self.bounds.height - paddingVertical * 2
        let titleX = paddingLeft + previewImageSize + interItemSpacing
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
        previewImageView.frame = CGRect(x: paddingLeft, y: paddingVertical, width: previewImageSize, height: previewImageSize)
        // titleLabel
        titleLabel.frame = CGRect(x: titleX, y: previewImageView.frame.minY, width: titleWidth, height: titleHeight)
        // urlLabel
        sourceLabel.frame = CGRect(x: titleX, y: urlY, width: titleWidth, height: urlHeight)
        // dateLabel
        dateLabel.frame = CGRect(x: titleX, y: dateY, width: titleWidth, height: dateHeight)
    }
    
    // MARK: - Public Methods
    func configure(with configuration: QRCodeCellConfiguration) {
        titleLabel.text = configuration.title
        sourceLabel.text = configuration.source
        dateLabel.text = configuration.date
        
        // Bind image property to imageView
        disposables += configuration.image.producer
            .observe(on: UIScheduler())
            .startWithValues { [weak self] image in
                self?.previewImageView.image = image
            }
    }
}