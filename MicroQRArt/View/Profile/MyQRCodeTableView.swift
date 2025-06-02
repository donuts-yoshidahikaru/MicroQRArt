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

    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        backgroundColor = UIColor.background
        rowHeight = cellHeight
        separatorStyle = .none
        register(MyQRCodeTableViewCell.self, forCellReuseIdentifier: "MyQRCodeTableViewCell")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
