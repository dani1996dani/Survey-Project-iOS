package Entities;

import org.json.JSONObject;

import java.util.List;

public class Question extends BaseQuestion {

    private List<PossibleAnswer> possibleAnswerList;
    private int answerVotedId;

    public Question(int questionId, User askingUser, String title, long timeAsked, QuestionCategory category, int votes,List<PossibleAnswer> possibleAnswers,int answerVotedId) {
        super(questionId, askingUser, title, timeAsked, category, votes);
        this.possibleAnswerList = possibleAnswers;
        this.answerVotedId = answerVotedId;
    }

    public List<PossibleAnswer> getPossibleAnswerList() {
        return possibleAnswerList;
    }

    public int getAnswerVotedId() {
        return answerVotedId;
    }

    @Override
    public JSONObject toJSON() {
        return new JSONObject(this);
    }
}
