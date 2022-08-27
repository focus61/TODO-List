//
//  UserDefaultsSettings.swift
//  Todo-List
//
//  Created by Aleksandr on 27.08.2022.
//

import Foundation
protocol UserDefaultsRevisionDelegate: AnyObject {
    func setRevisionValue(value: Int32)
    func getRevisionValue() -> Int32
}
final class UserDefaultsSettings {
    private let keyRevisionForUserDefaults = "revision"
    private let userDefaultsRevision = UserDefaults.standard
}
extension UserDefaultsSettings: UserDefaultsRevisionDelegate {
    func setRevisionValue(value: Int32) {
        userDefaultsRevision.set(Int(value), forKey: keyRevisionForUserDefaults)
        print("SOME")
    }
    func getRevisionValue() -> Int32 {
        print("SOME@")
        return Int32(userDefaultsRevision.integer(forKey: keyRevisionForUserDefaults))
    }
}
