//
//  NetworkManager.swift
//  Instaco
//
//  Created by Henry Lin on 7/11/18.
//  Copyright © 2018 Heng Lin. All rights reserved.
//

import Alamofire

class NetworkManager: SessionManager{
    
    // MARK: - Singleton instance
    static let shared: Alamofire.SessionManager = {
    
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        return sessionManager
    }()
}
