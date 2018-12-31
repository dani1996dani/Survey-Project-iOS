//
//  HttpErrorUI.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 23/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class UIHttpError{
    
    private init(){
        
    }
    
    static let shared = UIHttpError()
    
    /// - returns: a `UIAlertController` that shows a loss of internet connection.
    func httpErrorAlert() -> UIAlertController{
        return UIAlertController(title: "Lost Connection", message: "Unable to reach our servers.", preferredStyle: .alert)
    }
    
}
