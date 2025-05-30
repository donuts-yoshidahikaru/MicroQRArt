//
//  RootViewModel.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/29.
//

import UIKit
import Combine

protocol RootViewModelProtocol {
    var navigationState: CurrentValueSubject<NavigationState, Never> { get }
    var shouldTransition: PassthroughSubject<(from: Int, to: Int, direction: UIPageViewController.NavigationDirection), Never> { get }
    
    var navigationButtonStates: AnyPublisher<[NavigationButtonState], Never> { get }
    
    func didTapNavigation(_ type: RootViewControllerType)
}

final class RootViewModel: RootViewModelProtocol {
    let navigationState = CurrentValueSubject<NavigationState, Never>(NavigationState())
    let shouldTransition = PassthroughSubject<(from: Int, to: Int, direction: UIPageViewController.NavigationDirection), Never>()
    
    var navigationButtonStates: AnyPublisher<[NavigationButtonState], Never> {
        return navigationState
            .map { $0.buttonStates }
            .eraseToAnyPublisher()
    }
    
    func didTapNavigation(_ type: RootViewControllerType) {
        guard let newIndex = type.index else { return }
        guard let currentIndex = navigationState.value.currentIndex, newIndex != currentIndex else { return }
        
        let direction: UIPageViewController.NavigationDirection = newIndex > currentIndex ? .forward : .reverse
        
        // 状態更新
        navigationState.send(navigationState.value.updated(currentIndex: newIndex))
        
        // 画面遷移トリガー
        shouldTransition.send((from: currentIndex, to: newIndex, direction: direction))
    }
}
