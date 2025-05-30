//
//  PageControllerButtonState.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/29.
//

import UIKit

struct PageControllerButtonState {
    let type: RootViewControllerType
    let iconName: String
    let isSelected: Bool
    
    var systemIconName: String {
        return isSelected ? iconName + ".fill" : iconName
    }
}
