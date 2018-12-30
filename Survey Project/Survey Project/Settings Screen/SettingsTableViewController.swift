//
//  SettingsTableViewController.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 26/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        //sends the user to the about us page
        if section == 0 && row == 0{
            performSegue(withIdentifier: "about_us", sender: nil)
        }
        //logs the user out and shows the login screen again
        if section == 1 && row == 0{
            Auth.logout()
            let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "login_controller") as! LoginController
            loginViewController.onLoginDelegate = self.tabBarController as! MainTabBarViewController
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}
