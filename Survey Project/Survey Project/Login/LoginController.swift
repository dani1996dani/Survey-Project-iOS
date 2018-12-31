//
//  ViewController.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 06/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit
import CommonCrypto

class LoginController: UIViewController {
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var onLoginDelegate : OnLoginDelegate?
    
    var username : String{
        return usernameField.text ?? ""
    }
    
    var password : String{
        return passwordField.text ?? ""
    }
    
    lazy var authHandler : Auth = {
        return Auth()
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
       
        
        
    }
    
    ///inits the UI to its default state
    func initUI(){
        usernameField.delegate = self
        passwordField.delegate = self
        let blue = UIColor.init(red: 40/255, green: 121/255, blue: 252/255, alpha: 1).cgColor
        
        
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = blue
        
        usernameField.layer.borderWidth = 1
        usernameField.layer.cornerRadius = 2
        usernameField.layer.borderColor = UIColor.darkGray.cgColor
        
        passwordField.layer.borderWidth = 1
        passwordField.layer.cornerRadius = 2
        passwordField.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    ///Handles a response for a login attempt. the respose needs to be 36 characters long - a UUID length (of the user token), other resposes (error responses) are purposefully not 36 characters long. On a successful response, will continue to the app, on an error, will show error to the user and stay on the same screen.
    func onAuthAttempt(response : String){
        self.view.removeBluerLoader()
        if (response.count == 36){
            self.view.endEditing(true)
            UserDefaults.standard.set(response, forKey: "userToken")
            onLoginDelegate?.onSuccess()
            self.dismiss(animated: true)
        }
        else{
            errorLabel.isHidden = false
            errorLabel.shake()
            errorLabel.text = response
        }
    }
    
    ///tries to log in the user
    @IBAction func login(_ sender: UIButton) {
        self.view.showBlurLoader()
        authHandler.login(username: username, password: password,completion: onAuthAttempt)
        
    }
    
    ///tries to create a new account for the user
    @IBAction func register(_ sender: UIButton) {
        self.view.showBlurLoader()
        authHandler.register(username: username, password: password,completion: onAuthAttempt)
        
    }
}

extension LoginController : UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

protocol OnLoginDelegate {
    func onSuccess()
}



