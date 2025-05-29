//
//  NavigationContentView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit
import Combine

protocol NavigationContentViewDelegate: AnyObject {
    func navigationContentView(_ view: NavigationContentView, didTap type: RootViewControllerType)
}

final class NavigationContentView: UIView {

    // MARK: - IBOutlets
    @IBOutlet private weak var decorationButton: UIButton!
    @IBOutlet private weak var homeButton: UIButton!
    @IBOutlet private weak var profileButton: UIButton!

    // MARK: - Properties
    weak var delegate: NavigationContentViewDelegate?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let view = UINib(nibName: "NavigationContentView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configure(with buttonStates: [NavigationButtonState]) {
        for buttonState in buttonStates {
            updateButton(for: buttonState)
        }
    }
    
    private func updateButton(for state: NavigationButtonState) {
        let button = getButton(for: state.type)
        let systemImage = UIImage(systemName: state.systemIconName)
        
        button?.setImage(systemImage, for: .normal)
    }
    
    private func getButton(for type: RootViewControllerType) -> UIButton? {
        switch type {
        case .decoration: return decorationButton
        case .home: return homeButton
        case .profile: return profileButton
        }
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
