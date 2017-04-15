//
//  GitHubRouter.swift
//  Xgist
//
//  Created by Fernando Bunn on 27/03/17.
//  Copyright © 2017 Fernando Bunn. All rights reserved.
//

import Foundation

enum GitHubRouter {
    case auth([String : Any])
    case anonymousGist([String : Any])
    case authenticatedGist([String : Any])

    var basePath: String {
        return "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .auth:
            return "authorizations/clients/\(GitHubCredential.clientID.rawValue)/\(UUID.init())"
        case .anonymousGist:
            return "gists"
        case .authenticatedGist:
            guard let token = GitHubAPI().token else { fatalError("No Token") }
            return "gists?access_token=\(token)"
        }
    }
    
    var method: String {
        switch self {
        case .auth:
            return "PUT"
        case .anonymousGist, .authenticatedGist:
            return "POST"
        }
    }
    
    var httpBody: Data? {
        switch self {
        case .auth(let params), .anonymousGist(let params), .authenticatedGist(let params):
            let jsonData = try? JSONSerialization.data(withJSONObject: params)
            return jsonData
        }
    }
    
    var request: URLRequest? {
        guard let url = URL(string: "\(basePath)/\(path)") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = httpBody
        return request
    }
}
