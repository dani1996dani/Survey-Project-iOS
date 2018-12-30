//
//  ProfileDataSource.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 26/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation
class ProfileDataSource{
    private init(){
        
    }
    
    static let shared = ProfileDataSource()
    
    /**
     Queries the server for the users recent questions, and returns [Question] in the completion handler.
     */
    func getMyQuestions(completion: @escaping ([Question])->()){
        let token = Auth.userToken
        let action = "get_user_questions"
        let urlString = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.QUESTION_SERVLET)?action=\(action)&token=\(token)"
        
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                return
            }
            guard let data = data else {return;}
            var questions = [Question]()
            
            let jsonArray = try! JSONSerialization.jsonObject(with: data, options: []) as! JSONArray
            
            for json in jsonArray{
                let question = QuestionsDataSource.shared.parseQuestion(from : json)
                questions.append(question)
            }
            
            DispatchQueue.main.async {
                completion(questions)
            }
            
        }
        
        task.resume()
    }
    
    
    /**
     Queries the server for the users metadata, and returns ProfileMetada in the completion handler.
     */
    func getProfileMetadata(completion: @escaping (ProfileMetadata)->()){
        let token = Auth.userToken
        let action = "profile_metadata"
        let urlString = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.PROFILE_SERVLET)?action=\(action)&token=\(token)"
        
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                return
            }
            guard let data = data else{return;}
            
            let profileMetadata = self.parseProfileMetadata(from: data)
            
            DispatchQueue.main.async {
                completion(profileMetadata)
            }
            
        }
        
        task.resume()
    }
    
    ///Parses a json that contains user metadata
    ///- parameters:
    ///    - jsondata: the json to parse
    ///- returns: ProfileMetadata constructed from the json
    
    func parseProfileMetadata(from jsondata : Data) -> ProfileMetadata{
        let json = try! JSONSerialization.jsonObject(with: jsondata, options: []) as! JSON
        let questionAmount = json["questionAmount"] as! Int
        let voteAmount = json["voteAmount"] as! Int
        let user = json["user"] as! JSON
        let userId = user["userId"] as! Int
        let username = user["userName"] as! String
        
        let userObject = User(userId: userId, username: username)
        
        return ProfileMetadata(voteAmount: voteAmount, questionAmount: questionAmount, user: userObject)
        
    }
    
    
    
    
}
