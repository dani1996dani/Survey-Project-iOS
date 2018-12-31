//
//  QuestionDetailDataSource.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 15/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class QuestionDetailDataSource{
    
    private init(){
        
    }
    
    static let shared = QuestionDetailDataSource()
    
    
    ///Requests a DetailedQuestion object from the server, based on the questionId, and returns the constructed object back to the completion handler.
    /// - parameters:
    ///     - quesitonId: the question id to load from the server
    ///     - completion: the completion handler to send the DetailedQuestion to, for further processing.
    func getDetailedQuestionById(quesitonId : Int,completion : @escaping (DetailedQuestion) -> ()){
        let userToken = UserDefaults.standard.string(forKey: "userToken") ?? ""
        let urlString = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.QUESTION_SERVLET)?action=get_specific_question&question_id=\(quesitonId)&token=\(userToken)"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else{return;}
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSON
            let user = json["askingUser"] as! JSON
            let userId = user["userId"] as! Int
            let username = user["userName"] as! String
            
            let userObject = User(userId: userId, username: username)
            
            let title = json["title"] as! String
            let timeAsked = json["timeAsked"] as! TimeInterval
            let questionId = json["questionId"] as! Int
            let voteAmount = json["votes"] as! Int
            let votedForAnswerId = json["answerVotedId"] as! Int
            
            let category = json["category"] as! JSON
            let categoryId = category["categoryId"] as! Int
            let categoryName = category["categoryName"] as! String
            
            let answers  = json["possibleAnswerList"] as! JSONArray
            var possibleAnswers : [PossibleAnswer] = []
            
            for answer in answers{
                let title = answer["answerTitle"] as! String
                let answerId = answer["answerId"] as! Int
                let qId = answer["questionId"] as! Int
                let votes = answer["votes"] as! Int
                let possibleAnswer = PossibleAnswer(questionId: qId, answerId: answerId, answerTitle: title, votes: votes)
                possibleAnswers.append(possibleAnswer)
            }
            
            let question = DetailedQuestion(title: title, timeAsked: timeAsked, categoryName: categoryName, votes: voteAmount, user: userObject, categoryId: categoryId, questionId: quesitonId, possibleAnswers: possibleAnswers, votedForAnswerId: votedForAnswerId)
            
            DispatchQueue.main.async {
                completion(question)
            }
        }
        task.resume()
    }
}
