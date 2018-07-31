//
//  BaseNetworkService.swift
//  Instaco
//
//  Created by Henry Lin on 7/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import Alamofire

class BaseNetworkService {
    
    var config: RequestConfiguration
    
    init(config: RequestConfiguration) {
        self.config = config
    }
    
    func execute(request: URLRequest) -> DataRequest {
        
        return NetworkManager.shared.request(request).validate()
    }
    
    func executeWithoutValidation(request: URLRequest) -> DataRequest {
        
        return NetworkManager.shared.request(request)
    }
    
    func buildRequest(path: String, method: HTTPMethod, encoding: ParameterEncoding, params: Parameters? = nil, headers: HTTPHeaders) -> URLRequest {

        let url = createUrl(config.url)
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        do {
            urlRequest = try encoding.encode(urlRequest, with: params)
        } catch _ {
            print("Failed encoding of params")
        }
//        print(String(data: urlRequest.httpBody!, encoding: .utf8)!)
        
        return urlRequest
    }
    
    func buildRequestViaSettingHttpBody(path: String, method: HTTPMethod, httpbody: String, headers: HTTPHeaders) -> URLRequest {
        
        let url = createUrl(config.url)
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = Data(httpbody.utf8)
        
        return urlRequest
    }
    
    private func createUrl(_ fromUrl: String) -> URL {
        if let _url = URL(string: fromUrl) {
            return _url
        }
        return URL(fileURLWithPath: "")
    }
    
}
