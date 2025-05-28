//
//  ParentViewController.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit

class ParentViewController: UIViewController {
    
    private let navigationView = NavigationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.contentView.delegate = self
        view.addSubview(navigationView)
    }
}

// MARK: - NavigationContentViewDelegate

extension ParentViewController: NavigationContentViewDelegate {
    func navigationContentView(_ view: NavigationContentView, didTap type: ParentViewControllerType) {
        print("navigationContentView didTap: \(type)")
        switch type {
        case .home:
            print("home")
        case .profile:
            print("profile")
        case .decoration:
            print("decoration")
        }
    }
}

