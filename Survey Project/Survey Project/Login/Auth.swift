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
        print(UserDefaults.standard.string(forKey: "userToken"))
        return UserDefaults.standard.string(forKey: "userToken") ?? ""
    }
    
    static let illegalCredentials = "Username needs to be between 3-16 characters long, and password needs to be 8-30 characters long"
    static let usernameTaken = "Username Taken"
    
   
    
    func login(username: String, password : String, completion: @escaping (String) -> ()){
            authAttempt(username: username, password: password, using: loginAction, completion: completion)

    }
    
    func register(username : String, password: String, completion: @escaping (String) -> ()){
        if validateCredentials(username: username, password: password){
            authAttempt(username: username, password: password, using: registerAction, completion: completion)
        }
        else{
            completion(Auth.illegalCredentials)
        }
    }
    
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
    
    func authAttempt(username : String, password: String,using action: String,completion: @escaping (String) -> ()){
        var response = ""
//        let hashedUsername = username.sha256()
        let hashedPassword = password.sha256()
        let urlPath = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.AUTH_SERVLET)?action=\(action)&\(username_param)=\(username)&\(hashed_password_param)=\(hashedPassword)"
        print(urlPath)
        let url = URL(string: urlPath)!
        let task = URLSession.shared.dataTask(with: url) { (data, res, error) in
            guard let data = data else{print("No Data");return;}
            response = String(decoding: data, as: UTF8.self)
            
            DispatchQueue.main.async {
                completion(response)
            }
            
        }
        task.resume()
    }
    
    static func logout(){
        let userDefaults = UserDefaults.standard
        userDefaults.set("", forKey: "userToken")
        print(userDefaults.string(forKey: "userToken"))
    }
    
    
}
