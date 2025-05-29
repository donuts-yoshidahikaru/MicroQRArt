//
//  RootViewController.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit

final class RootViewController: UIViewController {
    private let navView = NavigationView()
    private let contentHost = UIView()

    private lazy var homeVC       = HomeViewController()
    private lazy var decorationVC = DecorationViewController()
    private lazy var profileVC    = ProfileViewController()

    private lazy var viewControllers: [UIViewController] = [
        DecorationViewController(),
        HomeViewController(),
        ProfileViewController()
    ]

    private let pageVC   = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )

    private var currentIndex = 1
    private var current: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        navView.contentView.delegate = self
        view.backgroundColor = .background

        layout()
        pageVC.setViewControllers(
            [viewControllers[currentIndex]],
            direction: .forward,
            animated: false
        )
    }

    private func layout() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        view.addSubview(navView)

        pageVC.didMove(toParent: self)

        navView.translatesAutoresizingMaskIntoConstraints = false
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // NavView ― 画面最下部
            navView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // PageVC ― 上端〜NavView の上端
            pageVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: navView.topAnchor)
        ])
    }

    private func switchTo(_ type: RootViewControllerType) {
        guard let next = viewController(for: type), current != next else { return }

        transition(from: current, to: next)
        current = next
    }

    private func viewController(for type: RootViewControllerType) -> UIViewController? {
        switch type {
        case .home:       return homeVC
        case .decoration: return decorationVC
        case .profile:    return profileVC
        }
    }

    private func transition(from old: UIViewController?, to new: UIViewController) {
        // 子 VC コンテインメント標準手順
        old?.willMove(toParent: nil)
        addChild(new)

        if let old = old {
            old.view.removeFromSuperview()
            old.removeFromParent()
        }

        new.view.frame = contentHost.bounds
        contentHost.addSubview(new.view)
        new.didMove(toParent: self)
    }
}

// MARK: - NavigationContentViewDelegate

extension RootViewController: NavigationContentViewDelegate {
    func navigationContentView(_ view: NavigationContentView, didTap type: RootViewControllerType) {
        guard let newIndex = type.index, newIndex != currentIndex else { return }

        let dir: UIPageViewController.NavigationDirection =
            newIndex > currentIndex ? .forward : .reverse

        pageVC.setViewControllers(
            [viewControllers[newIndex]],
            direction: dir,
            animated: true
        )

        currentIndex = newIndex
    }
}
