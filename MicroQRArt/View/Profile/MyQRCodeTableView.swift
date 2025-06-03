//
//  MyQRCodeTableView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class MyQRCodeTableView: UITableView {

    // MARK: - Properties
    private let cellHeight: CGFloat = 80
    private let disposables = CompositeDisposable()

    // MARK: - Configuration
    private struct Configuration {
        static let backgroundColor = UIColor.background
        static let cellIdentifier = "MyQRCodeTableViewCell"
        static let defaultRowHeight: CGFloat = 80
        static let separatorStyle: UITableViewCell.SeparatorStyle = .none
    }

    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    deinit {
        disposables.dispose()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        backgroundColor = Configuration.backgroundColor
        rowHeight = Configuration.defaultRowHeight
        separatorStyle = Configuration.separatorStyle
        estimatedRowHeight = Configuration.defaultRowHeight
        
        registerCells()
        setupAccessibility()
    }

    private func registerCells() {
        register(MyQRCodeTableViewCell.self, forCellReuseIdentifier: Configuration.cellIdentifier)
    }
    
    private func setupAccessibility() {
        accessibilityIdentifier = "qr_code_table_view"
        accessibilityLabel = "QRコード一覧"
    }

    // MARK: - Public Methods
    func bind<P: PropertyProtocol>(
        source: P,
        dataSource: QRCodeTableViewDataSource
    ) where P.Value == [QRCodeSection] {
        self.dataSource = dataSource
        dataSource.setTableView(self)
        
        // データソースにバインド
        disposables += source.producer
            .take(during: self.reactive.lifetime)
            .startWithValues { [weak dataSource] sections in
                dataSource?.sections.value = sections
            }
    }

    func configure(with configuration: TableViewConfiguration) {
        rowHeight = configuration.rowHeight
        backgroundColor = configuration.backgroundColor
        separatorStyle = configuration.separatorStyle
    }
}

// MARK: - Configuration Structure
struct TableViewConfiguration {
    let rowHeight: CGFloat
    let backgroundColor: UIColor
    let separatorStyle: UITableViewCell.SeparatorStyle
    
    static let `default` = TableViewConfiguration(
        rowHeight: 80,
        backgroundColor: UIColor.background,
        separatorStyle: UITableViewCell.SeparatorStyle.none
    )
}

// MARK: - Animation Configuration
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

// MARK: - Custom DataSource for ReactiveCocoa with Animation Support
class QRCodeTableViewDataSource: NSObject, UITableViewDataSource {
    let sections = MutableProperty<[QRCodeSection]>([])
    private let disposables = CompositeDisposable()
    private weak var tableView: UITableView?
    private var previousSections: [QRCodeSection] = []
    private let animationConfig: AnimationConfiguration
    
    init(animationConfig: AnimationConfiguration = .default) {
        self.animationConfig = animationConfig
        super.init()
        setupBindings()
    }
    
    deinit {
        disposables.dispose()
    }
    
    private func setupBindings() {
        // sectionsの変更を監視してTableViewをアニメーション付きで更新
        disposables += sections.producer
            .skip(first: 1) // 初期値をスキップ
            .observe(on: UIScheduler())
            .startWithValues { [weak self] newSections in
                self?.updateTableViewWithAnimation(newSections: newSections)
            }
    }
    
    func setTableView(_ tableView: UITableView) {
        self.tableView = tableView
    }
    
    private func updateTableViewWithAnimation(newSections: [QRCodeSection]) {
        guard let tableView = self.tableView else { return }
        
        let oldSections = previousSections
        let changes = calculateChanges(from: oldSections, to: newSections)
        
        if changes.isEmpty {
            // 変更がない場合は通常のリロード
            tableView.reloadData()
        } else {
            // アニメーション付きで更新
            tableView.performBatchUpdates({
                // 削除されたアイテム
                for indexPath in changes.deletions.reversed() {
                    tableView.deleteRows(at: [indexPath], with: animationConfig.deleteAnimation)
                }
                
                // 挿入されたアイテム
                for indexPath in changes.insertions {
                    tableView.insertRows(at: [indexPath], with: animationConfig.insertAnimation)
                }
                
                // 更新されたアイテム
                for indexPath in changes.updates {
                    tableView.reloadRows(at: [indexPath], with: animationConfig.reloadAnimation)
                }
            }, completion: nil)
        }
        
        previousSections = newSections
    }
    
    private func calculateChanges(from oldSections: [QRCodeSection], to newSections: [QRCodeSection]) -> TableViewChanges {
        var deletions: [IndexPath] = []
        var insertions: [IndexPath] = []
        var updates: [IndexPath] = []
        
        // 簡易的な差分計算（単一セクションを想定）
        guard !oldSections.isEmpty && !newSections.isEmpty else {
            return TableViewChanges(deletions: deletions, insertions: insertions, updates: updates)
        }
        
        let oldItems = oldSections[0].items
        let newItems = newSections[0].items
        
        // IDベースで変更を検出
        let oldItemsById = Dictionary(uniqueKeysWithValues: oldItems.enumerated().map { ($1.id, $0) })
        let newItemsById = Dictionary(uniqueKeysWithValues: newItems.enumerated().map { ($1.id, $0) })
        
        // 削除されたアイテムを検出
        for (id, oldIndex) in oldItemsById {
            if !newItemsById.keys.contains(id) {
                deletions.append(IndexPath(row: oldIndex, section: 0))
            }
        }
        
        // 挿入・更新されたアイテムを検出
        for (id, newIndex) in newItemsById {
            if let oldIndex = oldItemsById[id] {
                // 既存アイテムの更新チェック
                if oldItems[oldIndex] != newItems[newIndex] {
                    updates.append(IndexPath(row: newIndex, section: 0))
                }
            } else {
                // 新規アイテム
                insertions.append(IndexPath(row: newIndex, section: 0))
            }
        }
        
        return TableViewChanges(deletions: deletions, insertions: insertions, updates: updates)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sections.value.count else { return 0 }
        return sections.value[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "MyQRCodeTableViewCell",
                for: indexPath
        ) as? MyQRCodeTableViewCell else {
            return UITableViewCell()
        }
        
        guard indexPath.section < sections.value.count,
              indexPath.row < sections.value[indexPath.section].items.count else {
            return cell
        }
        
        let item = sections.value[indexPath.section].items[indexPath.row]
        cell.configure(
            title: item.title,
            source: item.source,
            date: item.date,
            image: item.image
        )
        return cell
    }
}

// MARK: - Helper Structures
private struct TableViewChanges {
    let deletions: [IndexPath]
    let insertions: [IndexPath]
    let updates: [IndexPath]
    
    var isEmpty: Bool {
        return deletions.isEmpty && insertions.isEmpty && updates.isEmpty
    }
}