package WebSocket;

import Database.DB;
import Database.QuestionPersistence;
import Database.VotePersistence;
import Entities.PossibleAnswer;
import org.json.JSONObject;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;


@ServerEndpoint("/vote")
public class VoteEndpoint {

    public static final String ERROR = "Error";

    @OnOpen
    public void open(Session session) {
        System.out.println("This is the websocket opened");
        System.out.println(session);
        List<String> questionIdParams = session.getRequestParameterMap().get("question_id");
        if (questionIdParams == null || questionIdParams.size() < 1)
            return;

        String qId = questionIdParams.get(0);
        int questionId;
        try {
            questionId = Integer.valueOf(qId);
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
        SessionManager.getInstance().registerSessionByQuestionId(questionId, session);


//        String test = session.getRequestParameterMap().get("test").get(0);
//        System.out.println(test);
    }

    @OnClose
    public void close(Session session) {
        System.out.println("disconnected");

    }

    @OnError
    public void onError(Session session,Throwable error) {
        SessionManager.getInstance().removeSession(session);
        error.printStackTrace();
    }

    @OnMessage
    public void pongMessage(PongMessage message){
        System.out.println("Pong: " + message);

    }

    @OnMessage
    public void handleMessage(String message, Session session) {
        System.out.println("from: " + session + ", " + message);
        JSONObject jsonObject = new JSONObject(message);
        String action = jsonObject.getString("action");
        switch (action) {
            case "upvote":
                int questionId = jsonObject.getInt("questionId");
                int answerId = jsonObject.getInt("answerId");
                String userToken = jsonObject.getString("userToken");
                int newVotedFor = VotePersistence.getInstance().upvoteByAnswerId(questionId, answerId, userToken);

                if (newVotedFor == -1)
                    return;
                else {
                    String updateVotedForMessage = messageForUpdateVotedFor(newVotedFor);
                    try {
                        session.getBasicRemote().sendText(updateVotedForMessage);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }

                updateClientsAnswersByQuestionId(questionId);

                return;


            case "downvote":
                questionId = jsonObject.getInt("questionId");
                answerId = jsonObject.getInt("answerId");
                userToken = jsonObject.getString("userToken");
                newVotedFor = VotePersistence.getInstance().downvoteByAnswerId(questionId, answerId, userToken);

                if (newVotedFor == -1) {
                    String updateVotedForMessage = messageForUpdateVotedFor(newVotedFor);
                    try {
                        session.getBasicRemote().sendText(updateVotedForMessage);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                } else
                    return;

                updateClientsAnswersByQuestionId(questionId);


                break;

            case "disconnect":
                questionId = jsonObject.getInt("questionId");
                SessionManager.getInstance().removeSessionByQuestionId(questionId, session);
                break;
        }

    }


    private List<PossibleAnswer> getNewPossibleAnswers(int questionId) {
        try (Connection connection = DB.getConnection()) {
            return QuestionPersistence.getInstance().getAnswersByQuestionId(connection, questionId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String messageForUpdateVotedFor(int newVotedFor) {
        JSONObject updateVotedFor = new JSONObject();
        updateVotedFor.put("action", "update_voted_for");
        updateVotedFor.put("voted_for", newVotedFor);
        return updateVotedFor.toString();
    }

    private void updateClientsAnswersByQuestionId(int questionId) {
        List<PossibleAnswer> answers = getNewPossibleAnswers(questionId);
        if (answers == null)
            return;

        Set<Session> registeredSessions = SessionManager.getInstance().getSessionsByQuestionId(questionId);

        JSONObject updatedAnswerObject = new JSONObject();
        updatedAnswerObject.put("action", "new_answers");
        updatedAnswerObject.put("answers", answers);

        String messageToClients = updatedAnswerObject.toString();

        for (Session regSesh : registeredSessions) {
            regSesh.getAsyncRemote().sendText(messageToClients);
        }
    }

//    private void pushNewAnswers(Set<Session> sessionsSet, List<PossibleAnswer> answers) {
//        String message = new JSONArray(answers).toString();
//        for (Session session : sessionsSet) {
//            session.getAsyncRemote().sendText(message);
//        }
//    }

}

