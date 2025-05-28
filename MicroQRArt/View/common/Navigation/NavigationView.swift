//
//  NavigationView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit

final class NavigationView: UIView {
    private let contentView = NavigationContentView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        self.backgroundColor = .subtleContent
        
        self.addSubview(contentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let safeBottom = self.safeAreaInsets.bottom
        let width = UIScreen.main.bounds.width
        let height: CGFloat = 73 + safeBottom
        
        // safeAreaより上、高さ73固定
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: 73)
        // 下部固定、高さ=73+safeArea
        self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - height, width: width, height: height)
    }
    
    required init?(coder: NSCoder){ fatalError("init(coder:) has not been implemented"); }
}
