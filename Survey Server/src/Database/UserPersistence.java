package Database;

import Entities.ProfileMetadata;
import Entities.User;

import java.sql.*;

public class UserPersistence {

    public static UserPersistence instance;

    private UserPersistence(){

    }

    public static UserPersistence getInstance(){
        if (instance == null)
            instance = new UserPersistence();
        return instance;
    }

    public User getUserIdByToken(Connection connection, String token) throws SQLException{
        User user = null;
        try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT user_id,user_name FROM survey.users WHERE user_token = ?")){
            preparedStatement.setString(1,token);
            try(ResultSet resultSet = preparedStatement.executeQuery()){
                if(resultSet.next()){
                    int userId  = resultSet.getInt("user_id");
                    String userName = resultSet.getString("user_name");

                    user = new User(userId,userName);
                }
            }
        }
        return user;
    }

    public User getUserById(Connection connection,int userId) throws SQLException{
        User user = null;
        try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT user_name FROM survey.users WHERE user_id = ?")){
            preparedStatement.setInt(1,userId);
            try(ResultSet resultSet = preparedStatement.executeQuery()){
                if (resultSet.next()){
                    String username = resultSet.getString("user_name");
                    user = new User(userId,username);
                }
            }
        }
        return user;
    }



    public ProfileMetadata getUserProfileMetadata(String userToken){
        ProfileMetadata profileMetadata = null;

        int votes = 0;
        int questions = 0;

        try(Connection connection = DB.getConnection()){

            User user = getUserIdByToken(connection,userToken);
            if (user == null)
                return profileMetadata;

            try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT COUNT(*) as votes FROM survey.votes WHERE user_id = ?")){
                preparedStatement.setInt(1,user.getUserId());
                try(ResultSet resultSet = preparedStatement.executeQuery()){
                    if (resultSet.next()){
                        votes = resultSet.getInt("votes");
//                        profileMetadata.setVoteAmount(totalAmountOfUserVotes);
                    }
                }
            }

            try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT COUNT(*) as questions FROM survey.questions WHERE user_id = ?")){
                preparedStatement.setInt(1,user.getUserId());
                try(ResultSet resultSet = preparedStatement.executeQuery()){
                    if (resultSet.next()){
                        questions = resultSet.getInt("questions");
//                        profileMetadata.setQuestionAmount(totalAmountOfUSerQuestions);
                    }
                }
            }

            profileMetadata = new ProfileMetadata(votes,questions,user);


        } catch (SQLException e) {
            e.printStackTrace();
        }

        return profileMetadata;
    }

    public boolean isUsernameAvailable(Connection connection,String username) throws SQLException{
        try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT user_name FROM survey.users WHERE user_name = ?")){
            preparedStatement.setString(1,username);
            try(ResultSet resultSet = preparedStatement.executeQuery()){
                if (resultSet.next()){
                    return false;
                }
                else{
                    return true;
                }
            }
        }
    }

}
