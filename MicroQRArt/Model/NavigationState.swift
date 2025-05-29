//
//  NavigationState.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/29.
//

struct NavigationState {
    let currentIndex: Int?
    let availableTabs: [RootViewControllerType]
    
    init(currentIndex: Int = 1, availableTabs: [RootViewControllerType] = [.decoration, .home, .profile]) {
        self.currentIndex = currentIndex
        self.availableTabs = availableTabs
    }
    
    func updated(currentIndex: Int) -> NavigationState {
        return NavigationState(currentIndex: currentIndex, availableTabs: availableTabs)
    }
}