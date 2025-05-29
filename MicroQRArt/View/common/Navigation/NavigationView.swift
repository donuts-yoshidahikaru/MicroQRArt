//
//  NavigationView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit

final class NavigationView: UIView {
    public let contentView = NavigationContentView()
    private let fixedHeight: CGFloat = 73

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        self.backgroundColor = .subtleContent
        
        self.addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: fixedHeight)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: fixedHeight + safeAreaInsets.bottom)
    }
    
    required init?(coder: NSCoder){ fatalError("init(coder:) has not been implemented"); }
}
