package Servlets;

import Database.QuestionCategoryPersistence;
import Database.QuestionPersistence;
import Entities.BaseQuestion;
import Entities.NewQuestion;
import Entities.Question;

import Streams.StreamManager;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static Servlets.AuthServlet.ACTION;
import static Servlets.AuthServlet.UUID_LENGTH;

@WebServlet(name = "QuestionServlet")
public class QuestionServlet extends HttpServlet {

    public static final String GET_QUESTIONS = "get_questions";
    public static final String FILTER_BY = "filter_by";
    public static final String GET_SPECIFIC_QUESTIION = "get_specific_question";
    public static final String GET_ALL_CATEGORIES = "get_all_categories";
    public static final String GET_USER_QUESTIONS = "get_user_questions";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String messageFromClient = StreamManager.decodeInputStream(request.getInputStream());
        System.out.println(messageFromClient);
        boolean success = addNewQuestion(messageFromClient);
        response.getWriter().write(success ? "Success" : "Error");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter(ACTION);
        if (action == null || action.isEmpty()) {
            return;
        }
        switch (action) {
            case GET_QUESTIONS:
                String filterBy = request.getParameter(FILTER_BY);
                if (filterBy == null || filterBy.isEmpty()) {
                    List<BaseQuestion> baseQuestionList = QuestionPersistence.getInstance().getAllQuestions();
                    JSONArray questionsArray = new JSONArray();
                    for (BaseQuestion baseQuestion : baseQuestionList) {
                        JSONObject jsonObject = baseQuestion.toJSON();
                        questionsArray.put(jsonObject);
                    }
                    response.setContentType("application/json");
                    response.getWriter().write(questionsArray.toString());

                } else {
                    List<BaseQuestion> baseQuestionList = QuestionPersistence.getInstance().getFilteredQuestions(filterBy);
                    JSONArray questionsArray = new JSONArray();
                    for (BaseQuestion baseQuestion : baseQuestionList) {
                        JSONObject jsonObject = baseQuestion.toJSON();
                        questionsArray.put(jsonObject);
                    }
                    response.setContentType("application/json");
                    response.getWriter().write(questionsArray.toString());

                }
                break;
            case GET_SPECIFIC_QUESTIION:
                String qId = request.getParameter("question_id");
                if (qId == null || qId.isEmpty())
                    return;

                int questionId = 0;
                try {
                    questionId = Integer.valueOf(qId);
                } catch (Exception e) {
                    return;
                }

                String userToken = request.getParameter("token");
                if (userToken == null || userToken.length() != UUID_LENGTH) {
                    return;
                }


                Question question = QuestionPersistence.getInstance().getQuestionById(questionId, userToken);
                response.setContentType("application/json");
                String message  = question.toJSON().toString();
                response.getWriter().write(message);
                break;

            case GET_ALL_CATEGORIES:
                message = messageOfAllCategories();
                response.setContentType("application/json");
                response.getWriter().write(message);

                break;

            case GET_USER_QUESTIONS:
                userToken = request.getParameter("token");
                if (userToken == null || userToken.length() != UUID_LENGTH) {
                    return;
                }

                message = messageForUserQuestions(userToken);
                response.setContentType("application/json");
                response.getWriter().write(message);
                break;

        }

    }

    private String messageForUserQuestions(String userToken) {
        List<BaseQuestion> userQuestions = QuestionPersistence.getInstance().getUserQuestions(userToken);
        JSONArray jsonArray = new JSONArray(userQuestions);
        return jsonArray.toString();
    }

    private boolean addNewQuestion(String messageFromClient) {
        JSONObject jsonObject = new JSONObject(messageFromClient);
        String question = jsonObject.getString("question");
        String categoryName = jsonObject.getString("categoryName");
        List<String> answers = new ArrayList<>();
        JSONArray jsonArray = jsonObject.getJSONArray("answers");
        for (int i = 0; i < jsonArray.length(); i++) {
            String answer = String.valueOf(jsonArray.get(i));
            answers.add(answer);
        }

        String askerToken = jsonObject.getString("askerToken");

        NewQuestion newQuestion = new NewQuestion(question, categoryName, answers, askerToken);
        boolean success = QuestionPersistence.getInstance().addNewQuestion(newQuestion);
        return success;
    }

    private String messageOfAllCategories() {
        JSONObject jsonObject = new JSONObject();
        Map<Integer, String> categoryMap = QuestionCategoryPersistence.getInstance().getAllCategories();
        Set<Integer> keys = categoryMap.keySet();
        for (int key : keys) {
            jsonObject.put(String.valueOf(key), categoryMap.get(key));
        }
        return jsonObject.toString();
    }


    private String getCategoryName(Connection connection, int categoryId) throws SQLException {
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT category_name FROM survey.question_categorys WHERE category_id = ?")) {
            preparedStatement.setInt(1, categoryId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getString("category_name");
                }
            }
        }
        return "";
    }

//    private int getVotesForQuestion(Connection connection, int questionId) throws SQLException{
//        int sumOfVotes = 0;
//
//        try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT votes FROM survey.question_answers WHERE question_id = ?")){
//            preparedStatement.setInt(1,questionId);
//            try(ResultSet resultSet = preparedStatement.executeQuery()){
//                while (resultSet.next()){
//                    sumOfVotes += resultSet.getInt("votes");
//                }
//            }
//        }
//        return sumOfVotes;
//    }
}

