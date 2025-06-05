//
//  MyQRCodeTableViewDataSource.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/03.
//

import UIKit
import ReactiveSwift

// MARK: - Configuration
struct AnimationConfiguration {
    let insertAnimation: UITableView.RowAnimation
    let deleteAnimation: UITableView.RowAnimation
    let reloadAnimation: UITableView.RowAnimation

    static let `default` = AnimationConfiguration(
        insertAnimation: .automatic,
        deleteAnimation: .automatic,
        reloadAnimation: .automatic
    )
}

final class MyQRCodeTableViewDataSource: NSObject, UITableViewDataSource {
    
    // MARK: - Properties
    private let animationConfig: AnimationConfiguration
    private let imageLoadingService: ImageLoadingServiceProtocol
    private weak var tableView: UITableView?
    private var currentSections: [QRCodeSection] = []
    private var isInitialLoad = true
    private var imageProperties: [String: Property<UIImage?>] = [:]

    // MARK: - Initialization
    init(
        animationConfig: AnimationConfiguration = .default,
        imageLoadingService: ImageLoadingServiceProtocol = ImageLoadingService()
    ) {
        self.animationConfig = animationConfig
        self.imageLoadingService = imageLoadingService
        super.init()
    }

    // MARK: - Public Methods
    func setTableView(_ tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
    }

    func apply(_ newSections: [QRCodeSection]) {
        guard let tableView else { return }

        updateImageProperties(for: newSections)

        if isInitialLoad {
            isInitialLoad = false
            currentSections = newSections
            tableView.reloadData()
            return
        }

        guard let changes = diff(from: currentSections, to: newSections) else {
            currentSections = newSections
            tableView.reloadData()
            return
        }

        currentSections = newSections
        tableView.performBatchUpdates({
            for i in changes.deletions { tableView.deleteRows(at: [i], with: animationConfig.deleteAnimation) }
            for i in changes.insertions { tableView.insertRows(at: [i], with: animationConfig.insertAnimation) }
            for i in changes.updates   { tableView.reloadRows(at: [i], with: animationConfig.reloadAnimation) }
        })
    }

    // MARK: - Private Methods
    private func updateImageProperties(for sections: [QRCodeSection]) {
        let allItemIds = Set(sections.flatMap { $0.items.map { $0.id } })
        imageProperties = imageProperties.filter { allItemIds.contains($0.key) }
        
        for section in sections {
            for item in section.items {
                if imageProperties[item.id] == nil {
                    let imageProperty = Property(
                        initial: QRCodeImageGenerator.createPlaceholder(),
                        then: imageLoadingService.loadImage(from: item.image)
                    )
                    imageProperties[item.id] = imageProperty
                }
            }
        }
    }
    
    private struct Changes {
        var deletions: [IndexPath] = []
        var insertions: [IndexPath] = []
        var updates: [IndexPath] = []
        var isEmpty: Bool { deletions.isEmpty && insertions.isEmpty && updates.isEmpty }
    }

    /// 行の移動が１つでもあれば `nil` を返し、全リロードにフォールバック
    private func diff(from old: [QRCodeSection], to new: [QRCodeSection]) -> Changes? {
        guard
            let oldItems = old.first?.items,
            let newItems = new.first?.items
        else { return Changes() }

        var result = Changes()

        let oldMap = Dictionary(uniqueKeysWithValues: oldItems.enumerated().map { ($1.id, $0) })
        let newMap = Dictionary(uniqueKeysWithValues: newItems.enumerated().map { ($1.id, $0) })

        // 削除
        for (id, oldRow) in oldMap where newMap[id] == nil {
            result.deletions.append(IndexPath(row: oldRow, section: 0))
        }

        // 挿入・更新・移動判定
        for (id, newRow) in newMap {
            if let oldRow = oldMap[id] {
                if oldRow != newRow { return nil } // 行移動 → フォールバック
                if oldItems[oldRow] != newItems[newRow] {
                    result.updates.append(IndexPath(row: newRow, section: 0))
                }
            } else {
                result.insertions.append(IndexPath(row: newRow, section: 0))
            }
        }

        return result.isEmpty ? nil : result
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int { currentSections.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MyQRCodeTableViewCell",
            for: indexPath
        ) as? MyQRCodeTableViewCell else { return UITableViewCell() }

        let item = currentSections[indexPath.section].items[indexPath.row]
        
        let imageProperty = imageProperties[item.id] ?? Property(value: QRCodeImageGenerator.createPlaceholder())
        
        let configuration = QRCodeCellConfiguration(
            title: item.title,
            source: item.source,
            date: item.date,
            image: imageProperty
        )
        
        cell.configure(with: configuration)
        return cell
    }
}
