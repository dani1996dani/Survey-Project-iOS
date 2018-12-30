//
//  ProfileMetadata.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 26/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class ProfileMetadata {
    var voteAmount : Int
    var questionAmount : Int
    var user : User
    
    var voteText : String{
        return NumberFormatter.format(number: voteAmount)
    }
    
    var questionText : String {
        return NumberFormatter.format(number: questionAmount)
    }
    
    init(voteAmount : Int,questionAmount : Int,user : User){
        self.voteAmount = voteAmount
        self.questionAmount = questionAmount
        self.user = user
    }
}
