//
//  MyQRCodeTableViewCell.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit

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
    private var imageDownloadTask: URLSessionDataTask?

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
        imageDownloadTask?.cancel()
        imageDownloadTask = nil
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
    // MARK: - Public Methodsa
    /// - Parameters:
    ///   - title: タイトル
    ///   - source: URL文字列
    ///   - date: 作成日
    func configure(title: String, source: String, date: String, image: String?) {
        titleLabel.text = title
        sourceLabel.text = source
        dateLabel.text = date
        
        // Load image from URL
        if let imageURLString = image, let imageURL = URL(string: imageURLString) {
            loadImage(from: imageURL)
        } else {
            // Set default QR code placeholder
            previewImageView.image = createPlaceholderQRImage()
        }
    }
    
    // MARK: - Image Loading
    private func loadImage(from url: URL) {
        // Cancel previous task
        imageDownloadTask?.cancel()
        
        // Set placeholder while loading
        previewImageView.image = createPlaceholderQRImage()
        
        imageDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.previewImageView.image = self?.createPlaceholderQRImage()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.previewImageView.image = image
            }
        }
        
        imageDownloadTask?.resume()
    }
    
    private func createPlaceholderQRImage() -> UIImage? {
        let size = CGSize(width: 56, height: 56)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // Background
        UIColor.systemGray5.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // QR pattern simulation
        UIColor.label.setFill()
        let patternSize: CGFloat = 4
        
        for row in 0..<Int(size.height / patternSize) {
            for col in 0..<Int(size.width / patternSize) {
                if (row + col) % 2 == 0 {
                    let rect = CGRect(
                        x: CGFloat(col) * patternSize,
                        y: CGFloat(row) * patternSize,
                        width: patternSize,
                        height: patternSize
                    )
                    UIRectFill(rect)
                }
            }
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
