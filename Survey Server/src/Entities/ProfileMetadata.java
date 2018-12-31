package Entities;

import org.json.JSONObject;

public class ProfileMetadata {

    private int voteAmount;
    private int questionAmount;
    private User user;

    public ProfileMetadata(int voteAmount, int questionAmount,User user) {
        this.voteAmount = voteAmount;
        this.questionAmount = questionAmount;
        this.user = user;
    }

    public int getVoteAmount() {
        return voteAmount;
    }

    public int getQuestionAmount() {
        return questionAmount;
    }

    public void setVoteAmount(int voteAmount) {
        this.voteAmount = voteAmount;
    }

    public void setQuestionAmount(int questionAmount) {
        this.questionAmount = questionAmount;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public JSONObject toJSON(){
        return new JSONObject(this);
    }
}
