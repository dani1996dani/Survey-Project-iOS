package WebSocket;

import javax.websocket.Session;
import java.util.*;

public class SessionManager {

    public static SessionManager instance;

    private Map<Integer, Set<Session>> sessionMap = new HashMap<>();


    private SessionManager() {

    }

    public static SessionManager getInstance() {
        if (instance == null)
            instance = new SessionManager();
        return instance;
    }

    public Set<Session> getSessionsByQuestionId(int questionId) {
        Set<Session> sessions = sessionMap.get(questionId);
        if (sessions == null)
            sessions = new HashSet<>();
        return sessions;
    }

    public void registerSessionByQuestionId(int questionId, Session session) {
        Set<Session> sessions = sessionMap.get(questionId);
        if (sessions == null)
            sessions = new HashSet<>();
        sessions.add(session);
        sessionMap.put(questionId, sessions);
    }

    public void removeSessionByQuestionId(int questionId, Session session) {
        Set<Session> sessions = sessionMap.get(questionId);
        if (sessions == null)
            return;
        sessions.remove(session);
    }

    /**
     * Use this method only when a question id is not available (onError for example). This function runs in O(n) and therefore is not prefered.
     *
     * @param session The session to find and remove in the entire session map.
     */
    public void removeSession(Session session) {
        Set<Integer> keys = sessionMap.keySet();
        for (Integer key : keys) {
            Set<Session> sessionSet = sessionMap.get(key);
            if (sessionSet.contains(session)) {
                sessionSet.remove(session);
                System.out.println("Removed session without qId");
                return;
            }

        }

    }

}
