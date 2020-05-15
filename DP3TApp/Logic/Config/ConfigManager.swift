/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit
#if ENABLE_TESTING
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

/// Config request allows to disable old versions of the app if
class ConfigManager: NSObject {
    // MARK: - Data Task

    private let session = URLSession.certificatePinned
    private var dataTask: URLSessionDataTask?

    // MARK: - Init

    override init() {}

    // MARK: - Last Loaded Config

    @UBOptionalUserDefault(key: "config")
    static var currentConfig: ConfigResponseBody? {
        didSet {
            UIStateManager.shared.refresh()
            if let sdkConfig = currentConfig?.sdkConfig {
                ConfigManager.updateSDKParameters(config: sdkConfig)
            }
            if let config = currentConfig, config.forceTraceShutdown {
                TracingManager.shared.endTracing()
            }
        }
    }

    static var allowTracing: Bool {
        if let config = self.currentConfig {
            return !config.forceTraceShutdown
        }
        return true
    }

    // MARK: - Version Numbers

    static var appVersion: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return "ios-\(shortVersion)"
    }

    static var osVersion: String {
        let systemVersion = UIDevice.current.systemVersion
        return "ios\(systemVersion)"
    }

    static var buildNumber: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        return "ios-\(shortVersion)"
    }

    // MARK: - Start config request

    private struct ConfigClaims: DP3TClaims {
        let iss: String
        let iat: Date
        let exp: Date
        let contentHash: String
        let hashAlg: String

        enum CodingKeys: String, CodingKey {
            case contentHash = "content-hash"
            case hashAlg = "hash-alg"
            case iss, iat, exp
        }
    }

    public func loadConfig(completion: @escaping (ConfigResponseBody?) -> Void) {

        Logger.log("Load Config", appState: true)
        
        let configDict: [String: Any?] = ["forceUpdate": false,
                                          "forceTraceShutdown": false,
                                          "infoBox": nil,
                                          "sdkConfig": ["numberOfWindowsForExposure": 3,
                                                        "contactAttenuationThreshold": 73]]
        
        if let configData = try? JSONSerialization.data(withJSONObject: configDict, options: []),
            let config = try? JSONDecoder().decode(ConfigResponseBody.self, from: configData) {
            
            ConfigManager.currentConfig = config
            completion(config)
        } else {
            Logger.log("Failed to load config, error:")
            completion(nil)
        }
        return

        // Request to server removed, values configured in app
        /*dataTask = session.dataTask(with: Endpoint.config(appversion: ConfigManager.appVersion, osversion: ConfigManager.osVersion, buildnr: ConfigManager.buildNumber).request(), completionHandler: { data, response, error in

            guard let httpResponse = response as? HTTPURLResponse,
                let data = data else {
                Logger.log("Failed to load config, error: \(error?.localizedDescription ?? "?")")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Validate JWT
            if #available(iOS 11.0, *) {
                let verifier = DP3TJWTVerifier(publicKey: Environment.current.configJwtPublicKey,
                                               jwtTokenHeaderKey: "Signature")
                do {
                    try verifier.verify(claimType: ConfigClaims.self, httpResponse: httpResponse, httpBody: data)
                } catch let error as DP3TNetworkingError {
                    Logger.log("Failed to verify config signature, error: \(error.errorCodeString ?? error.localizedDescription)")
                    DispatchQueue.main.async { completion(nil) }
                    return
                } catch {
                    Logger.log("Failed to verify config signature, error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
            }

            DispatchQueue.main.async {
                if let config = try? JSONDecoder().decode(ConfigResponseBody.self, from: data) {
                    ConfigManager.currentConfig = config
                    completion(config)
                } else {
                    Logger.log("Failed to load config, error: \(error?.localizedDescription ?? "?")")
                    completion(nil)
                }
            }
        })

        dataTask?.resume()*/
    }

    public func startConfigRequest(window: UIWindow?) {

        // immediate alert if old config enforced update
        if let oldConfig = ConfigManager.currentConfig {
            presentAlertIfNeeded(config: oldConfig, window: window)
        }

        loadConfig { config in
            // self must be strong
            if let config = config {
                self.presentAlertIfNeeded(config: config, window: window)
            }
        }
    }

    public static func updateSDKParameters(config: ConfigResponseBody.SDKConfig) {
        var parameters = DP3TTracing.parameters

        if let numberOfWindowsForExposure = config.numberOfWindowsForExposure {
            parameters.contactMatching.numberOfWindowsForExposure = numberOfWindowsForExposure
        }
        if let contactAttenuationThreshold = config.contactAttenuationThreshold {
            parameters.contactMatching.contactAttenuationThreshold = contactAttenuationThreshold
        }

        DP3TTracing.parameters = parameters
    }

    private func presentAlertIfNeeded(config: ConfigResponseBody, window: UIWindow?) {
        if config.forceUpdate {
            let alert = UIAlertController(title: "force_update_title".ub_localized,
                                          message: "force_update_text".ub_localized,
                                          preferredStyle: .alert)

            window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            Logger.log("NO force update alert")
        }
    }
}
