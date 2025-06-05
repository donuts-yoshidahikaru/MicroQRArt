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
    private let disposables = CompositeDisposable()

    // Pipes for Inputs
    private let viewDidLoadPipe = Signal<Void, Never>.pipe()
    private let deleteActionPipe = Signal<IndexPath, Never>.pipe()
    private let editActionPipe = Signal<(IndexPath, String), Never>.pipe()
    private let editAlertRequestPipe = Signal<IndexPath, Never>.pipe()

    // For Outputs
    private let _sections: Property<[QRCodeSection]>
    private let showEditAlertPipe = Signal<(IndexPath, String), Never>.pipe()
    private let _errorMessage: Signal<String, Never>
    private let _isLoading: Property<Bool>

    // MARK: - Initialization
    init(model: ProfileModelProtocol = ProfileModel()) {
        self.model = model

        self._sections = Property(model.qrCodeItems.map { items in
            [QRCodeSection(header: "", items: items)]
        })
        self._errorMessage = model.errorMessage
        self._isLoading = model.isLoading
        
        setupBindings()
    }

    deinit {
        disposables.dispose()
    }

    // MARK: - Private Methods
    private func setupBindings() {
        disposables += viewDidLoadPipe.output
            .observeValues { [weak self] in
                self?.model.loadQRCodeItems()
            }

        disposables += deleteActionPipe.output
            .observeValues { [weak self] indexPath in
                self?.model.deleteQRCodeItem(at: indexPath.row)
            }

        disposables += editActionPipe.output
            .observeValues { [weak self] (indexPath, newTitle) in
                self?.model.updateQRCodeItem(at: indexPath.row, newTitle: newTitle)
            }

        disposables += editAlertRequestPipe.output
            .observeValues { [weak self] indexPath in
                self?.handleEditAlertRequest(for: indexPath)
            }
    }

    private func handleEditAlertRequest(for indexPath: IndexPath) {
        let qrCodeItems = model.qrCodeItems.value
        guard indexPath.row < qrCodeItems.count else { return }

        let currentTitle = qrCodeItems[indexPath.row].title
        showEditAlertPipe.input.send(value: (indexPath, currentTitle))
    }
}

// MARK: - MyQRCodeListViewModelType
extension MyQRCodeListViewModel: MyQRCodeListViewModelType {
    var inputs: MyQRCodeListViewModelInputs { self }
    var outputs: MyQRCodeListViewModelOutputs { self }
}

// MARK: - MyQRCodeListViewModelInputs
extension MyQRCodeListViewModel: MyQRCodeListViewModelInputs {
    var viewDidLoad: Signal<Void, Never>.Observer {
        return viewDidLoadPipe.input
    }

    var deleteAction: Signal<IndexPath, Never>.Observer {
        return deleteActionPipe.input
    }

    var editAction: Signal<(IndexPath, String), Never>.Observer {
        return editActionPipe.input
    }

    var editAlertRequest: Signal<IndexPath, Never>.Observer {
        return editAlertRequestPipe.input
    }
}

// MARK: - MyQRCodeListViewModelOutputs
extension MyQRCodeListViewModel: MyQRCodeListViewModelOutputs {
    var sections: Property<[QRCodeSection]> {
        return _sections
    }

    var showEditAlert: Signal<(IndexPath, String), Never> {
        return showEditAlertPipe.output
    }

    var errorMessage: Signal<String, Never> {
        return model.errorMessage
    }
    
    var isLoading: Property<Bool> {
        return model.isLoading
    }
}