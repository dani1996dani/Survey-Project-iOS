//
//  NewQuestionDataSource.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 23/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation
class NewQuestionDataSource{
    
    private init(){
        
    }
    
    static let shared = NewQuestionDataSource()
    var httpErrorDelegate : HttpErrorDelegate?
    
    func getAllCategoriyNames(completion: @escaping ([String])->()){
        let urlString = "\(WebConnectionSettings.HTTP_PROTOCOL)\(WebConnectionSettings.HOST)\(WebConnectionSettings.QUESTION_SERVLET)?action=get_all_categories"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil{
                DispatchQueue.main.async {
                    
                    self.httpErrorDelegate?.onError(erroredIn: self)
                }
                
                return
            }
            
            guard let data = data else{return;}
            
            let names = self.parseCategoryNames(data: data)
            DispatchQueue.main.async {
                completion(names)
            }
        }
        task.resume()
    }
    
    func parseCategoryNames(data : Data) -> [String]{
        var names : [String] = []
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSON
        for obj in json{
//            print(obj.value as! String)
            let name = obj.value as! String
            names.append(name)
        }
        return names
    }
    
}
