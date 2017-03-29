//
//  AppDelegate.swift
//  Xgist
//
//  Created by Fernando Bunn on 10/12/16.
//  Copyright © 2016 Fernando Bunn. All rights reserved.
//

import Foundation
import XcodeKit
import AppKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    let gitHubAPI = GitHubAPI()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        guard let textContent = invocation.content else {
            completionHandler(nil)
            return
        }
        
        gitHubAPI.post(gist: textContent, fileExtension: invocation.codeType) { (error, result) in
            if let content = result {
                self.copyToPasteBoard(value: content)
                self.showSuccessMessage()
            }
            completionHandler(error)
        }
    }

    private func copyToPasteBoard(value: String) -> Void {
        let pasteboard = NSPasteboard.general()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(value, forType: NSPasteboardTypeString)
    }
    
    
    //MARK: - UI Agent
    
    private func showSuccessMessage() {
        guard let url = BezelMessage.clipboard.urlEncoded else { return }
        _ = NSWorkspace.shared().open(url)
    }
}

fileprivate extension XCSourceEditorCommandInvocation {
    
    enum CommandType: String {
        case selection = "SourceEditorCommandFromSelection"
        case file = "SourceEditorCommandFromFile"
    }
    
    private func getTextSelectionFrom(buffer: XCSourceTextBuffer) -> String {
        var text = ""
        buffer.selections.forEach { selection in
            guard let range = selection as? XCSourceTextRange else { return }
            
            for l in range.start.line...range.end.line {
                if l >= buffer.lines.count {
                    continue
                }
                guard let line = buffer.lines[l] as? String else { continue }
                text.append(line)
            }
        }
        return text
    }
    
    var content: String? {
        if commandIdentifier.contains(CommandType.selection.rawValue) {
            return getTextSelectionFrom(buffer: buffer)
        } else if commandIdentifier.contains(CommandType.file.rawValue) {
            return buffer.completeBuffer
        }
        return nil
    }
    
    var codeType: String {
        //Github doesn't recognize the type "objective-c" or ".playground"
        //There's probably a better way to solve this, but this will do for now
        let types = [("objective-c", "m"),
                     ("com.apple.dt.playground", "playground.swift"),
                     ("swift","swift"),
                     ("xml", "xml")]
        
        for type in types {
            if buffer.contentUTI.contains(type.0) {
                return type.1
            }
        }
        return buffer.contentUTI
    }
}

