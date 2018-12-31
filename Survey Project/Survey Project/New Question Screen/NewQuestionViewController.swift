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
    
    var selectedCategory = ""
    
    
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var questionField: PaddedTextField!
    @IBOutlet weak var questionCategoryField: PaddedTextField!
    @IBOutlet var answerFieldCollection: [UITextField]!
    
    var categoryNames : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initCustomSearchField()
        initTextDelegate()
        getCategories()
        createCategoryPicker()
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        clearUI()
        
    }
    

    /// Calls the new questions data source to fetch new questions.
    func getCategories(){
        let newQuestionsDataSource = NewQuestionDataSource.shared
        newQuestionsDataSource.httpErrorDelegate = self
        newQuestionsDataSource.getAllCategoriyNames { (strings) in
            self.categoryNames = strings
//            self.questionCategoryField.filterStrings(strings)
        }
    }
    
    func createCategoryPicker() {
        
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        
        questionCategoryField.inputView = categoryPicker
        createToolbar()
    }
    
    func createToolbar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NewQuestionViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        questionCategoryField.inputAccessoryView = toolBar
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    ///restarts the UI to its 'clean' state
    func clearUI(){
        self.view.removeBluerLoader()
        self.scrollVIew.scrollToTop()
        self.instructionTextView.textColor = UIColor.black
        visibleAnswers = 2
        addAnswerButton.isEnabled = true
        questionField.text = ""
        
        selectedCategory = ""
        questionCategoryField.text = selectedCategory
        
        for index in 0..<answerFieldCollection.count{
            answerFieldCollection[index].text = ""
            if index >= visibleAnswers{
                answerFieldCollection[index].isHidden = true
            }
        }
    }
    
    ///gets called when the user taps the + navigation item.
    @IBAction func addAnswer(_ sender: Any) {
        if visibleAnswers < answerFieldCollection.count{
            answerFieldCollection[visibleAnswers].isHidden = false
            visibleAnswers += 1
            if visibleAnswers == answerFieldCollection.count{
                addAnswerButton.isEnabled = false
            }
        }
      
    }
    ///inits the question category input
    func initCustomSearchField(){
    }
    
    ///setting the textfield delegates as the viewcontroller to handle keyboard hiding when return key is pressed.
    func initTextDelegate(){
        questionField.delegate = self
        for field in answerFieldCollection{
            field.delegate = self
        }
    }
    
    ///grab all answers from the possible answers inputs
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
    
    ///grabs the question input
    func grabQuestion() -> String{
        let inputString = questionField.text ?? ""
        return inputString
    }
    
    ///grabs the category input
    func grabCategory() -> String{
        return selectedCategory
    }
    
    ///validates that all new question constraints are met, and if are continues to submit in submitQuestion()
    @IBAction func submitTapped(_ sender: UIButton) {
        
        let question = grabQuestion()
        let category = grabCategory()
        let answers = grabAnswers()
        
        if question.isEmpty{
            displayInstructionsAgain()
            return
        }
        
        if answers.count < 2{
            displayInstructionsAgain()
            return
        }
        
        if category.isEmpty{
            displayInstructionsAgain()
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
    
    ///submits the new question to the server, handles success and error responses
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
    ///shakes the instruction textview and makes it red to indicate that the user is not meeting the conditions
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
    ///alerts an error alert when an error response was received from the server on new question submition.
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
    ///alerts a success alert when a success response was received from the server on new question submition.
    func displaySubmitSuccess(){
        let alertController = UIAlertController(title: "Success", message: "The question was received and proccessed! Thank you.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Take me home", style: .default, handler: { (_) in
            self.tabBarController?.selectedIndex = 0
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

extension NewQuestionViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryNames.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryNames[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedCategory = categoryNames[row]
        questionCategoryField.text = selectedCategory
    }
    
}

extension NewQuestionViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension NewQuestionViewController : HttpErrorDelegate{
    ///handling loss of connection mid-sumbition of new question
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





