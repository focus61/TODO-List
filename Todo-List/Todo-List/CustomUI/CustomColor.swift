//
//  CustomColor.swift
//  Todo-List
//
//  Created by Aleksandr on 30.07.2022.
//

import UIKit

final class CustomColor {
    var displayMode: DisplayMode
    init(displayMode: DisplayMode = .lightMode) {
        self.displayMode = displayMode
    }
    func switchedMode(lightColorRGB: UIColor, darkColorRGB: UIColor) -> UIColor {
        switch displayMode {
        case .darkMode:
            return darkColorRGB
        case .lightMode:
            return lightColorRGB
        }
    }
    var supportSeparator: UIColor {
        let lightColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        let darkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var supportOverlay: UIColor {
        let lightColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)
        let darkColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.32)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var supportNavBarBlur: UIColor {
        let lightColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.8)
        let darkColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var labelPrimary: UIColor {
        let lightColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        let darkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var labelSecondary: UIColor {
        let lightColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        let darkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var labelTertiary: UIColor {
        let lightColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        let darkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var labelDisable: UIColor {
        let lightColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        let darkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var red: UIColor {
        let lightColor = UIColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
        let darkColor = UIColor(red: 1, green: 0.27, blue: 0.23, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var green: UIColor {
        let lightColor = UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1)
        let darkColor = UIColor(red: 0.2, green: 0.84, blue: 0.29, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var blue: UIColor {
        let lightColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
        let darkColor = UIColor(red: 0.04, green: 0.52, blue: 1, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var gray: UIColor {
        let lightColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1)
        let darkColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var grayLight: UIColor {
        let lightColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1)
        let darkColor = UIColor(red: 0.28, green: 0.28, blue: 0.29, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var white: UIColor {
        let lightColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let darkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var backIosPrimary: UIColor {
        let lightColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        let darkColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var backPrimary: UIColor {
        let lightColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        let darkColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var backSecondary: UIColor {
        let lightColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let darkColor = UIColor(red: 0.145, green: 0.145, blue: 0.155, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
    var backElevated: UIColor {
        let lightColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let darkColor = UIColor(red: 0.23, green: 0.23, blue: 0.25, alpha: 1)
        return switchedMode(lightColorRGB: lightColor, darkColorRGB: darkColor)
    }
}
