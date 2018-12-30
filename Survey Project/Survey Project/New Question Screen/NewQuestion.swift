//
//  NewQuestion.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 22/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class NewQuestion : Encodable{
    
    var question : String
    var categoryName : String
    var answers : [String]
    var askerToken : String
    
    init(){
        question = ""
        answers = []
        categoryName = ""
        askerToken = Auth.userToken
    }
    
    
    
}
