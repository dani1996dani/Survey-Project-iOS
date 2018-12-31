//
//  Auth.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 08/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class Auth{
    
    let loginAction = "login"
    let registerAction = "register"
    let username_param = "username"
    let hashed_password_param = "hashed_password"
    
    static var isAuthorized : Bool{
        let savedToken = userToken
        return savedToken.count == 36
    }
    
    static var userToken : String{
        return UserDefaults.standard.string(forKey: "userToken") ?? ""
    }
    
    static let illegalCredentials = "Username needs to be between 3-16 characters long, and password needs to be 8-30 characters long"
    static let usernameTaken = "Username Taken"
    
   
    ///tries to log in the user with the username and password given, and sends the completion handler a response from the server, or an error message if the the credentials aren't valid.
    func login(username: String, password : String, completion: @escaping (String) -> ()){
            authAttempt(username: username, password: password, using: loginAction, completion: completion)

    }
    
    ///tries to create a new account for the user with the username and password given, and sends the completion handler a response from the server, or an error message if the the credentials aren't valid.
    func register(username : String, password: String, completion: @escaping (String) -> ()){
        if validateCredentials(username: username, password: password){
            authAttempt(username: username, password: password, using: registerAction, completion: completion)
        }
        else{
            completion(Auth.illegalCredentials)
        }
    }
    
    ///Validates that the username and password are meeting minimal conditions.
    func validateCredentials(username: String, password : String) -> Bool{
        let usernameLength = username.count
        if usernameLength < 3 || usernameLength > 16 {
            return false
        }
        
        let passwordLength = password.count
        if passwordLength < 8 || passwordLength > 30 {
            return false
        }
        
        return true
    }
    
    ///The actual HTTP request that handles the authentication process for the user.
    /// - parameters:
    ///     - username: the username to use in the authentication request.
    ///     - password: the password to use in the authentication request.
    ///     - action: the action (login or register) to use in the authentication request.
    ///     - completion: the completion handler to send the server response back to.
    func authAttempt(username : String, password: String,using action: String,completion: @escaping (String) -> ()){
        var response = ""
        let hashedPassword = password.sha256()
        let urlPath = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.AUTH_SERVLET)?action=\(action)&\(username_param)=\(username)&\(hashed_password_param)=\(hashedPassword)"
        let url = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) { (data, res, error) in
            guard let data = data else{return;}
            response = String(decoding: data, as: UTF8.self)
            
            DispatchQueue.main.async {
                completion(response)
            }
            
        }
        task.resume()
    }
    
    ///Logs out the current user from the app by clearing the stored token in UserDefaults.
    static func logout(){
        let userDefaults = UserDefaults.standard
        userDefaults.set("", forKey: "userToken")
    }
    
    
}
