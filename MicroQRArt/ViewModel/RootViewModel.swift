//
//  RootViewModel.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/29.
//

import UIKit
import Combine

struct TransitionInfo {
    let from: RootViewControllerType
    let to: RootViewControllerType
    let direction: UIPageViewController.NavigationDirection
}

protocol RootViewModelProtocol {
    var pageControllerState: AnyPublisher<PageControllerState, Never> { get }
    var shouldTransition: AnyPublisher<TransitionInfo, Never> { get }

    var pageControllerButtonStates: AnyPublisher<[PageControllerButtonState], Never> { get }
    
    func didTapPageController(_ type: RootViewControllerType)
}

final class RootViewModel: RootViewModelProtocol {

    let model = RootModel()
}

// MARK: - Outputs

extension RootViewModel {
    var pageControllerState: AnyPublisher<PageControllerState, Never> {
        return model.$selectedTab
            .map { PageControllerState(currentIndex: $0.rawValue) }
            .eraseToAnyPublisher()
    }

    var shouldTransition: AnyPublisher<TransitionInfo, Never> {
        return model.$selectedTab
            .withPrevious()
            .compactMap { previous, new in
                guard let previous else { return nil }
                return .init(from: previous, to: new, direction: new.rawValue > previous.rawValue ? .forward : .reverse)
            }
            .eraseToAnyPublisher()
    }

    var pageControllerButtonStates: AnyPublisher<[PageControllerButtonState], Never> {
        return pageControllerState
            .map { $0.buttonStates }
            .eraseToAnyPublisher()
    }
}

// MARK: - Inputs

extension RootViewModel {
    func didTapPageController(_ type: RootViewControllerType) {
        model.selectedTab = type
    }
}

// MARK: - extension Publisher.withPrevious

private extension Publisher {
    func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        scan((nil as Output?, nil as Output?)) { previous, current in
            (previous.1, current)
        }
        .dropFirst()
        .compactMap { previous, current in
            guard let current else { return nil }
            return (previous, current)
        }
        .eraseToAnyPublisher()
    }
}
