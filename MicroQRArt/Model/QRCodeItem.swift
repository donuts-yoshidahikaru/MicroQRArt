//
//  QRCodeItem.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/02.
//

import Foundation
struct QRCodeItem: Identifiable, Equatable {
    let id: String
    let image: Data?
    let title: String
    let source: String
    let date: String
} 
