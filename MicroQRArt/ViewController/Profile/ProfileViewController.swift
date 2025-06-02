//
//  ProfileViewController.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit
import SwiftUI

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         let profileView = ProfileView()
         profileView.frame = view.bounds
         view.addSubview(profileView)
    }
}
