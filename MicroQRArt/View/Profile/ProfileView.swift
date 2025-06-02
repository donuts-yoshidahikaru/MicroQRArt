//
//  ProfileView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit

/// QRコード一覧画面（UIKit版View）。
///
/// WHY: SwiftUIからUIKitへの移行。View単体で再利用性を高めるため。
class ProfileView: UIView {
    private let tableView = MyQRCodeTableView(frame: .zero, style: .plain)
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My QR Codes"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor.content
        label.textAlignment = .center
        label.backgroundColor = UIColor.background
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let labelHeight: CGFloat = 56
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.background
        addSubview(titleLabel)
        addSubview(tableView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupLayout() {
        titleLabel.frame = CGRect(
            x: 0, y: 0, width: bounds.width, height: labelHeight
        )
        tableView.frame = CGRect(
            x: 0, y: labelHeight, width: bounds.width, height: bounds.height - labelHeight
        )
    }
}
