package Entities;

import org.json.JSONObject;

public class BaseQuestion {

    private int questionId;
    private User askingUser;
    private String title;
    private long timeAsked;
    private QuestionCategory category;
    private int votes;

    public BaseQuestion(int questionId, User askingUser, String title, long timeAsked, QuestionCategory category, int votes) {
        this.questionId = questionId;
//        this.askerId = askerId;
//        this.askerName = askerName;
        this.askingUser = askingUser;
        this.title = title;
        this.timeAsked = timeAsked;
        this.category = category;
        this.votes = votes;
    }

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

//    public int getAskerId() {
//        return askerId;
//    }
//
//    public void setAskerId(int askerId) {
//        this.askerId = askerId;
//    }


    public User getAskingUser() {
        return askingUser;
    }

    public void setAskingUser(User askingUser) {
        this.askingUser = askingUser;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public long getTimeAsked() {
        return timeAsked;
    }

    public void setTimeAsked(long timeAsked) {
        this.timeAsked = timeAsked;
    }

    public QuestionCategory getCategory() {
        return category;
    }

    public void setCategory(QuestionCategory category) {
        this.category = category;
    }

    public int getVotes() {
        return votes;
    }

    public void setVotes(int votes) {
        this.votes = votes;
    }

//    public String getAskerName() {
//        return askerName;
//    }
//
//    public void setAskerName(String askerName) {
//        this.askerName = askerName;
//    }

    public JSONObject toJSON(){
        return new JSONObject(this);
    }
}
