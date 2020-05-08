///

import Foundation
import UIKit

/// Changes the language of the bundle
class LanguageManager {
    
    static func setLanguage(language: Language) {
        let defaults = UserDefaults.standard
        defaults.set([language.rawValue], forKey: "AppleLanguages")
        
        StaticVars.bundle = LanguageManager.getBundle()

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "languageChangeNotification"), object: self)
    }
    
    ///Access to the bundle to add the new language
    static func getBundle() -> Bundle {
        let language = Locale.preferredLanguages.first
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            return Bundle.main
        }
        
        guard let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        
        return bundle
    }
    
    
}

class StaticVars {
    
    // Var bundle created so if we have to modify it to change
    static var bundle: Bundle = {
        return LanguageManager.getBundle()
    }()
}
