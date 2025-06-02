//
//  QRCodeSection.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/02.
//

import RxDataSources

struct QRCodeSection {
    var header: String
    var items: [QRCodeItem]
}

extension QRCodeSection: SectionModelType {
    typealias Item = QRCodeItem

    init(original: QRCodeSection, items: [QRCodeItem]) {
        self = original
        self.items = items
    }
} 