//
//  VoteDelegate.swift
//  Survey Project
//
//  Created by Daniel Butrashvili on 17/12/2018.
//  Copyright © 2018 Daniel Butrashvili. All rights reserved.
//

import Foundation
import Starscream

class VoteDelegate{
    
    var newAnswersDelegate : NewAnswerDataDelegate?
    var initiatedDisconnect = false
    var pongTimer : Timer?
    
    private init(){
        
        
    }
    static let shared = VoteDelegate()
    var socket : WebSocket!
    
    func connect(with questionId : Int){
        let urlString  = "\(WebConnectionSettings.WEBSOCKET_PROTOCOL)\(WebConnectionSettings.HOST)vote?question_id=\(questionId)"
        socket = WebSocket(url: URL(string: urlString)!)
        socket.delegate = self
        socket.connect()
        initiatedDisconnect = false
        pongTimer = Timer.scheduledTimer(timeInterval: 25.0, target: self, selector: #selector(sendPong), userInfo: nil, repeats: true)
        
    }
    
    func disconnect(from questionId : Int){
        pongTimer?.invalidate()
        let disconnectMessage = DisconnectMessage(questionId: questionId).toJSON()
        socket.write(string: disconnectMessage)
        initiatedDisconnect = true
        socket.disconnect()
        
    }
    
    @objc func sendPong(){
        socket.write(pong: Data())
        print("pong sent")
    }
}

extension VoteDelegate : VoteCellDelegate{
    func didUpvote(questionId: Int, answerId: Int) {
        //        print("yay thank \(questionId) -> \(answerId)")
        
        let voteMessage = VoteMessage(action: "upvote", questionId: questionId, answerId: answerId, userToken: Auth.userToken)
        let json = voteMessage.toJSON()
        print(json)
        socket.write(string: json)
    }
    
    func didDownvote(questionId: Int, answerId: Int) {
        let voteMessage = VoteMessage(action: "downvote", questionId: questionId, answerId: answerId,userToken: Auth.userToken)
        let json = voteMessage.toJSON()
        print(json)
        socket.write(string: json)
    }
}

extension VoteDelegate : WebSocketDelegate{
    func websocketDidConnect(socket: WebSocketClient) {
        print("COnnectied")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconecteddddd")
        pongTimer?.invalidate()
        if !initiatedDisconnect{
            newAnswersDelegate?.onError()
        }
        
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        if text != "Error"{
            parseJSONResponse(jsonString: text)
            //            parseNewAnswers(jsonString: text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Some data was received")
    }
    
    func parseJSONResponse(jsonString : String){
        let data = jsonString.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! JSON
        let action = json["action"] as! String
        switch action {
        case "update_voted_for":
            parseUpdateVotedFor(json: jsonString)
        case "new_answers":
            parseNewAnswers(jsonString: jsonString)
        default:
            print("In default")
        }
    }
    
    func parseNewAnswers(jsonString : String){
        var answers = [PossibleAnswer]()
        let data = jsonString.data(using: .utf8)!
        let wholeJson = try! JSONSerialization.jsonObject(with: data, options: []) as! JSON
        let jsonAnswers = wholeJson["answers"] as! JSONArray
        for object in jsonAnswers{
            let answerId = object["answerId"] as! Int
            let questionId = object["questionId"] as! Int
            let answerTitle = object["answerTitle"] as! String
            let votes = object["votes"] as! Int
            let answer = PossibleAnswer(questionId: questionId, answerId: answerId, answerTitle: answerTitle, votes: votes)
            answers.append(answer)
        }
        newAnswersDelegate?.onNewData(answers: answers)
        
        
    }
    
    func parseUpdateVotedFor(json : String){
        
    }
}



protocol NewAnswerDataDelegate {
    func onNewData(answers : [PossibleAnswer])
    func onNewVotedFor(newVotedFor : Int)
    func onError()
}
