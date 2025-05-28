//
//  NavigationContentView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit

final class NavigationContentView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let view = UINib(nibName: "NavigationContentView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
