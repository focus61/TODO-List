//
//  Constants.swift
//  Todo-List
//
//  Created by Aleksandr on 06.08.2022.
//

import UIKit

enum WindowInsetConstants: CGFloat {
    case top
    case bottom
    case trailing
    case leading
    
    var value: CGFloat {
        switch self {
            case .top: return 10
            case .bottom: return 10
            case .trailing: return 16
            case .leading: return 16
        }
    }
}
