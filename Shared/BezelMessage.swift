//
//  BezelMessage.swift
//  Xgist
//
//  Created by Guilherme Rambo on 15/03/17.
//  Copyright © 2017 Fernando Bunn. All rights reserved.
//

import Foundation

struct BezelMessage {
    let imageName: String
    let title: String
}

extension BezelMessage {
    static let clipboard = BezelMessage(imageName: "copy", title: "Link Copied")
    static let installed = BezelMessage(imageName: "message", title: "Xgist is Installed")
    
    private var dict: [String: String] {
        return [
            "imageName": imageName,
            "title": title
        ]
    }
    
    var urlEncoded: URL? {
        var components = URLComponents(string: "XgistMessage://message")
        
        let imageNameItem = URLQueryItem(name: "imageName", value: imageName)
        let titleItem = URLQueryItem(name: "title", value: title)
        
        components?.queryItems = [imageNameItem, titleItem]
        
        return components?.url
    }
    
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return nil }
        
        guard let imageName = queryItems.first(where: { $0.name == "imageName" })?.value,
            let title = queryItems.first(where: { $0.name == "title" })?.value else { return nil }
        
        self.imageName = imageName
        self.title = title
    }
}

