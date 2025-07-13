//
//  UserModel.swift
//  Musicora
//
//  Created by Bora Gündoğu on 1.07.2025.
//

import Foundation

struct User {
    let name: String
    let surname: String
    let mail: String
    let password: String
    
    init(name: String, surname: String, mail: String, password: String) {
        self.name = name
        self.surname = surname
        self.mail = mail
        self.password = password
    }
    
    init?(from userDefaults: UserDefaults) {
        guard let userDict = userDefaults.object(forKey: "user") as? [String: String],
              let name = userDict["name"],
              let surname = userDict["surname"],
              let mail = userDict["mail"],
              let password = userDict["password"] else {
            return nil
        }
        
        self.name = name
        self.surname = surname
        self.mail = mail
        self.password = password
    }
    
    func save(to userDefaults: UserDefaults) {
        let userDict: [String: String] = [
            "name": name,
            "surname": surname,
            "mail": mail,
            "password": password
        ]
        userDefaults.set(userDict, forKey: "user")
    }
}
