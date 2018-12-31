package Database;

import Entities.*;
import Search.Search;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class QuestionPersistence {

    private static QuestionPersistence instance;

    private QuestionPersistence() {
    }

    public static QuestionPersistence getInstance() {
        if (instance == null)
            instance = new QuestionPersistence();
        return instance;
    }

    public List<BaseQuestion> getAllQuestions() {
        List<BaseQuestion> baseQuestions = new ArrayList<>();

        try (Connection connection = DB.getConnection()) {
            try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT question_id, user_id, title, time_asked, category_id FROM survey.questions ORDER BY time_asked DESC LIMIT 10;")) {
                try (ResultSet resultSet = preparedStatement.executeQuery()) {

                    Map<Integer, String> categoryNameMap = QuestionCategoryPersistence.getInstance().getAllCategories(connection);

                    while (resultSet.next()) {

//                        int questionId = resultSet.getInt("question_id");
//                        int userId = resultSet.getInt("user_id");
//                        String title = resultSet.getString("title");
//                        long timeAsked = resultSet.getLong("time_asked");
//
//                        int categoryId = resultSet.getInt("category_id");
//                        String categoryName = categoryNameMap.get(categoryId);
//                        QuestionCategory questionCategory = new QuestionCategory(categoryId, categoryName);
//                        int questionVotes = getQuestionVotes(connection, questionId);
//
//                        BaseQuestion baseQuestion = new BaseQuestion(questionId, userId, title, timeAsked, questionCategory, questionVotes);
                        BaseQuestion baseQuestion = parseBaseQuestionFormResultSet(connection,resultSet,categoryNameMap);

                        baseQuestions.add(baseQuestion);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return baseQuestions;
    }

    public List<BaseQuestion> getUserQuestions(String userToken){

        List<BaseQuestion> baseQuestions = new ArrayList<>();
        try(Connection connection = DB.getConnection()){

            User user = UserPersistence.getInstance().getUserIdByToken(connection,userToken);

            if (user == null){
                return baseQuestions;
            }

            Map<Integer, String> categoryNameMap = QuestionCategoryPersistence.getInstance().getAllCategories(connection);

            try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT question_id, user_id, title, time_asked, category_id FROM survey.questions WHERE user_id = ? ORDER BY time_asked DESC LIMIT 10")){
                preparedStatement.setInt(1,user.getUserId());
                try(ResultSet resultSet = preparedStatement.executeQuery()){
                    while (resultSet.next()){
                        BaseQuestion baseQuestion = parseBaseQuestionFormResultSet(connection,resultSet,categoryNameMap);
                        baseQuestions.add(baseQuestion);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return baseQuestions;
    }

    private BaseQuestion parseBaseQuestionFormResultSet(Connection connection,ResultSet resultSet,Map<Integer, String> categoryNameMap) throws SQLException{
        int questionId = resultSet.getInt("question_id");
        int userId = resultSet.getInt("user_id");
        String title = resultSet.getString("title");
        long timeAsked = resultSet.getLong("time_asked");

        int categoryId = resultSet.getInt("category_id");
        String categoryName = categoryNameMap.get(categoryId);
        QuestionCategory questionCategory = new QuestionCategory(categoryId, categoryName);
        int questionVotes = getQuestionVotes(connection, questionId);

        User user = UserPersistence.getInstance().getUserById(connection,userId);

        BaseQuestion baseQuestion = new BaseQuestion(questionId, user, title, timeAsked, questionCategory, questionVotes);
        return baseQuestion;
    }



    public Question getQuestionById(int questionId, String token) {
        try (Connection connection = DB.getConnection()) {
            User user = UserPersistence.getInstance().getUserIdByToken(connection, token);
            if (user == null)
                return null;

            int answerVotedForId = getAnswerVotedFor(connection, user.getUserId(), questionId);

            try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM survey.questions WHERE question_id = ?")) {
                preparedStatement.setInt(1, questionId);
                try (ResultSet resultSet = preparedStatement.executeQuery()) {

                    Map<Integer, String> categoryNameMap = QuestionCategoryPersistence.getInstance().getAllCategories(connection);
                    if (resultSet.next()) {
                        int askerId = resultSet.getInt("user_id");
                        String title = resultSet.getString("title");
                        long timeAsked = resultSet.getLong("time_asked");

                        int categoryId = resultSet.getInt("category_id");
                        String categoryName = categoryNameMap.get(categoryId);
                        QuestionCategory questionCategory = new QuestionCategory(categoryId, categoryName);
                        int questionVotes = getQuestionVotes(connection, questionId);
                        List<PossibleAnswer> answers = getAnswersByQuestionId(connection, questionId);


                        Question question = new Question(questionId, user, title, timeAsked, questionCategory, questionVotes, answers, answerVotedForId);
                        return question;
                    }

                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private int getQuestionVotes(Connection connection, int questionId) throws SQLException {
        int votes = 0;
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT COUNT(*) as votes FROM survey.votes WHERE question_id = ?")) {
            preparedStatement.setInt(1, questionId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    votes = resultSet.getInt("votes");
                }
            }
        }

        return votes;
    }

    public List<PossibleAnswer> getAnswersByQuestionId(Connection connection, int questionId) throws SQLException {
        List<PossibleAnswer> answers = new ArrayList<>();
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM survey.question_answers WHERE question_id = ?")) {
            preparedStatement.setInt(1, questionId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    int answerId = resultSet.getInt("answer_id");
                    String title = resultSet.getString("answer_title");
                    int votesForAnswer = getVotesByAnswerId(connection, answerId);
                    PossibleAnswer possibleAnswer = new PossibleAnswer(questionId, answerId, title, votesForAnswer);
                    answers.add(possibleAnswer);
                }
            }
        }
        return answers;
    }

    private int getVotesByAnswerId(Connection connection, int answerId) throws SQLException {
        int votes = 0;
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT COUNT(*) as votes FROM survey.votes WHERE answer_id= ?")) {
            preparedStatement.setInt(1, answerId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    votes = resultSet.getInt("votes");
                }
            }
        }
        return votes;
    }

    public int getAnswerVotedFor(Connection connection, int userId, int questionId) throws SQLException {
        int votedForAnswerId = -1;
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT answer_id FROM survey.votes WHERE question_id = ? AND user_id = ?")) {
            preparedStatement.setInt(1, questionId);
            preparedStatement.setInt(2, userId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    votedForAnswerId = resultSet.getInt("answer_id");
                }
            }
        }
        return votedForAnswerId;
    }

    public List<BaseQuestion> getFilteredQuestions(String searchInput) {
        List<BaseQuestion> baseQuestions = new ArrayList<>();

        QuestionCategory closestCategory = Search.getInstance().closestMatch(searchInput, 3);

        if (closestCategory == null)
            return baseQuestions;

        try (Connection connection = DB.getConnection()) {
            try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT question_id, user_id, title, time_asked, category_id FROM survey.questions WHERE category_id = ? ORDER BY time_asked DESC LIMIT 10;")) {
                preparedStatement.setInt(1, closestCategory.getCategoryId());
                try (ResultSet resultSet = preparedStatement.executeQuery()) {

//                    Map<Integer, String> categoryNameMap = QuestionCategoryPersistence.getInstance().getAllCategories(connection);

                    while (resultSet.next()) {

                        int questionId = resultSet.getInt("question_id");
                        int userId = resultSet.getInt("user_id");
                        String title = resultSet.getString("title");
                        long timeAsked = resultSet.getLong("time_asked");

//                        int categoryId = resultSet.getInt("category_id");
//                        String categoryName = categoryNameMap.get(categoryId);
//                        QuestionCategory questionCategory = new QuestionCategory(categoryId,categoryName);
                        int questionVotes = getQuestionVotes(connection, questionId);

                        User user = UserPersistence.getInstance().getUserById(connection,userId);

                        BaseQuestion baseQuestion = new BaseQuestion(questionId, user, title, timeAsked, closestCategory, questionVotes);
                        baseQuestions.add(baseQuestion);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return baseQuestions;
    }

    public boolean addNewQuestion(NewQuestion questionToAdd) {
        try (Connection connection = DB.getConnection()) {
            User user = UserPersistence.getInstance().getUserIdByToken(connection, questionToAdd.getAskerToken());

            if (user == null)
                return false;

            int categoryId = QuestionCategoryPersistence.getInstance().getCategoryIdByName(connection, questionToAdd.getCategoryName());
            if (categoryId == -1) {
                return false;
            }

            long timeAsked = System.currentTimeMillis();
            String questionTitle = questionToAdd.getQuestion();

            int questionId = -1;

            try (PreparedStatement preparedStatement = connection.prepareStatement("INSERT INTO survey.questions(user_id, title, time_asked, category_id) VALUES (?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
                preparedStatement.setInt(1, user.getUserId());
                preparedStatement.setString(2, questionTitle);
                preparedStatement.setLong(3, timeAsked);
                preparedStatement.setInt(4, categoryId);

                int rowsAffected = preparedStatement.executeUpdate();
                if (rowsAffected == 0) {
                    return false;
                }
                try (ResultSet resultSet = preparedStatement.getGeneratedKeys()) {
                    if (resultSet.next()) {
                        questionId = resultSet.getInt(1);
                    }
                    if (questionId == -1)
                        return false;
                }

            }



            try(PreparedStatement preparedStatement = connection.prepareStatement("INSERT INTO survey.question_answers(question_id, answer_title) VALUES (?, ?)")){
                List<String> answers = questionToAdd.getAnswers();
                for (int i = 0; i < answers.size(); i++) {
                    preparedStatement.setInt(1,questionId);
                    preparedStatement.setString(2,answers.get(i));
                    preparedStatement.addBatch();
                }
                int[] updateCounts = preparedStatement.executeBatch();
                boolean success = true;
                for (int count : updateCounts){
                    System.out.print(count + " ");
                    if (count == 0)
                        success = false;
                }
                return success;

            }


        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
