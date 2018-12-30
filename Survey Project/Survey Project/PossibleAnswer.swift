//
//  PossibleAnswer.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 15/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

struct PossibleAnswer{
    let questionId : Int
    let answerId : Int
    let answerTitle : String
    var votes : Int
    
    init(questionId : Int,answerId : Int,answerTitle : String,votes: Int) {
        self.questionId = questionId
        self.answerId = answerId
        self.answerTitle = answerTitle
        self.votes = votes
    }
}
