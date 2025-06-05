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
    var isLoading: Property<Bool> { get }
    
    func loadQRCodeItems()
    func deleteQRCodeItem(at index: Int)
    func updateQRCodeItem(at index: Int, newTitle: String)
}

// MARK: - Model
final class ProfileModel: ProfileModelProtocol {
    
    // MARK: - Properties
    private let itemsProperty = MutableProperty<[QRCodeItem]>([])
    private let errorPipe = Signal<String, Never>.pipe()
    private let loadingProperty = MutableProperty<Bool>(false)
    private let dataRepository: QRCodeRepositoryProtocol
    
    // MARK: - Outputs
    var qrCodeItems: Property<[QRCodeItem]> {
        return Property(itemsProperty)
    }
    
    var errorMessage: Signal<String, Never> {
        return errorPipe.output
    }
    
    var isLoading: Property<Bool> {
        return Property(loadingProperty)
    }
    
    // MARK: - Initialization
    init(dataRepository: QRCodeRepositoryProtocol = QRCodeRepository()) {
        self.dataRepository = dataRepository
    }
    
    // MARK: - Public Methods
    func loadQRCodeItems() {
        loadingProperty.value = true
        
        dataRepository.fetchQRCodeItems { [weak self] result in
            self?.loadingProperty.value = false
            
            switch result {
            case .success(let items):
                self?.itemsProperty.value = items
            case .failure(let error):
                self?.errorPipe.input.send(value: "データの読み込みに失敗しました: \(error.localizedDescription)")
            }
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
    func fetchQRCodeItems(completion: @escaping (Result<[QRCodeItem], Error>) -> Void)
    func deleteQRCodeItem(id: String) throws
    func updateQRCodeItem(_ item: QRCodeItem) throws
}

// MARK: - Repository
final class QRCodeRepository: QRCodeRepositoryProtocol {
    
    private let apiEndpoint = "https://s-5.app/micro_qr_art/list"
    
    func fetchQRCodeItems(completion: @escaping (Result<[QRCodeItem], Error>) -> Void) {
        guard let url = URL(string: apiEndpoint) else {
            // インジケータのデバック用に3秒のディレイを追加
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                completion(.failure(APIError.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                do {
                    let apiResponse = try JSONDecoder().decode(QRCodeAPIResponse.self, from: data)
                    
                    if apiResponse.result == "ok" {
                        completion(.success(apiResponse.data))
                    } else {
                        completion(.failure(APIError.serverError))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func deleteQRCodeItem(id: String) throws {
        print("Deleting item with id: \(id)")
    }
    
    func updateQRCodeItem(_ item: QRCodeItem) throws {
        print("Updating item: \(item)")
    }
}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case noData
    case serverError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .noData:
            return "データが取得できませんでした"
        case .serverError:
            return "サーバーエラーが発生しました"
        }
    }
}
