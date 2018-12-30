//
//  VoteTableViewCell.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 16/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class VoteTableViewCell: UITableViewCell {

   
    @IBOutlet weak var voteAmountLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var voteButton: RoundedButton!
    var answer : PossibleAnswer!
    var websocketVoteDelegate : VoteCellDelegate?
    var viewControllerVoteDelegate : VoteCellDelegate?
    
    
    
    @IBAction func voteButtonTapped(_ sender: RoundedButton) {
        print(sender.isOn,answer.answerId)
        if sender.isOn{
            websocketVoteDelegate?.didUpvote(questionId: answer.questionId, answerId: answer.answerId)
            viewControllerVoteDelegate?.didUpvote(questionId: answer.questionId, answerId: answer.answerId)
        }
        else{
            websocketVoteDelegate?.didDownvote(questionId: answer.questionId, answerId: answer.answerId)
            viewControllerVoteDelegate?.didDownvote(questionId: answer.questionId, answerId: answer.answerId)
        }
    }
    
    
    
}

protocol VoteCellDelegate{
    func didUpvote(questionId : Int,answerId : Int)
    func didDownvote(questionId : Int,answerId : Int)
}
