//
//  CustomFont.swift
//  Todo-List
//
//  Created by Aleksandr on 30.07.2022.
//

import UIKit

final class CustomFont: UIFont {
    static var largeTitle: UIFont {
        return .systemFont(ofSize: 38, weight: .bold)
    }
    static var title: UIFont {
        return .systemFont(ofSize: 20, weight: .semibold)
    }
    static var headline: UIFont {
        return .systemFont(ofSize: 17, weight: .semibold)
    }
    static var body: UIFont {
        return .systemFont(ofSize: 17, weight: .regular)
    }
    static var subhead: UIFont {
        return .systemFont(ofSize: 15, weight: .regular)
    }
    static var footnote: UIFont {
        return  .systemFont(ofSize: 13, weight: .semibold)
    }
    
}
