//
//  RootViewControllerType.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

enum RootViewControllerType: Int {
    case decoration
    case home
    case profile
} 

extension RootViewControllerType {
    var iconName: String {
        switch self {
        case .decoration: return "paintbrush.pointed"
        case .home: return "house"
        case .profile: return "person"
        }
    }
}
