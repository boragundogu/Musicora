//
//  Localizer.swift
//  Musicora
//
//  Created by Bora Gündoğu on 8.07.2025.
//

import Foundation

class Localizer {
    
    class func swizzleMainBundle() {
        let originalMethod = class_getInstanceMethod(Bundle.self, #selector(Bundle.localizedString))
        let swizzledMethod = class_getInstanceMethod(Bundle.self, #selector(Bundle.customLocalizedString(forKey:value:table:)))
        
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}


extension Bundle {
    
    static var swizzled = false
    
    @objc func customLocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
     
        let currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        var bundle: Bundle?
        
       
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            bundle = Bundle(path: path)
        }
        
    
        if let bundle = bundle {
            return bundle.customLocalizedString(forKey: key, value: value, table: tableName)
        } else {
            return self.customLocalizedString(forKey: key, value: value, table: tableName)
        }
    }
}
