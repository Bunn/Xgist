//
//  SourceEditorExtension.swift
//  XgistEx
//
//  Created by Fernando Bunn on 10/12/16.
//  Copyright © 2016 Fernando Bunn. All rights reserved.
//

import Cocoa
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey : Any]] {
        
        let anonymous = keyWith(identifier: "SourceEditorCommandAnonymous", name: "Anonymous Gist")
        let authenticated = keyWith(identifier: "SourceEditorCommandAuthenticated", name: "Authenticated Gist")

        var result = [[XCSourceEditorCommandDefinitionKey : Any]]()
        result.append(anonymous)
        
        if GitHubAPI().isAuthenticated {
            result.append(authenticated)
        }
        
        return result
    }
    
    func extensionDidFinishLaunching() {
        
    }
    
    
   fileprivate func keyWith(identifier: String, name: String) -> [XCSourceEditorCommandDefinitionKey : Any] {
        return [
            .classNameKey : "XgistEx.SourceEditorCommand",
            .identifierKey : "com.idevzilla.XgistEx.\(identifier)",
            .nameKey : name
        ]
    }
    
}
