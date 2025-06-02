//
//  MyQRCodeListViewModel.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/02.
//

import UIKit
import RxSwift
import RxCocoa

final class MyQRCodeListViewModel {

    // MARK: - Inputs
    struct Input {
        let deleteAction: Observable<IndexPath>
        let editAction: Observable<(IndexPath, String)>
        let viewDidLoad: Observable<Void>
    }
    
    // MARK: - Outputs
    struct Output {
        let sections: Observable<[QRCodeSection]>
        let showEditAlert: Observable<(IndexPath, String)>
        let errorMessage: Observable<String>
    }

    // MARK: - Properties
    private let itemsRelay = BehaviorRelay<[QRCodeItem]>(value: [])
    private let errorRelay = PublishRelay<String>()
    private let editAlertRelay = PublishRelay<(IndexPath, String)>()
    private let dataRepository: QRCodeRepositoryProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Initialization
    init(dataRepository: QRCodeRepositoryProtocol = QRCodeRepository()) {
        self.dataRepository = dataRepository
        loadInitialData()
    }

    // MARK: - Public Methods
    func transform(input: Input) -> Output {
        // 削除処理
        input.deleteAction
            .subscribe(onNext: { [weak self] indexPath in
                self?.deleteItem(at: indexPath)
            })
            .disposed(by: disposeBag)
        
        // 編集処理
        input.editAction
            .subscribe(onNext: { [weak self] (indexPath, newTitle) in
                self?.editTitle(at: indexPath, newTitle: newTitle)
            })
            .disposed(by: disposeBag)
        
        // データの再読み込み
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.loadInitialData()
            })
            .disposed(by: disposeBag)
        
        let sections = itemsRelay
            .map { [QRCodeSection(header: "", items: $0)] }
            .asObservable()
        
        return Output(
            sections: sections,
            showEditAlert: editAlertRelay.asObservable(),
            errorMessage: errorRelay.asObservable()
        )
    }

    // MARK: - Private Methods
    private func loadInitialData() {
        do {
            let items = try dataRepository.fetchQRCodeItems()
            itemsRelay.accept(items)
        } catch {
            errorRelay.accept("データの読み込みに失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        var currentItems = itemsRelay.value
        guard indexPath.row < currentItems.count else {
            errorRelay.accept("削除対象のアイテムが見つかりません")
            return
        }
        
        let itemToDelete = currentItems[indexPath.row]
        
        do {
            try dataRepository.deleteQRCodeItem(id: itemToDelete.id)
            currentItems.remove(at: indexPath.row)
            itemsRelay.accept(currentItems)
        } catch {
            errorRelay.accept("削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func editTitle(at indexPath: IndexPath, newTitle: String) {
        guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorRelay.accept("タイトルが空です")
            return
        }
        
        var currentItems = itemsRelay.value
        guard indexPath.row < currentItems.count else {
            errorRelay.accept("編集対象のアイテムが見つかりません")
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
            itemsRelay.accept(currentItems)
        } catch {
            errorRelay.accept("更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func prepareEditAlert(for indexPath: IndexPath) {
        let currentItems = itemsRelay.value
        guard indexPath.row < currentItems.count else { return }
        let currentTitle = currentItems[indexPath.row].title
        editAlertRelay.accept((indexPath, currentTitle))
    }
} 

// MARK: - Repository Protocol
protocol QRCodeRepositoryProtocol {
    func fetchQRCodeItems() throws -> [QRCodeItem]
    func deleteQRCodeItem(id: String) throws
    func updateQRCodeItem(_ item: QRCodeItem) throws
}

// MARK: - Repository Implementation
final class QRCodeRepository: QRCodeRepositoryProtocol {
    func fetchQRCodeItems() throws -> [QRCodeItem] {
        return [
            QRCodeItem(id: "1", image: nil, title: "自宅Wi-Fi", source: "https://wifi.example.com/qr/1234567890", date: "2025/05/30"),
            QRCodeItem(id: "2", image: nil, title: "会社Wi-Fi", source: "https://wifi.example.com/qr/0987654321", date: "2025/05/29"),
            QRCodeItem(id: "3", image: nil, title: "名刺QR", source: "https://meishi.example.com/qr/1111111111", date: "2025/05/28"),
            QRCodeItem(id: "4", image: nil, title: "イベント入場QR", source: "https://event.example.com/qr/2222222222", date: "2025/05/27")
        ]
    }
    
    func deleteQRCodeItem(id: String) throws {
        print("Deleting item with id: \(id)")
    }
    
    func updateQRCodeItem(_ item: QRCodeItem) throws {
        print("Updating item: \(item)")
    }
}
