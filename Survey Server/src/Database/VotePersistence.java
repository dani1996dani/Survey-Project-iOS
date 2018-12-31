package Database;

import Entities.PossibleAnswer;
import Entities.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VotePersistence {

    public static VotePersistence instance;

    private VotePersistence() {

    }

    public static VotePersistence getInstance() {
        if (instance == null)
            instance = new VotePersistence();
        return instance;
    }

    public int upvoteByAnswerId(int questionId, int answerId, String userToken) {
        int newVotedForAnswer = -1;
        try (Connection connection = DB.getConnection()) {
            User user = UserPersistence.getInstance().getUserIdByToken(connection, userToken);

            if (user == null){
                throw new SQLException("Invalid user token - no relevant user id found");
            }

            //Checks if the user already voted for this answer,if yes,delete it and insert a new row of the different answer
            try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM survey.votes WHERE question_id = ? AND user_id = ?")){
                preparedStatement.setInt(1,questionId);
                preparedStatement.setInt(2,user.getUserId());
                try(ResultSet resultSet = preparedStatement.executeQuery()){
                    if (resultSet.next()){
                        deleteVote(connection,questionId,user.getUserId());
                    }
                }
            }

            try (PreparedStatement preparedStatement = connection.prepareStatement("INSERT INTO survey.votes(question_id, answer_id, user_id) VALUES (?,?,?)")) {
                preparedStatement.setInt(1, questionId);
                preparedStatement.setInt(2, answerId);
                preparedStatement.setObject(3, user.getUserId());

                int rowsAffected = preparedStatement.executeUpdate();
                if (rowsAffected < 1)
                    throw new SQLException("An INSERT statement was not successful");
            }

            newVotedForAnswer = QuestionPersistence.getInstance().getAnswerVotedFor(connection, user.getUserId(), questionId);


        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
        return newVotedForAnswer;
    }

    //should return -1.
    public int downvoteByAnswerId(int questionId,int answerId,String userToken){
        int newVotedForAnswer = -1;
        try (Connection connection = DB.getConnection()) {
            User user = UserPersistence.getInstance().getUserIdByToken(connection, userToken);

            if (user == null){
                throw new SQLException("Invalid user token - no relevant user id found");
            }

            deleteVote(connection,questionId,user.getUserId());

            newVotedForAnswer = QuestionPersistence.getInstance().getAnswerVotedFor(connection, user.getUserId(), questionId);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return newVotedForAnswer;
    }

    private void deleteVote(Connection connection,int questionId,int userId) throws SQLException{
        try(PreparedStatement deleteStatement = connection.prepareStatement("DELETE FROM survey.votes WHERE question_id = ? AND user_id = ?")){
            deleteStatement.setInt(1,questionId);
            deleteStatement.setInt(2,userId);
            int rowsAffected = deleteStatement.executeUpdate();
            if (rowsAffected == 0){
                throw new SQLException("Invalid State - Did not delete a row.");
            }
        }
    }

}
