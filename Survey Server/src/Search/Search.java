package Search;

import Database.DB;
import Entities.QuestionCategory;
import org.apache.commons.text.similarity.LevenshteinDistance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;


public class Search {

    private Search(){

    }
    public static Search instance;

    public static Search getInstance(){
        if (instance == null)
            instance = new Search();
        return instance;
    }



    Set<QuestionCategory> categories = new HashSet<>();

    public  int getDistance(String a,String b){

        int distance = LevenshteinDistance.getDefaultInstance().apply(a.toLowerCase(),b.toLowerCase());
        return distance;
    }

    public  QuestionCategory closestMatch(String searchInput,int threshold){
        QuestionCategory matchedCategory = null;
        int bestDifference = threshold;

        if (categories.isEmpty()){
            fetchCategories();
        }

        for (QuestionCategory category : categories){
            String categoryName = category.getCategoryName();
            int distance = getDistance(searchInput,categoryName);
            if (distance > threshold)
                continue;
            if (distance < bestDifference){
                bestDifference = distance;
                matchedCategory = category;
            }
        }
        return matchedCategory;
    }

    private void fetchCategories(){
        try(Connection connection = DB.getConnection()){
            try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT category_id,category_name FROM survey.question_categorys")){
                try(ResultSet resultSet = preparedStatement.executeQuery()){
                    while (resultSet.next()){
                        String categoryName = resultSet.getString("category_name");
                        int categoryId = resultSet.getInt("category_id");
                        QuestionCategory questionCategory = new QuestionCategory(categoryId,categoryName);
                        categories.add(questionCategory);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


}
