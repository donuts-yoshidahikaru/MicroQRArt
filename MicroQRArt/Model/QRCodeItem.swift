//
//  QRCodeItem.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/02.
//

import Foundation
import RxDataSources

struct QRCodeItem: Identifiable, Equatable, IdentifiableType {
    let id: String
    let image: Data?
    let title: String
    let source: String
    let date: String
    var identity: String { id }
} 
