//
//  RootViewControllerType.swift
//  MicroQRArt
//
//  Created by yoshida.hikaru on 2025/05/28.
//

enum RootViewControllerType {
    case decoration
    case home
    case profile

    var index: Int? {
        get {
            switch self {
            case .decoration: return 0
            case .home: return 1
            case .profile: return 2
            }
        }
    }
} 
