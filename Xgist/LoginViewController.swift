//
//  LoginViewController.swift
//  Xgist
//
//  Created by Fernando Bunn on 02/05/17.
//  Copyright © 2017 Fernando Bunn. All rights reserved.
//

import Cocoa

enum SegueIdentifier: String {
    case twoFactorAuthenticate = "showTwoFactorController"
}

enum DefaultKeys: String {
    case username = "usernameKey"
}

class LoginViewController: NSViewController {
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var headerText: NSTextField!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
    private let githubAPI = GitHubAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        usernameTextField.isEnabled = !githubAPI.isAuthenticated
        passwordTextField.isEnabled = !githubAPI.isAuthenticated;
        showSpinner(show: false)
        passwordTextField.stringValue = ""
        headerText.textColor = NSColor.black
        
        if githubAPI.isAuthenticated {
            actionButton.title = "Logout"
            headerText.stringValue = "You are logged in"
            if let name = UserDefaults.standard.string(forKey: DefaultKeys.username.rawValue) {
                usernameTextField.stringValue = name
            }
        } else {
            actionButton.title = "Login"
            headerText.stringValue = "To create authenticated Gists, fill out the following information:"
            usernameTextField.stringValue = ""
            passwordTextField.stringValue = ""
        }
    }
    
    private func showSpinner(show: Bool) {
        spinner.isHidden = !show
        actionButton.isHidden = show
        if show {
            spinner.startAnimation(nil)
        } else {
            spinner.stopAnimation(nil)
        }
    }
    
    private func displayError(message: String) {
        showSpinner(show: false)
        headerText.stringValue = message
        headerText.textColor = NSColor.red
    }
    
    fileprivate func authenticate(twoFactorCode: String? = nil) {
        showSpinner(show: true)
        githubAPI.authenticate(username: usernameTextField.stringValue, password: passwordTextField.stringValue, twoFactorCode: twoFactorCode) { (error: Error?) in
            print("Error \(String(describing: error))")
            DispatchQueue.main.async {
                if error != nil {
                    if let apiError = error as? GitHubAPI.GitHubAPIError {
                        switch apiError {
                        case .twoFactorRequired:
                            self.openTwoFactorController()
                            return
                        default: break
                        }
                    }
                    self.displayError(message: "Bad username or password")
                } else {
                    UserDefaults.standard.set(self.usernameTextField.stringValue, forKey: DefaultKeys.username.rawValue)
                    self.setupUI()
                }
            }
        }
    }
    
    @IBAction func actionButtonClicked(_ sender: NSButton) {
        if githubAPI.isAuthenticated {
            githubAPI.logout()
            setupUI()
        } else {
            authenticate()
        }
    }
    
    private func openTwoFactorController() {
        performSegue(withIdentifier: SegueIdentifier.twoFactorAuthenticate.rawValue, sender: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        switch segueIdentifier {
        case SegueIdentifier.twoFactorAuthenticate.rawValue:
            if let controller = segue.destinationController as? TwoFactorViewController {
                controller.delegate = self
            }
            break
        default:
            print("No segue found")
            break
        }
    }
}

extension LoginViewController: TwoFactorViewControllerDelegate {
    func didEnter(code: String, controller: TwoFactorViewController) {
        dismissViewController(controller)
        authenticate(twoFactorCode: code)
    }
}
