//
//  RootViewModel.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/29.
//

import UIKit
import Combine

protocol RootViewModelProtocol {
    var pageControllerState: CurrentValueSubject<PageControllerState, Never> { get }
    var shouldTransition: PassthroughSubject<(from: Int, to: Int, direction: UIPageViewController.NavigationDirection), Never> { get }
    
    var pageControllerButtonStates: AnyPublisher<[PageControllerButtonState], Never> { get }
    
    func didTapPageController(_ type: RootViewControllerType)
}

final class RootViewModel: RootViewModelProtocol {
    let pageControllerState = CurrentValueSubject<PageControllerState, Never>(PageControllerState())
    let shouldTransition = PassthroughSubject<(from: Int, to: Int, direction: UIPageViewController.NavigationDirection), Never>()
    
    var pageControllerButtonStates: AnyPublisher<[PageControllerButtonState], Never> {
        return pageControllerState
            .map { $0.buttonStates }
            .eraseToAnyPublisher()
    }
    
    func didTapPageController(_ type: RootViewControllerType) {
        guard let newIndex = type.index else { return }
        guard let currentIndex = pageControllerState.value.currentIndex, newIndex != currentIndex else { return }
        
        let direction: UIPageViewController.NavigationDirection = newIndex > currentIndex ? .forward : .reverse
        
        // 状態更新
        pageControllerState.send(pageControllerState.value.updated(currentIndex: newIndex))
        
        // 画面遷移トリガー
        shouldTransition.send((from: currentIndex, to: newIndex, direction: direction))
    }
}
