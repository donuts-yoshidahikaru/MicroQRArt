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
    private let viewModel = MyQRCodeListViewModel()
    private let disposeBag = DisposeBag()
    private let profileView = ProfileView()

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

    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.frame = view.bounds
        view.addSubview(profileView)
        // SectionModelに変換してバインド
        let sections = viewModel.items.map { [QRCodeSection(header: "", items: $0)] }
        profileView.tableView.bind(source: sections, dataSource: dataSource)
        profileView.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView.frame = view.bounds
    }
}

// MARK: UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "編集") { (_, _, completionHandler) in
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.viewModel.deleteItem(at: indexPath)
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
