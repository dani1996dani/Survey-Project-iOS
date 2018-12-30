//
//  QuestionsDataSource.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 11/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class QuestionsDataSource{
    
    private init(){
        
    }
    
    static let shared = QuestionsDataSource()
    
    var httpErrorDelegate : HttpErrorDelegate?
    
    ///gets the latest questions from the server, returning [Question] to the completion handler.
    func getRecentQuestions(limit: Int,completion : @escaping ([Question]) -> ()){
        let urlString = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.QUESTION_SERVLET)?action=get_questions"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                DispatchQueue.main.async {
                    self.httpErrorDelegate?.onError(erroredIn: self)
                }
                
                return
            }
            guard let data = data else{return;}
            
            
            let questions = self.parseQuestionsFromJSON(data: data)
            DispatchQueue.main.async {
                completion(questions)
            }
            
        }
        
        task.resume()
    }
    
    ///gets the latest filtered questions from the server, returning [Question] to the completion handler.
    func getFilteredQuestions(limit: Int,using filter : String,completion : @escaping ([Question]) -> ()){
        var urlString = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.QUESTION_SERVLET)?action=get_questions&filter_by=\(filter)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(urlString)
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                DispatchQueue.main.async {
                    self.httpErrorDelegate?.onError(erroredIn: self)
                }
                
                return
            }
            
            guard let data = data else{return;}
            
            let questions = self.parseQuestionsFromJSON(data: data)
            DispatchQueue.main.async {
                completion(questions)
            }
        }
        
        task.resume()
    }
    
    ///parses questions from json
    ///- parameters:
    ///     - data: the json to parse
    ///- returns: [Question] parsed from data
    func parseQuestionsFromJSON(data : Data) -> [Question]{
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: []) as! JSONArray
        
        var questions : [Question] = []
        for json in jsonResult{
            let question = parseQuestion(from: json)
            questions.append(question)
        }
        
        return questions
        
    }
    
    ///parses one question from json
    ///- parameters:
    ///     - data: the json to parse
    ///- returns: Question parsed from data
    func parseQuestion(from json : JSON) -> Question{
        let user = json["askingUser"] as! JSON
        let userId = user["userId"] as! Int
        let userName = user["userName"] as! String
        
        let userObject = User(userId: userId, username: userName)
        
        let title = json["title"] as! String
        let timeAsked = json["timeAsked"] as! TimeInterval
        let questionId = json["questionId"] as! Int
        let voteAmount = json["votes"] as! Int
        
        let category = json["category"] as! JSON
        let categoryId = category["categoryId"] as! Int
        let categoryName = category["categoryName"] as! String
        
        return Question(title: title, timeAsked: timeAsked, categoryName: categoryName, votes: voteAmount, user: userObject, categoryId: categoryId, questionId: questionId)
    }
}

protocol HttpErrorDelegate {
    func onError(erroredIn : Any)
}
