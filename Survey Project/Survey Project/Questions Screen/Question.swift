//
//  Question.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 11/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class Question{
    var title : String
    var timeAsked : TimeInterval
    var categoryName : String
    var votes : Int

    var user : User
    var categoryId : Int
    var questionId : Int
    var formatedVotesText : String{
        return NumberFormatter.format(number: votes)
    }
    
    init (title : String,timeAsked : TimeInterval,categoryName : String,votes : Int, user : User, categoryId : Int,questionId : Int){
        self.title = title
        self.timeAsked = timeAsked
        self.categoryName = categoryName
        self.votes = votes
        self.user = user
        self.categoryId = categoryId
        self.questionId = questionId
    }
    
    
}
