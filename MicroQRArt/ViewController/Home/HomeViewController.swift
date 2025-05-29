//
//  HomeViewController.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit

final class HomeViewController: UIViewController {
    @IBOutlet weak var sourceTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissRecognizer()
        sourceTextField.returnKeyType = .done
        sourceTextField.delegate = self
    }

    private func setupKeyboardDismissRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
