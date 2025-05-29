//
//  RootViewController.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit
import Combine

final class RootViewController: UIViewController {
    // MARK: - UI Components
    private let navView = NavigationView()
    private let pageVC = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    // MARK: - Child ViewControllers
    private lazy var viewControllers: [UIViewController] = [
        DecorationViewController(),
        HomeViewController(),
        ProfileViewController()
    ]
    
    // MARK: - ViewModel & Binding
    private let viewModel: RootViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(viewModel: RootViewModelProtocol = RootViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = RootViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        setupInitialState()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        navView.contentView.delegate = self
        view.backgroundColor = .background
        layout()
    }
    
    private func setupBindings() {
        // ナビゲーション状態の監視
        viewModel.navigationState
            .sink { state in }
            .store(in: &cancellables)

        // ナビゲーションボタンの状態監視
        viewModel.navigationButtonStates
            .sink { [weak self] buttonStates in
                self?.navView.contentView.configure(with: buttonStates)
            }
            .store(in: &cancellables)
            
        // 画面遷移の実行
        viewModel.shouldTransition
            .sink { [weak self] transition in
                self?.performTransition(
                    from: transition.from,
                    to: transition.to,
                    direction: transition.direction
                )
            }
            .store(in: &cancellables)
    }
    
    private func setupInitialState() {
        guard let initialIndex = viewModel.navigationState.value.currentIndex else { return }
        pageVC.setViewControllers(
            [viewControllers[initialIndex]],
            direction: .forward,
            animated: false
        )
    }
    
    // MARK: - UI Layout
    private func layout() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        view.addSubview(navView)
        pageVC.didMove(toParent: self)
        
        navView.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: navView.topAnchor)
        ])
    }
    
    // MARK: - Private Methods
    private func performTransition(from oldIndex: Int, to newIndex: Int, direction: UIPageViewController.NavigationDirection) {
        pageVC.setViewControllers(
            [viewControllers[newIndex]],
            direction: direction,
            animated: true
        )
    }
}

// MARK: - NavigationContentViewDelegate
extension RootViewController: NavigationContentViewDelegate {
    func navigationContentView(_ view: NavigationContentView, didTap type: RootViewControllerType) {
        viewModel.didTapNavigation(type)
    }
}
