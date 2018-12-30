//
//  WebConnectionSettings.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 09/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation

class WebConnectionSettings{
    
    private static let localHost = "localhost:8080/"
    private static let herokuHost = "survey-project-ios.herokuapp.com/"
    
    
    static let HOST = herokuHost
    static let HTTP_PROTOCOL = "https://"
    static let WEBSOCKET_PROTOCOL = "wss://"
    static let AUTH_SERVLET = "AuthServlet"
    static let QUESTION_SERVLET = "QuestionServlet"
    static let PROFILE_SERVLET = "ProfileServlet"
    
}
