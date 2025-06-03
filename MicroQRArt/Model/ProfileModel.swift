//
//  ProfileModel.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/03.
//

import Foundation
import ReactiveSwift

// MARK: - Protocol
protocol ProfileModelProtocol {
    var qrCodeItems: Property<[QRCodeItem]> { get }
    var errorMessage: Signal<String, Never> { get }
    
    func loadQRCodeItems()
    func deleteQRCodeItem(at index: Int)
    func updateQRCodeItem(at index: Int, newTitle: String)
}

// MARK: - Model
final class ProfileModel: ProfileModelProtocol {
    
    // MARK: - Properties
    private let itemsProperty = MutableProperty<[QRCodeItem]>([])
    private let errorPipe = Signal<String, Never>.pipe()
    private let dataRepository: QRCodeRepositoryProtocol
    
    // MARK: - Outputs
    var qrCodeItems: Property<[QRCodeItem]> {
        return Property(itemsProperty)
    }
    
    var errorMessage: Signal<String, Never> {
        return errorPipe.output
    }
    
    // MARK: - Initialization
    init(dataRepository: QRCodeRepositoryProtocol = QRCodeRepository()) {
        self.dataRepository = dataRepository
    }
    
    // MARK: - Public Methods
    func loadQRCodeItems() {
        do {
            let items = try dataRepository.fetchQRCodeItems()
            itemsProperty.value = items
        } catch {
            errorPipe.input.send(value: "データの読み込みに失敗しました: \(error.localizedDescription)")
        }
    }
    
    func deleteQRCodeItem(at index: Int) {
        var currentItems = itemsProperty.value
        guard index < currentItems.count else {
            errorPipe.input.send(value: "削除対象のアイテムが見つかりません")
            return
        }
        
        let itemToDelete = currentItems[index]
        
        do {
            try dataRepository.deleteQRCodeItem(id: itemToDelete.id)
            currentItems.remove(at: index)
            itemsProperty.value = currentItems
        } catch {
            errorPipe.input.send(value: "削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func updateQRCodeItem(at index: Int, newTitle: String) {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            errorPipe.input.send(value: "タイトルが空です")
            return
        }
        
        var currentItems = itemsProperty.value
        guard index < currentItems.count else {
            errorPipe.input.send(value: "編集対象のアイテムが見つかりません")
            return
        }
        
        let oldItem = currentItems[index]
        let newItem = QRCodeItem(
            id: oldItem.id,
            image: oldItem.image,
            title: trimmedTitle,
            source: oldItem.source,
            date: oldItem.date
        )
        
        do {
            try dataRepository.updateQRCodeItem(newItem)
            currentItems[index] = newItem
            itemsProperty.value = currentItems
        } catch {
            errorPipe.input.send(value: "更新に失敗しました: \(error.localizedDescription)")
        }
    }
}

// MARK: - Protocol
protocol QRCodeRepositoryProtocol {
    func fetchQRCodeItems() throws -> [QRCodeItem]
    func deleteQRCodeItem(id: String) throws
    func updateQRCodeItem(_ item: QRCodeItem) throws
}

// MARK: - Repository
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
