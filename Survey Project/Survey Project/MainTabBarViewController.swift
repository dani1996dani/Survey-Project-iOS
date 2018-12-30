//
//  MainTabBarViewController.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 09/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit


class MainTabBarViewController: UITabBarController {
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
//        LoginController.onLoginDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if (!Auth.isAuthorized){
            performSegue(withIdentifier: "login", sender: nil)
        }
    }
    
    
    
    
}

extension MainTabBarViewController : OnLoginDelegate{
    func onSuccess() {
        print("setting selected index")
        selectedIndex = 0
        let viewController = viewControllers![0] as! QuestionsViewController
        viewController.loadQuestions(showBlur: true)
    }
}
