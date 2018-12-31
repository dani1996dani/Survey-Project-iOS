//
//  QuestionDetailViewController.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 12/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class QuestionDetailViewController: UIViewController {
    
    var question : Question!
    var detailedQuestion : DetailedQuestion!
    let voteDelegate = VoteDelegate.shared
    var votedForAnswerId = -1 {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var totalVotesLabel: UILabel!
    @IBOutlet weak var askedByLabel: UILabel!
    
    var answers : [PossibleAnswer] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.tableFooterView = UIView(frame: .zero)
        
    }
    
    ///Go back to the the QuestionsViewController when the back button is pressed.
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    ///inits required conditions for the view controller
    func initController(){
        self.view.showBlurLoader()
        voteDelegate.newAnswersDelegate = self
        voteDelegate.connect(with: question.questionId)
        
        questionTitleLabel.text = question.title
        askedByLabel.text = "Asked By: \(question.user.username)"
        
        QuestionDetailDataSource.shared.getDetailedQuestionById(quesitonId: question.questionId) { (question) in
            self.detailedQuestion = question
            self.answers = question.possibleAnswers
            self.votedForAnswerId = self.detailedQuestion.votedForAnswerId
            self.calculateTotalVotes()
            self.view.removeBluerLoader()
        }
    }
    
    
}



extension QuestionDetailViewController : UITableViewDelegate{
    
}

extension QuestionDetailViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoteCell") as! VoteTableViewCell
        cell.selectionStyle = .none
        let index = indexPath.row
        let answer = answers[index]
        
        ///the delegates that allow voting
        cell.websocketVoteDelegate = voteDelegate
        cell.viewControllerVoteDelegate = self
        
        let isVotedFor = answer.answerId == votedForAnswerId
        if isVotedFor {
            if isVotedFor != cell.voteButton.isOn{
                cell.voteButton.activateButton(bool: true)
            }
        }
        else{
            if isVotedFor != cell.voteButton.isOn{
                cell.voteButton.activateButton(bool: false)
            }
        }
        
        cell.answerLabel.text = answer.answerTitle
        cell.voteAmountLabel.text = "Votes: \(answer.votes)"
        cell.answer = answer
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        voteDelegate.disconnect(from: question.questionId)
    }
    
    
}

extension QuestionDetailViewController : VoteCellDelegate{
    ///handles the upvote of an answer
    func didUpvote(questionId: Int, answerId: Int) {
        self.view.showBlurLoader()
        votedForAnswerId = answerId
    }
    
    ///handles the downvote of an answer
    func didDownvote(questionId: Int, answerId: Int) {
        self.view.showBlurLoader()
        votedForAnswerId = -1
        print(votedForAnswerId)
    }
}

extension QuestionDetailViewController : NewAnswerDataDelegate{
    
    ///handles the error when trying to get new answers, shows an alert that suggests to the user to retry the action
    func onError() {
        let alertController = UIHttpError.shared.httpErrorAlert()
        let reconnectAction = UIAlertAction(title: "Retry Connection", style: .default) { (_) in
            self.voteDelegate.connect(with: self.question.questionId)
        }
        alertController.addAction(reconnectAction)
            
        self.present(alertController, animated: true)
    }
    
    ///updates the answer id the user voted for
    func onNewVotedFor(newVotedFor: Int) {
        votedForAnswerId = newVotedFor
    }
    
    ///updates the possible answers to the new answers received from the server
    func onNewData(answers: [PossibleAnswer]) {
        self.answers = answers
        self.tableView.reloadData()
        
        calculateTotalVotes()
        self.view.removeBluerLoader()
    }
    
    ///calculates the new total votes of the question, and presents it in the UI
    func calculateTotalVotes(){
        var totalVotes = 0
        for answer in answers{
            totalVotes += answer.votes
        }
        
        let totalVotesText = NumberFormatter.format(number: totalVotes)
        totalVotesLabel.text = "Total Votes: \(totalVotesText)"
    }
    
    
}

