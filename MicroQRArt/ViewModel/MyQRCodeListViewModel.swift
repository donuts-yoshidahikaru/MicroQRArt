//
//  MyQRCodeListViewModel.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/02.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

final class MyQRCodeListViewModel {
    // MARK: - Properties
    private let model: ProfileModelProtocol
    private let editAlertPipe = Signal<(IndexPath, String), Never>.pipe()
    private let disposables = CompositeDisposable()

    // MARK: - Initialization
    init(model: ProfileModelProtocol = ProfileModel()) {
        self.model = model
    }
    
    deinit {
        disposables.dispose()
    }

    // MARK: - Public Methods
    func transform(input: Input) -> Output {
        // ViewDidLoad処理
        disposables += input.viewDidLoad
            .observeValues { [weak self] in
                self?.model.loadQRCodeItems()
            }
        
        // 削除処理
        disposables += input.deleteAction
            .observeValues { [weak self] indexPath in
                self?.model.deleteQRCodeItem(at: indexPath.row)
            }
        
        // 編集処理
        disposables += input.editAction
            .observeValues { [weak self] (indexPath, newTitle) in
                self?.model.updateQRCodeItem(at: indexPath.row, newTitle: newTitle)
            }
        
        // 編集アラート表示要求
        disposables += input.editAlertRequest
            .observeValues { [weak self] indexPath in
                self?.handleEditAlertRequest(for: indexPath)
            }
        
        // QRCodeItemsをQRCodeSectionに変換
        let sections = model.qrCodeItems
            .map { [QRCodeSection(header: "", items: $0)] }
        
        return Output(
            sections: Property(sections),
            showEditAlert: editAlertPipe.output,
            errorMessage: model.errorMessage
        )
    }

    // MARK: - Private Methods
    private func handleEditAlertRequest(for indexPath: IndexPath) {
        let qrCodeItems = model.qrCodeItems.value
        guard indexPath.row < qrCodeItems.count else { return }
        
        let currentTitle = qrCodeItems[indexPath.row].title
        editAlertPipe.input.send(value: (indexPath, currentTitle))
    }
}

extension MyQRCodeListViewModel {
    // MARK: - Inputs
    struct Input {
        let deleteAction: Signal<IndexPath, Never>
        let editAction: Signal<(IndexPath, String), Never>
        let viewDidLoad: Signal<Void, Never>
        let editAlertRequest: Signal<IndexPath, Never>
    }
    // MARK: - Outputs
    struct Output {
        let sections: Property<[QRCodeSection]>
        let showEditAlert: Signal<(IndexPath, String), Never>
        let errorMessage: Signal<String, Never>
    }
}