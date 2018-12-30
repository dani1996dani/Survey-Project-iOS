//
//  NewQuestionViewController.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 22/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import UIKit
import SearchTextField

class NewQuestionViewController: UIViewController {
    
    var visibleAnswers = 2
    @IBOutlet weak var addAnswerButton: UIBarButtonItem!
    @IBOutlet weak var instructionTextView: UITextView!
    
    var newQuestion = NewQuestion()
    
    @IBOutlet weak var scrollVIew: UIScrollView!
    
    let submitError = "Error"
    let submitSuccess = "Success"
    
    
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var scrollContentViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var questionField: PaddedTextField!
    @IBOutlet var answerFieldCollection: [UITextField]!
    @IBOutlet weak var questionCategoryField: SearchTextField!
    var categoryNames : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCustomSearchField()
        initTextDelegate()
        getCategories()
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        clearTextFields()
        
    }
    
    func getCategories(){
        let newQuestionsDataSource = NewQuestionDataSource.shared
        newQuestionsDataSource.httpErrorDelegate = self
        newQuestionsDataSource.getAllCategoriyNames { (strings) in
            self.categoryNames = strings
            self.questionCategoryField.filterStrings(strings)
        }
    }
    
    
    
    
    func clearTextFields(){
        self.view.removeBluerLoader()
        self.scrollVIew.scrollToTop()
        self.instructionTextView.textColor = UIColor.black
        visibleAnswers = 2
        addAnswerButton.isEnabled = true
        print("in clear")
        questionField.text = ""
        questionCategoryField.text = ""
        for index in 0..<answerFieldCollection.count{
            answerFieldCollection[index].text = ""
            if index >= visibleAnswers{
                answerFieldCollection[index].isHidden = true
            }
        }
    }
    
    @IBAction func addAnswer(_ sender: Any) {
        if visibleAnswers < answerFieldCollection.count{
            answerFieldCollection[visibleAnswers].isHidden = false
            visibleAnswers += 1
            if visibleAnswers == answerFieldCollection.count{
                addAnswerButton.isEnabled = false
            }
        }
      
    }
    
    func initCustomSearchField(){
        questionCategoryField.inlineMode = true
        questionCategoryField.layer.borderColor = UIColor.darkGray.cgColor
        questionCategoryField.layer.borderWidth = 1
        questionCategoryField.layer.cornerRadius = 3
    }
    
    func initTextDelegate(){
        questionField.delegate = self
        for field in answerFieldCollection{
            field.delegate = self
        }
    }
    
    func grabAnswers() -> [String]{
        var answers : [String] = []
        for field in answerFieldCollection{
            let answer = field.text ?? ""
            if answer.isEmpty{
                continue
            }
            answers.append(answer)
        }
        return answers
    }
    
    func grabQuestion() -> String{
        let inputString = questionField.text ?? ""
        return inputString
    }
    
    func grabCategory() -> String{
        let inputString = questionCategoryField.text ?? ""
        return inputString
    }
    
    
    @IBAction func submitTapped(_ sender: UIButton) {
        
        let question = grabQuestion()
        let category = grabCategory()
        let answers = grabAnswers()
        
        if question.isEmpty{
            displayInstructionsAgain()
            print("Empty question")
            return
        }
        
        if answers.count < 2{
            displayInstructionsAgain()
            print("not enough answers")
            return
        }
        
        if category.isEmpty{
            displayInstructionsAgain()
            print("not a proper category")
            return
        }
        
        if !categoryNames.contains(category){
            let alertController = UIAlertController(title: "Invalid category", message: "Please select a category that already exists. To request a new category, please e-mail us at no-reply@massquestions.com", preferredStyle: .alert)
            let action = UIAlertAction(title: "Got It", style: .default) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
        
        newQuestion.question = question
        newQuestion.answers = answers
        newQuestion.categoryName = category
        newQuestion.askerToken = Auth.userToken
        
        print(newQuestion.toJSON())
        NewQuestionSubmitDelegate.shared.httpErrorDelegate = self
        submitQuestion()
        self.view.showBlurLoader()
    }
    
    func submitQuestion(){
        instructionTextView.textColor = UIColor.black
        NewQuestionSubmitDelegate.shared.submitNewQuestion(question: newQuestion){(response) in
            self.view.removeBluerLoader()
            if response == self.submitSuccess{
                self.displaySubmitSuccess()
            }else if response == self.submitError{
                self.displaySubmitError()
            }
            
        }
    }
    
    func displayInstructionsAgain(){
        scrollVIew.scrollToTop()
        instructionTextView.textColor = UIColor.red
        UIView.animate(withDuration: 0.05, delay: 0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(3)
            self.instructionTextView.transform = CGAffineTransform(translationX: 5, y: 0)
            
        }, completion:{ (_) in
            self.instructionTextView.transform = CGAffineTransform.identity
        })
        
        
    }
    
    func displaySubmitError(){
        let alertController = UIAlertController(title: "Error", message: "The question failed to be submitted.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (_) in
            self.submitQuestion()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displaySubmitSuccess(){
        let alertController = UIAlertController(title: "Success", message: "The question was received and proccessed! Thank you.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Take me home", style: .default, handler: { (_) in
            self.tabBarController?.selectedIndex = 0
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

extension NewQuestionViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension NewQuestionViewController : HttpErrorDelegate{
    func onError(erroredIn : Any) {
        let alertController = UIHttpError.shared.httpErrorAlert()
        let reconnectAction = UIAlertAction(title: "Retry Connection", style: .default) { (_) in
            if erroredIn is NewQuestionSubmitDelegate{
                self.submitQuestion()
            }
            else if erroredIn is NewQuestionDataSource{
                self.getCategories()
            }
            //            self.voteDelegate.connect(with: self.question.questionId)
        }
        alertController.addAction(reconnectAction)
        
        self.present(alertController, animated: true)
    }
}





