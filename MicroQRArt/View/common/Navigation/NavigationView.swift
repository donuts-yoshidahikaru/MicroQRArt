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
        let width = UIScreen.main.bounds.width
        let height: CGFloat = fixedHeight + self.safeAreaInsets.bottom
        
        contentView.frame = CGRect(x: 0, y: 0, width: width, height: fixedHeight)
        self.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - height, width: width, height: height)

    }
    
    required init?(coder: NSCoder){ fatalError("init(coder:) has not been implemented"); }
}
