//
//  PageControllerContentView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit
import Combine

protocol PageControllerContentViewDelegate: AnyObject {
    func PageControllerContentView(_ view: PageControllerContentView, didTap type: RootViewControllerType)
}

final class PageControllerContentView: UIView {

    // MARK: - IBOutlets
    @IBOutlet private weak var decorationButton: UIButton!
    @IBOutlet private weak var homeButton: UIButton!
    @IBOutlet private weak var profileButton: UIButton!

    // MARK: - Properties
    weak var delegate: PageControllerContentViewDelegate?
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
        let view = UINib(nibName: "PageControllerContentView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func configure(with buttonStates: [PageControllerButtonState]) {
        for buttonState in buttonStates {
            updateButton(for: buttonState)
        }
    }
    
    private func updateButton(for state: PageControllerButtonState) {
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
private extension PageControllerContentView {
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        delegate?.PageControllerContentView(self, didTap: .home)
    }
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        delegate?.PageControllerContentView(self, didTap: .profile)
    }
    @IBAction func decorationButtonTapped(_ sender: UIButton) {
        delegate?.PageControllerContentView(self, didTap: .decoration)
    }
}
