//
//  MyQRCodeListViewModel.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/02.
//

import UIKit
import RxSwift
import RxCocoa

/// QRコードリストのViewModel（仮データ保持）
final class MyQRCodeListViewModel {
    // MARK: - Properties
    let items = BehaviorRelay<[QRCodeItem]>(value: [
        QRCodeItem(id: "1", image: nil, title: "自宅Wi-Fi", source: "https://wifi.example.com/qr/1234567890", date: "2025/05/30"),
        QRCodeItem(id: "2", image: nil, title: "会社Wi-Fi", source: "https://wifi.example.com/qr/0987654321", date: "2025/05/29"),
        QRCodeItem(id: "3", image: nil, title: "名刺QR", source: "https://meishi.example.com/qr/1111111111", date: "2025/05/28"),
        QRCodeItem(id: "4", image: nil, title: "イベント入場QR", source: "https://event.example.com/qr/2222222222", date: "2025/05/27")
    ])
} 