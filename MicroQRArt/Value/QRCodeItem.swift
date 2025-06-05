//
//  QRCodeItem.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/02.
//

import Foundation

struct QRCodeItem: Identifiable, Equatable, Codable {
    let id: String
    let image: String?
    let title: String
    let source: String
    let date: String
}

// MARK: - API Response Models
struct QRCodeAPIResponse: Codable {
    let result: String
    let data: [QRCodeItem]
}
