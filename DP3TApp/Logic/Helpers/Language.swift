/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

/// Languages supported by the app
enum Language: String {
    case german = "de"
    case english = "en"
    case spanish = "es"
    case catalan = "ca"

    
    static func currentLocaleLanguage() -> Language {
       var currentLocale: [String]
       if let languageCode = UserDefaults.standard.value(forKey: "AppleLanguages") as? [String] {
           currentLocale = languageCode
       } else {
           currentLocale = [Locale.current.languageCode ?? "ca"]
       }
       
       let firstLocale = currentLocale.first
       if firstLocale == Language.catalan.rawValue || (firstLocale?.contains("ca") ?? false) {
           return .catalan
       } else if firstLocale == Language.spanish.rawValue || (firstLocale?.contains("es") ?? false) {
           return .spanish
       } else if firstLocale == Language.english.rawValue || (firstLocale?.contains("en") ?? false) {
           return .english
       } else {
           return .spanish
       }
    }
    
    var name: String {
        switch self {
        case .english:
            return "English"
        case .spanish:
            return "Español"
        case .catalan:
            return "Català"
        default:
            return ""
        }
    }
}
