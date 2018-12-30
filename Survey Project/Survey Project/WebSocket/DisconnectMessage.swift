//
//  DisconnectMessage.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 20/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class DisconnectMessage : Encodable{
    var questionId : Int
    let action = "disconnect"
    
    init(questionId : Int){
        self.questionId = questionId
    }
}
