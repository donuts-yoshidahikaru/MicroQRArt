//
//  NavigationContentView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit

protocol NavigationContentViewDelegate: AnyObject {
    func navigationContentView(_ view: NavigationContentView, didTap type: ParentViewControllerType)
}

final class NavigationContentView: UIView {
    weak var delegate: NavigationContentViewDelegate?

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

// MARK: - IBAction
private extension NavigationContentView {
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        delegate?.navigationContentView(self, didTap: .home)
    }
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        delegate?.navigationContentView(self, didTap: .profile)
    }
    @IBAction func decorationButtonTapped(_ sender: UIButton) {
        delegate?.navigationContentView(self, didTap: .decoration)
    }
}
