//
//  GetUserData.swift
//  MyCollection
//
//  Created by Sourabh Modi on 27/11/24.
//

import Foundation

class GetUserData {
    var strAPI:String = "https://reqres.in/api/users?page=2"
    var urlAPI:URL?
    var urlRequest:URLRequest?
    
    init() {
        urlAPI = URL(string: strAPI)
        if let url = urlAPI {
            urlRequest = URLRequest(url: url)
            urlRequest?.httpMethod = "GET"
            urlRequest?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
    func getUserData(completion: @escaping(Result<GetUserDataModel,Error>) -> Void) {
        guard var reqURL = self.urlRequest else {
            completion(.failure(NSError(domain: "Inavlid URL", code: 0, userInfo: nil)))
            return
        }
        let task = URLSession.shared.dataTask(with: reqURL) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Inavlid Response", code: 0, userInfo: nil)))
                return
            }
            print("Data are coming from the API---------->",String(data: data!, encoding: .utf8) ?? "Unable to convert data")
            if !(200...299).contains(httpResponse.statusCode) {
                do {
                    if let jsonError = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                       let errorMessage = jsonError["error"] as? String {
                        let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: String(data: data!, encoding: .utf8) ?? "Unknown Error"])))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(GetUserDataModel.self, from: data!)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
