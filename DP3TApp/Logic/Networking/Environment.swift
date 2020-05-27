/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

/// The backend environment under which the application runs.
enum Environment {
    case dev
    case abnahme
    case prod
    
    /// The current validation method, change for each client
    static var currentValidationMethod: validationMethod = .otp

    /// The current environment, as configured in build settings.
    static var current: Environment {
        #if DEBUG
            return .dev
        #elseif RELEASE_ABNAHME
            return .abnahme
        #elseif RELEASE_TEST
            return .dev
        #elseif RELEASE_PROD
            return .prod
        #elseif RELEASE_UBDIAG
            return .dev
        #else
            fatalError("Missing build setting for environment")
        #endif
    }

    var codegenService: Backend {
        switch self {
        case .dev:
            return Backend("https://dpppt.test.basetis.com", version: "v1")
        case .abnahme:
            return Backend("https://codegen-service-a.bag.admin.ch", version: "v1")
        case .prod:
            return Backend("https://dpppt.basetis.com", version: "v1")
        }
    }


    var configService: Backend {
        switch self {
        case .dev:
            return Backend("https://dpppt.test.basetis.com", version: "v1")
        case .abnahme:
            return Backend("https://www.pt-a.bfs.admin.ch", version: "v1")
        case .prod:
            return Backend("https://dpppt.basetis.com", version: "v1")
        }
    }

    var publishService: Backend {
        switch self {
        case .dev:
            return Backend("https://dpppt.test.basetis.com", version: "v1")
        case .abnahme:
            return Backend("https://www.pt1-a.bfs.admin.ch", version: "v1")
        case .prod:
            return Backend("https://dpppt.basetis.com", version: "v1")
        }
    }
}

enum validationMethod: String {
    
    case all = "ALL"
    case otp = "OTP"
    case vottun = "VOTTUN"
    
}

