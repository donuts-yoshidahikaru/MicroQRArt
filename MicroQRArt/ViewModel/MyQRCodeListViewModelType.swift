//
//  MyQRCodeListViewModelType.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/06/03.
//

import Foundation
import ReactiveSwift

// MARK: - Inputs
protocol MyQRCodeListViewModelInputs {
    var viewDidLoad: Signal<Void, Never>.Observer { get }
    var deleteAction: Signal<IndexPath, Never>.Observer { get }
    var editAction: Signal<(IndexPath, String), Never>.Observer { get }
    var editAlertRequest: Signal<IndexPath, Never>.Observer { get }
}

// MARK: - Outputs
protocol MyQRCodeListViewModelOutputs {
    var sections: Property<[QRCodeSection]> { get }
    var showEditAlert: Signal<(IndexPath, String), Never> { get }
    var errorMessage: Signal<String, Never> { get }
}

// MARK: - Type
protocol MyQRCodeListViewModelType {
    var inputs: MyQRCodeListViewModelInputs { get }
    var outputs: MyQRCodeListViewModelOutputs { get }
}