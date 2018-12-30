//
//  VoteMessage.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 17/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class VoteMessage : Encodable {
    var action : String
    var questionId : Int
    var answerId : Int
    var userToken : String
    
    init(action : String,questionId : Int, answerId: Int,userToken : String){
        self.action = action
        self.questionId = questionId
        self.answerId = answerId
        self.userToken = userToken
    }
    
    func toJSON() -> String{
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(self)
        let json = String(data: jsonData, encoding: .utf8)!
        print(json)
        return json
    }
}
