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

    // MARK: - Inputs
    struct Input {
        let deleteAction: Signal<IndexPath, Never>
        let editAction: Signal<(IndexPath, String), Never>
        let viewDidLoad: Signal<Void, Never>
    }
    
    // MARK: - Outputs
    struct Output {
        let sections: Property<[QRCodeSection]>
        let showEditAlert: Signal<(IndexPath, String), Never>
        let errorMessage: Signal<String, Never>
    }

    // MARK: - Properties
    private let itemsProperty = MutableProperty<[QRCodeItem]>([])
    private let errorPipe = Signal<String, Never>.pipe()
    private let editAlertPipe = Signal<(IndexPath, String), Never>.pipe()
    private let dataRepository: QRCodeRepositoryProtocol
    private let disposables = CompositeDisposable()

    // MARK: - Initialization
    init(dataRepository: QRCodeRepositoryProtocol = QRCodeRepository()) {
        self.dataRepository = dataRepository
        loadInitialData()
    }
    
    deinit {
        disposables.dispose()
    }

    // MARK: - Public Methods
    func transform(input: Input) -> Output {
        // 削除処理
        disposables += input.deleteAction
            .observeValues { [weak self] indexPath in
                self?.deleteItem(at: indexPath)
            }
        
        // 編集処理
        disposables += input.editAction
            .observeValues { [weak self] (indexPath, newTitle) in
                self?.editTitle(at: indexPath, newTitle: newTitle)
            }
        
        // データの再読み込み
        disposables += input.viewDidLoad
            .observeValues { [weak self] in
                self?.loadInitialData()
            }
        
        let sections = itemsProperty
            .map { [QRCodeSection(header: "", items: $0)] }
        
        return Output(
            sections: Property(sections),
            showEditAlert: editAlertPipe.output,
            errorMessage: errorPipe.output
        )
    }

    // MARK: - Private Methods
    private func loadInitialData() {
        do {
            let items = try dataRepository.fetchQRCodeItems()
            itemsProperty.value = items
        } catch {
            errorPipe.input.send(value: "データの読み込みに失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        var currentItems = itemsProperty.value
        guard indexPath.row < currentItems.count else {
            errorPipe.input.send(value: "削除対象のアイテムが見つかりません")
            return
        }
        
        let itemToDelete = currentItems[indexPath.row]
        
        do {
            try dataRepository.deleteQRCodeItem(id: itemToDelete.id)
            currentItems.remove(at: indexPath.row)
            itemsProperty.value = currentItems
        } catch {
            errorPipe.input.send(value: "削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func editTitle(at indexPath: IndexPath, newTitle: String) {
        guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorPipe.input.send(value: "タイトルが空です")
            return
        }
        
        var currentItems = itemsProperty.value
        guard indexPath.row < currentItems.count else {
            errorPipe.input.send(value: "編集対象のアイテムが見つかりません")
            return
        }
        
        let oldItem = currentItems[indexPath.row]
        let newItem = QRCodeItem(
            id: oldItem.id,
            image: oldItem.image,
            title: newTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            source: oldItem.source,
            date: oldItem.date
        )
        
        do {
            try dataRepository.updateQRCodeItem(newItem)
            currentItems[indexPath.row] = newItem
            itemsProperty.value = currentItems
        } catch {
            errorPipe.input.send(value: "更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func prepareEditAlert(for indexPath: IndexPath) {
        let currentItems = itemsProperty.value
        guard indexPath.row < currentItems.count else { return }
        let currentTitle = currentItems[indexPath.row].title
        editAlertPipe.input.send(value: (indexPath, currentTitle))
    }
} 
