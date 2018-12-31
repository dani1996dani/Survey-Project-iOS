package Entities;

import org.json.JSONObject;

public class PossibleAnswer {
    int questionId;
    int answerId;
    String answerTitle;
    int votes;

    public PossibleAnswer(int questionId, int answerId, String answerTitle,int votes) {
        this.questionId = questionId;
        this.answerId = answerId;
        this.answerTitle = answerTitle;
        this.votes = votes;
    }

    public int getQuestionId() {
        return questionId;
    }

    public int getAnswerId() {
        return answerId;
    }

    public String getAnswerTitle() {
        return answerTitle;
    }

    public int getVotes() {
        return votes;
    }

    public JSONObject toJSON(){
        JSONObject jsonObject = new JSONObject(this);
        return jsonObject;
    }
}
