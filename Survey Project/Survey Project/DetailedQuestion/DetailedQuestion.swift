
import UIKit

class DetailedQuestion: Question {
    var possibleAnswers : [PossibleAnswer]
    var votedForAnswerId : Int
    
    init (title : String,timeAsked : TimeInterval,categoryName : String,votes : Int, user : User, categoryId : Int,questionId : Int,possibleAnswers : [PossibleAnswer],votedForAnswerId : Int){
        self.possibleAnswers = possibleAnswers
        self.votedForAnswerId = votedForAnswerId
        super.init(title: title, timeAsked: timeAsked, categoryName: categoryName, votes: votes, user: user, categoryId: categoryId, questionId: questionId)
        
    }
}
