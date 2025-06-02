//
//  MyQRCodeTableView.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/30.
//

import UIKit

class MyQRCodeTableView: UITableView {

    // MARK: - Properties
    private let cellHeight: CGFloat = 80

    // MARK: - Sample Data
    private let qrCodes = [
        (title: "自宅Wi-Fi", source: "https://wifi.example.com/qr/1234567890", date: "2025/05/30"),
        (title: "会社Wi-Fi", source: "https://wifi.example.com/qr/0987654321", date: "2025/05/29"),
        (title: "名刺QR", source: "https://meishi.example.com/qr/1111111111", date: "2025/05/28"),
        (title: "イベント入場QR", source: "https://event.example.com/qr/2222222222", date: "2025/05/27")
    ]
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        backgroundColor = UIColor.background
        separatorStyle = .none
        dataSource = self
        delegate = self
        register(MyQRCodeTableViewCell.self, forCellReuseIdentifier: "MyQRCodeTableViewCell")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyQRCodeTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qrCodes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyQRCodeTableViewCell", for: indexPath) as? MyQRCodeTableViewCell else {
            return UITableViewCell()
        }
        let qr = qrCodes[indexPath.row]
        cell.configure(title: qr.title, source: qr.source, date: qr.date)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
