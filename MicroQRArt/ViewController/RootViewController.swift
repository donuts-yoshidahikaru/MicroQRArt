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
    private let pageControllerView = PageControllerView()
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
        pageControllerView.contentView.delegate = self
        view.backgroundColor = .background
        layout()
    }
    
    private func setupBindings() {
        // ナビゲーション状態の監視
        viewModel.pageControllerState
            .sink { state in }
            .store(in: &cancellables)

        // ナビゲーションボタンの状態監視
        viewModel.pageControllerButtonStates
            .sink { [weak self] buttonStates in
                self?.pageControllerView.contentView.configure(with: buttonStates)
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
        pageVC.setViewControllers(
            [viewControllers[viewModel.initialSelectedTabIndex]],
            direction: .forward,
            animated: false
        )
    }
    
    // MARK: - UI Layout
    private func layout() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        view.addSubview(pageControllerView)
        pageVC.didMove(toParent: self)
        
        pageControllerView.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: pageControllerView.topAnchor)
        ])
    }
    
    // MARK: - Private Methods
    private func performTransition(from old: RootViewControllerType, to new: RootViewControllerType, direction: UIPageViewController.NavigationDirection) {
        pageVC.setViewControllers(
            [viewControllers[new.rawValue]],
            direction: direction,
            animated: true
        )
    }
}

// MARK: - NavigationContentViewDelegate
extension RootViewController: PageControllerContentViewDelegate {
    func PageControllerContentView(_ view: PageControllerContentView, didTap type: RootViewControllerType) {
        viewModel.didTapPageController(type)
    }
}
