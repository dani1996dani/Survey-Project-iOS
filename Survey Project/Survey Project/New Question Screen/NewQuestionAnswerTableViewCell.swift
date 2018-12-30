//
//  NewQuestionAnswerTableViewCell.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 22/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class NewQuestionAnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var answerField: PaddedTextField!
    var answer : String{
        return answerField.text ?? ""
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
