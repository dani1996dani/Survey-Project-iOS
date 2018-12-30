//
//  NewQuestionSubmitDelegate.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 23/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation
class NewQuestionSubmitDelegate{
    
    
    var httpErrorDelegate : HttpErrorDelegate?
    
    private init(){
        
    }
    
    static let shared = NewQuestionSubmitDelegate()
    
    func submitNewQuestion(question : NewQuestion,completion: @escaping (String) -> ()){
        let urlString = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.QUESTION_SERVLET)"
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try! JSONEncoder().encode(question)
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
            
            if error != nil{
                DispatchQueue.main.async {
                    self.httpErrorDelegate?.onError(erroredIn: self)
                }
                
                return
            }
            
            guard let data = data else{return;}
            
            DispatchQueue.main.async {
                completion(String(data: data, encoding: .utf8)!)
            }
            
        }
        
        task.resume()
    }
    
    
}
