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

    var buttonStates: [NavigationButtonState] {
        return availableTabs.map { type in
            let isSelected = (type.index == currentIndex)
            return NavigationButtonState(
                type: type,
                iconName: type.iconName,
                isSelected: isSelected
            )
        }
    }
    
    var currentTabType: RootViewControllerType? {
        return availableTabs.first { $0.index == currentIndex }
    }
}