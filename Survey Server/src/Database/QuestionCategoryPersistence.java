package Database;

import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class QuestionCategoryPersistence {

    private static QuestionCategoryPersistence instance;

    private QuestionCategoryPersistence() {
    }

    public static QuestionCategoryPersistence getInstance() {
        if (instance == null)
            instance = new QuestionCategoryPersistence();
        return instance;
    }

    public Map<Integer, String> getAllCategories() {
        Map<Integer, String> categoryMap = new HashMap<>();

        try (Connection connection = DB.getConnection()) {
            try (PreparedStatement prepearedStatement = connection.prepareStatement("SELECT * FROM survey.question_categorys")) {
                try (ResultSet resultSet = prepearedStatement.executeQuery()) {
                    while (resultSet.next()) {
                        int categoryId = resultSet.getInt("category_id");
                        String categoryName = resultSet.getString("category_name");
                        categoryMap.put(categoryId, categoryName);
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categoryMap;
    }

    public Map<Integer, String> getAllCategories(Connection connection) {
        Map<Integer, String> categoryMap = new HashMap<>();

        try (PreparedStatement prepearedStatement = connection.prepareStatement("SELECT * FROM survey.question_categorys")) {
            try (ResultSet resultSet = prepearedStatement.executeQuery()) {
                while (resultSet.next()) {
                    int categoryId = resultSet.getInt("category_id");
                    String categoryName = resultSet.getString("category_name");
                    categoryMap.put(categoryId, categoryName);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categoryMap;
    }

    /**
     * @param connection   an open connection to the database.
     * @param categoryName The category name which category id is desired.
     * @return Returns a valid category id, or -1 if no such category name was found.
     * @throws SQLException
     */
    public int getCategoryIdByName(Connection connection, String categoryName) throws SQLException {
        int categoryId = -1;
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT category_id FROM survey.question_categorys WHERE category_name = ?")) {
            preparedStatement.setString(1, categoryName);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    categoryId = resultSet.getInt("category_id");
                }
            }
        }
        return categoryId;
    }


}
