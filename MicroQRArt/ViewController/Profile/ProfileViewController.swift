//
//  ProfileViewController.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: MyQRCodeListViewModel
    private let disposables = CompositeDisposable()
    private let profileView = ProfileView()

    // MARK: - Reactive Properties
    private let deleteActionPipe = Signal<IndexPath, Never>.pipe()
    private let editActionPipe = Signal<(IndexPath, String), Never>.pipe()
    private let viewDidLoadPipe = Signal<Void, Never>.pipe()
    private let editAlertRequestPipe = Signal<IndexPath, Never>.pipe()

    // MARK: - Data Source
    private lazy var dataSource = MyQRCodeTableViewDataSource(
        animationConfig: AnimationConfiguration(
            insertAnimation: .automatic,
            deleteAnimation: .automatic,
            reloadAnimation: .automatic
        )
    )

    // MARK: - Initialization
    init(viewModel: MyQRCodeListViewModel = MyQRCodeListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposables.dispose()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewDidLoadPipe.input.send(value: ())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView.frame = view.bounds
    }

    // MARK: - Setup
    private func setupView() {
        profileView.frame = view.bounds
        view.addSubview(profileView)
        
        profileView.tableView.delegate = self
        profileView.tableView.dataSource = dataSource
    }

    private func bindViewModel() {
        disposables += viewDidLoadPipe.output.observe(viewModel.inputs.viewDidLoad)
        disposables += deleteActionPipe.output.observe(viewModel.inputs.deleteAction)
        disposables += editActionPipe.output.observe(viewModel.inputs.editAction)
        disposables += editAlertRequestPipe.output.observe(viewModel.inputs.editAlertRequest)

        profileView.tableView.bind(source: viewModel.outputs.sections, dataSource: dataSource)

        disposables += viewModel.outputs.errorMessage
            .observe(on: UIScheduler())
            .observeValues { [weak self] message in
                self?.showErrorAlert(message: message)
            }

        disposables += viewModel.outputs.showEditAlert
            .observe(on: UIScheduler())
            .observeValues { [weak self] (indexPath, currentTitle) in
                self?.showEditAlert(indexPath: indexPath, currentTitle: currentTitle)
            }
    }
    
    // MARK: - Private Methods
    private func showEditAlert(indexPath: IndexPath, currentTitle: String) {
        let alert = UIAlertController(title: "タイトル編集", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = currentTitle
            textField.placeholder = "新しいタイトルを入力"
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        let updateAction = UIAlertAction(title: "更新", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            self?.editActionPipe.input.send(value: (indexPath, newTitle))
        }
        
        alert.addAction(cancelAction)
        alert.addAction(updateAction)
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = createEditAction(for: indexPath)
        let deleteAction = createDeleteAction(for: indexPath)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    private func createEditAction(for indexPath: IndexPath) -> UIContextualAction {
        let editAction = UIContextualAction(style: .normal, title: "編集") { [weak self] (_, _, completionHandler) in
            self?.editAlertRequestPipe.input.send(value: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        return editAction
    }
    
    private func createDeleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { [weak self] (_, _, completionHandler) in
            self?.deleteActionPipe.input.send(value: indexPath)
            completionHandler(true)
        }
        return deleteAction
    }
}
