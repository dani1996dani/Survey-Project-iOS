package Entities;

import java.util.List;

public class NewQuestion {
    String question;
    String categoryName;
    String askerToken;
    List<String> answers;

    public NewQuestion(String question, String categoryName, List<String> answers,String askerToken) {
        this.question = question;
        this.categoryName = categoryName;
        this.answers = answers;
        this.askerToken = askerToken;
    }

    public String getQuestion() {
        return question;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public List<String> getAnswers() {
        return answers;
    }

    public String getAskerToken() {
        return askerToken;
    }
}
