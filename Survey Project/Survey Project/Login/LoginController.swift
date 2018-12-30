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
    
    func onAuthAttempt(response : String){
        self.view.removeBluerLoader()
        if (response.count == 36){
            print("Hoorah")
            UserDefaults.standard.set(response, forKey: "userToken")
            onLoginDelegate?.onSuccess()
            self.dismiss(animated: true)
        }
        else{
            print(response)
            errorLabel.isHidden = false
            errorLabel.shake()
            errorLabel.text = response
//            if response == Auth.invalidCredentials{
//                errorLabel.text = response
//                return
//            }
//            if response == Auth.usernameTaken{
//                errorLabel.text = response
//            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        self.view.showBlurLoader()
        authHandler.login(username: username, password: password,completion: onAuthAttempt)
        
    }
    
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



