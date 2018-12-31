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
    
    ///a timer to send pongs to the server, so the WebSocket connect can be kept alive with the Heroku server, due to Herokus limitations. (This is not a requirment for a vanilla WebSocket connection).
    var pongTimer : Timer?
    
    private init(){
    }
    
    static let shared = VoteDelegate()
    var socket : WebSocket!
    
    
    ///Connects with a WebSocket protocol, to the server endpoint that handles the specific question id.
    /// - parameters:
    ///     - questionId: the question id that is passed to the endpoint.
    func connect(with questionId : Int){
        let urlString  = "\(WebConnectionSettings.WEBSOCKET_PROTOCOL)\(WebConnectionSettings.HOST)vote?question_id=\(questionId)"
        socket = WebSocket(url: URL(string: urlString)!)
        socket.delegate = self
        socket.connect()
        initiatedDisconnect = false
        pongTimer = Timer.scheduledTimer(timeInterval: 25.0, target: self, selector: #selector(sendPong), userInfo: nil, repeats: true)
        
    }
    
    ///Disconnects from a WebSocket connection, to the server endpoint that handles the specific question id.
    /// - parameters:
    ///     - questionId: the question id that is passed to the endpoint.
    func disconnect(from questionId : Int){
        
        //stops the pong timer, as sending pongs to the server is no longer required.
        pongTimer?.invalidate()
        let disconnectMessage = DisconnectMessage(questionId: questionId).toJSON()
        socket.write(string: disconnectMessage)
        initiatedDisconnect = true
        socket.disconnect()
        
    }
    
    ///sends a single pong packet to the server, to keep the WebSocket connection alive, due to Heroku limitations.
    @objc func sendPong(){
        socket.write(pong: Data())
    }
}

extension VoteDelegate : VoteCellDelegate{
    
    ///Sends an upvote message to the WebSocket endpoint for an answer id.
    /// - parameters:
    ///     - questionId: the question id of the answer id.
    ///     - answerId: the answer id to upvote.
    func didUpvote(questionId: Int, answerId: Int) {
        let voteMessage = VoteMessage(action: "upvote", questionId: questionId, answerId: answerId, userToken: Auth.userToken)
        let json = voteMessage.toJSON()
        socket.write(string: json)
    }
    
    ///Sends a downvote message to the WebSocket endpoint for an answer id.
    /// - parameters:
    ///     - questionId: the question id of the answer id.
    ///     - answerId: the answer id to downvote.
    func didDownvote(questionId: Int, answerId: Int) {
        let voteMessage = VoteMessage(action: "downvote", questionId: questionId, answerId: answerId,userToken: Auth.userToken)
        let json = voteMessage.toJSON()
        socket.write(string: json)
    }
}

extension VoteDelegate : WebSocketDelegate{
    func websocketDidConnect(socket: WebSocketClient) {
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        //stops the pong timer, as sending pongs to the server is no longer required.
        pongTimer?.invalidate()
        
        //if the user did not initiate a WebSocket disconnect request from the server, that means that the WebSocket connection was interuptted and the user should be notifed of the error.
        if !initiatedDisconnect{
            newAnswersDelegate?.onError()
        }
        
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if text != "Error"{
            parseJSONResponse(jsonString: text)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
    }
    
    ///Parses a server response based on the action inside the message
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
    
    ///Parses new answers from the server, that contain the new vote count for the answers.
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
    ///notify the delegate that new answers have arrived from the server.
    func onNewData(answers : [PossibleAnswer])
    ///notify the delegate that a new voted for answer id has arrived from the server.
    func onNewVotedFor(newVotedFor : Int)
    ///notify the delegate that an error occured.
    func onError()
}
