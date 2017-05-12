//
//  TwoFactorViewController.swift
//  Xgist
//
//  Created by Fernando Bunn on 10/05/17.
//  Copyright © 2017 Fernando Bunn. All rights reserved.
//

import Cocoa

class TwoFactorViewController: NSViewController {
    @IBOutlet weak var codeTextField: NSTextField!
    weak var delegate: TwoFactorViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func authenticateButtonClicked(_ sender: NSButton) {
        delegate?.didEnter(code: codeTextField.stringValue, controller: self)
        dismiss(nil)
    }
}

protocol TwoFactorViewControllerDelegate: class {
    func didEnter(code: String, controller: TwoFactorViewController)
}
