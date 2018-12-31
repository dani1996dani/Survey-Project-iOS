//
//  QuestionsViewController.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 09/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //the last time of reloading the tableview, to calculate the time passed from the question being asked to now
    var timeOfReload : TimeInterval = 0
    
    var isFiltered = false
    var filterText = ""
    let refreshControl = UIRefreshControl()
    
    var questions : [Question] = [] {
        didSet{
            DispatchQueue.main.async {
                self.timeOfReload = Date().timeIntervalSince1970 * 1000
                self.isFiltered = false
                self.tableView.reloadData()
                self.view.removeBluerLoader()
                self.refreshControl.endRefreshing()
                
            }
        }
    }
    
    var filteredQuestions : [Question] = [] {
        didSet{
            self.timeOfReload = Date().timeIntervalSince1970 * 1000
            isFiltered = true
            self.tableView.reloadData()
            self.view.removeBluerLoader()
            self.refreshControl.endRefreshing()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    ///refreshes the content of the tableview with new questions
    @objc func refresh(){
        if !isFiltered{
            loadQuestions(showBlur: false)
        }
        else{
            loadFilteredQuestions(with: filterText, showBlur: false)
        }
        print("Refreshed!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.tableFooterView = UIView(frame: .zero)
        if questions.isEmpty{
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
            if #available(iOS 10.0, *) {
                tableView.addSubview(refreshControl)
                tableView.sendSubviewToBack(refreshControl)
            } else {
                tableView.backgroundView = refreshControl
            }
            
            QuestionsDataSource.shared.httpErrorDelegate = self
            
            if(Auth.isAuthorized){
                loadQuestions(showBlur: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    ///gets new questions from the question data source
    func loadQuestions(showBlur : Bool){
        if showBlur{
            self.view.showBlurLoader()
        }
        QuestionsDataSource.shared.getRecentQuestions(limit: 10){(questions) in
            self.questions = questions
            if showBlur{
                self.view.removeBluerLoader()
            }
        }
    }
     ///gets new filtered questions from the question data source
    ///- parameters:
    ///     - filter: the String to filter questions by
    ///     - showBlur: should show blur or not while fetching new questions.
    func loadFilteredQuestions(with filter : String,showBlur : Bool){
        if showBlur{
            self.view.showBlurLoader()
        }
        QuestionsDataSource.shared.getFilteredQuestions(limit: 10, using: filter) { (filteredQuestions) in
            self.filteredQuestions = filteredQuestions
            if showBlur{
                self.view.removeBluerLoader()
            }
        }
    }
    
    ///resets the tableview to unfiltered mode
    func resetQuestions(){
        isFiltered = false
        self.tableView.reloadData()
    }
}

extension QuestionsViewController : UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        resetQuestions()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var searchText = searchBar.text ?? ""
        searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        searchBar.resignFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton{
            searchBar.setShowsCancelButton(true, animated: true)
            cancelButton.isEnabled = true
        }
        
        filterText = searchText
        loadFilteredQuestions(with: searchText, showBlur: true)
    }
}

extension QuestionsViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question : Question!
        if !isFiltered{
            question = questions[indexPath.row]
        }
        else{
            question = filteredQuestions[indexPath.row]
        }

        //segues to the DetailQuestionViewController to show the question.
        performSegue(withIdentifier: "question_detail", sender: question)
    }
}

extension QuestionsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isFiltered{
            return questions.count
        }
        else{
            return filteredQuestions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "question")! as! QuestionTableViewCell
        let question : Question!
        if !isFiltered {
            question = questions[indexPath.row]
        }
        else{
            question = filteredQuestions[indexPath.row]
        }
        
        
        cell.questionTitle.text = question.title
        cell.categoryText.text = question.categoryName
        
        let timeSpan = (timeOfReload - question.timeAsked).rounded()
        cell.timeAskedText.text = TimeFormatter.millisToTimespan(millis: timeSpan)
        
        cell.votesAmountText.text = NumberFormatter.format(number: question.votes)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "question_detail"){
            let dest = segue.destination as! QuestionDetailViewController
            dest.question = sender as! Question
        }
    }
    
}

extension QuestionsViewController : HttpErrorDelegate{
    
    ///handles loss of http connection
    func onError(erroredIn: Any) {
        let alertController = UIAlertController(title: "Lost Connection", message: "Unable to reach our servers.", preferredStyle: .alert)
        let reconnectAction = UIAlertAction(title: "Retry Connection", style: .default) { (_) in
            self.loadQuestions(showBlur: true)
        }
        alertController.addAction(reconnectAction)
        
        self.present(alertController, animated: true)
    }
    
    
    
}

