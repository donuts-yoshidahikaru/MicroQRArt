//
//  MyQRCodeTableView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MyQRCodeTableView: UITableView {

    // MARK: - Properties
    private let cellHeight: CGFloat = 80
    private let disposeBag = DisposeBag()

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
    func bind<Source: ObservableType>(
        source: Source,
        dataSource: RxTableViewSectionedAnimatedDataSource<QRCodeSection>
    ) where Source.Element == [QRCodeSection] {
        source
            .bind(to: self.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
