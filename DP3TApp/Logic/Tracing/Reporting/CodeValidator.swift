/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

class CodeValidator {
    private let session = URLSession.certificatePinned

    enum ValidationResult {
        case success(token: String, date: Date)
        case failure(error: Error)
        case invalidTokenError
    }

    func sendCodeRequest(code: String, isFakeRequest fake: Bool, completion: @escaping (ValidationResult) -> Void) {
//        let auth = AuthorizationRequestBody(authorizationCode: code, fake: fake ? 1 : 0)

        let dataTask = session.dataTask(with: Endpoint.onset(code: code, fake: fake).request(), completionHandler: { data, response, error in

            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 404 {
                        completion(.invalidTokenError)
                        return
                    } else if response.statusCode >= 400 {
                        completion(.failure(error: NetworkError.statusError(code: response.statusCode)))
                        return
                    }
                }

                if let error = error {
                    completion(.failure(error: error))
                    return
                } else if response == nil {
                    completion(.failure(error: NetworkError.networkError))
                    return
                }

                guard let d = data, let result = try? JSONDecoder().decode(AuthorizationResponseBody.self, from: d) else {
                    completion(.failure(error: NetworkError.parseError))
                    return
                }

                guard let jwtBody = result.accessToken.body else {
                    completion(.failure(error: NetworkError.parseError))
                    return
                }

                guard let dateString = jwtBody.keydate ?? jwtBody.onset else {
                    completion(.failure(error: NetworkError.parseError))
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                guard let date = formatter.date(from: dateString) else {
                    completion(.failure(error: NetworkError.parseError))
                    return
                }

                let token = result.accessToken

                completion(.success(token: token, date: date))
            }
        })

        dataTask.resume()
    }
}
