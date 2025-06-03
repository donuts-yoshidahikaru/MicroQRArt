//
//  MyQRCodeTableView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

// MARK: - Configuration
struct TableViewConfiguration {
    let rowHeight: CGFloat
    let backgroundColor: UIColor
    let separatorStyle: UITableViewCell.SeparatorStyle

    static let `default` = TableViewConfiguration(
        rowHeight: 80,
        backgroundColor: .clear,
        separatorStyle: .none
    )
}

final class MyQRCodeTableView: UITableView {

    // MARK: - Properties
    private let disposables = CompositeDisposable()
    private weak var dataSourceHolder: MyQRCodeTableViewDataSource?
    private var pendingSections: [QRCodeSection]?
    private var currentConfig: TableViewConfiguration = .default

    // MARK: - Initialization
    deinit { disposables.dispose() }

    // MARK: - Lifecycle
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        register(MyQRCodeTableViewCell.self,
                 forCellReuseIdentifier: "MyQRCodeTableViewCell")
        showsVerticalScrollIndicator = false
        configure(with: .default)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public Methods
    func configure(with conf: TableViewConfiguration) {
        currentConfig = conf
        rowHeight = conf.rowHeight
        estimatedRowHeight = conf.rowHeight
        backgroundColor = conf.backgroundColor
        separatorStyle = conf.separatorStyle
    }

    func bind<P: PropertyProtocol>(
        source: P,
        dataSource: MyQRCodeTableViewDataSource
    ) where P.Value == [QRCodeSection] {
        dataSourceHolder = dataSource
        dataSource.setTableView(self)

        disposables += source.producer
            .take(during: reactive.lifetime)
            .startWithValues { [weak self] sections in
                guard let self else { return }
                if self.window == nil {
                    self.pendingSections = sections
                } else {
                    self.pendingSections = nil
                    self.dataSourceHolder?.apply(sections)
                }
            }
    }

    // MARK: - UIKit
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, let sections = pendingSections {
            pendingSections = nil
            dataSourceHolder?.apply(sections)
        }
    }
}
