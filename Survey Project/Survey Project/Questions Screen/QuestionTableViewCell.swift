//
//  QuestionTableViewCell.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 12/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var categoryText: UILabel!
    @IBOutlet weak var timeAskedText: UILabel!
    @IBOutlet weak var votesAmountText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
