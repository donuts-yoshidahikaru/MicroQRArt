//
//  ProfileViewController.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: MyQRCodeListViewModel
    private let disposeBag = DisposeBag()
    private let profileView = ProfileView()

    // MARK: - Reactive Properties
    private let deleteActionRelay = PublishRelay<IndexPath>()
    private let editActionRelay = PublishRelay<(IndexPath, String)>()
    private let viewDidLoadRelay = PublishRelay<Void>()

    // MARK: - Data Source
    private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<QRCodeSection> = {
        let ds = RxTableViewSectionedAnimatedDataSource<QRCodeSection>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .automatic,
                                                            reloadAnimation: .automatic,
                                                            deleteAnimation: .automatic),
            configureCell: { _, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: "MyQRCodeTableViewCell",
                        for: indexPath
                ) as? MyQRCodeTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(
                    title: item.title,
                    source: item.source,
                    date: item.date,
                    image: item.image
                )
                return cell
            }
        )
        ds.canEditRowAtIndexPath = { _, _ in true }
        return ds
    }()

    // MARK: - Initialization
    init(viewModel: MyQRCodeListViewModel = MyQRCodeListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewDidLoadRelay.accept(())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView.frame = view.bounds
    }

    // MARK: - Setup
    private func setupView() {
        profileView.frame = view.bounds
        view.addSubview(profileView)
        
        profileView.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = MyQRCodeListViewModel.Input(
            deleteAction: deleteActionRelay.asObservable(),
            editAction: editActionRelay.asObservable(),
            viewDidLoad: viewDidLoadRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // データバインディング
        output.sections
            .bind(to: profileView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // エラーメッセージの表示
        output.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        // 編集アラートの表示
        output.showEditAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (indexPath, currentTitle) in
                self?.showEditAlert(indexPath: indexPath, currentTitle: currentTitle)
            })
            .disposed(by: disposeBag)
    }
    // MARK: - Private Methods
    private func configureCell(tableView: UITableView, indexPath: IndexPath, item: QRCodeItem) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "MyQRCodeTableViewCell",
                for: indexPath
        ) as? MyQRCodeTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(
            title: item.title,
            source: item.source,
            date: item.date,
            image: item.image
        )
        
        return cell
    }
    
    private func showEditAlert(indexPath: IndexPath, currentTitle: String) {
        let alert = UIAlertController(title: "タイトル編集", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = currentTitle
            textField.placeholder = "新しいタイトルを入力"
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        let updateAction = UIAlertAction(title: "更新", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            self?.editActionRelay.accept((indexPath, newTitle))
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

// MARK: UITableViewDelegate
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
            self?.viewModel.prepareEditAlert(for: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        return editAction
    }
    
    private func createDeleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { [weak self] (_, _, completionHandler) in
            self?.deleteActionRelay.accept(indexPath)
            completionHandler(true)
        }
        return deleteAction
    }
}
