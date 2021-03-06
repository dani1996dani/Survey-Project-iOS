//
//  MyProfileViewController.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 26/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    var profileMetadata : ProfileMetadata!{
        didSet{
            loadUIMetadata()
        }
    }
 
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var voteAmountLabel: UILabel!
    @IBOutlet weak var questionAmountLabel: UILabel!
    
    var myQuestions : [Question] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var profileMetadataViews: [UIView]!
    
    static var shouldReloadQuestions = true
    static var shouldReloadProfileMetadata = true
    
    var shouldShowLoading = false{
        didSet{
            if shouldShowLoading{
                self.view.showBlurLoader()
            }
            else{
                self.view.removeBluerLoader()
            }
        }
    }
    var loadingElements = 0 {
        didSet {
            if loadingElements == 0{
                shouldShowLoading = false
            }
            else if loadingElements > 0{
                if !shouldShowLoading{
                    shouldShowLoading = true
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.tableFooterView = UIView(frame: .zero)
        loadData()
    }
    
    /**
        Load the profile metadata, and loads the users questions.
    */
    func loadData(){
        let profileDataSource = ProfileDataSource.shared

            loadingElements += 1
            profileDataSource.getProfileMetadata { (profileMetadata) in
                self.profileMetadata = profileMetadata
                self.loadingElements -= 1
                MyProfileViewController.shouldReloadProfileMetadata = false
            }

            loadingElements += 1
            profileDataSource.getMyQuestions{(questions) in
                self.myQuestions = questions
                MyProfileViewController.shouldReloadQuestions = false
                self.loadingElements -= 1
            }
    }
    
    /**
     Updates the UI when the metadata object is updated.
     */
    func loadUIMetadata(){
        voteAmountLabel.text = profileMetadata.voteText
        questionAmountLabel.text = profileMetadata.questionText
        navigationTitle.title = "\(profileMetadata.user.username)'s profile"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue to the QuestionDetailViewController when a user taps his own question for further viewing.
        if (segue.identifier == "goto_question_detail"){
            let dest = segue.destination as! QuestionDetailViewController
            dest.question = sender as! Question
        }
    }
}

extension MyProfileViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Recent Questions"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //sends the user to DetailQuestionViewController, to show him his question.
        let question = myQuestions[indexPath.row]
        print(question.title,question.votes)
        performSegue(withIdentifier: "goto_question_detail", sender: question)
    }
}

extension MyProfileViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ownQuestion") as! ProfileTableViewCell
        let index = indexPath.row
        let question = myQuestions[index]
        
        cell.quesitonLabel.text = question.title
        cell.voteAmountLabel.text = question.formatedVotesText
        
        return cell
    }
    
    
}
