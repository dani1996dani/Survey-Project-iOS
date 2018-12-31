package Servlets;

import Database.UserPersistence;
import Entities.ProfileMetadata;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static Servlets.AuthServlet.UUID_LENGTH;

@WebServlet(name = "ProfileServlet")
public class ProfileServlet extends HttpServlet {

    public static final String PROFILE_METADATA = "profile_metadata";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null || action.isEmpty())
            return;

        switch (action) {
            case PROFILE_METADATA:

                String userToken = request.getParameter("token");
                if (userToken == null || userToken.length() != UUID_LENGTH)
                    return;

                String message = messageForProfileMetadata(userToken);
                response.setContentType("application/json");
                response.getWriter().write(message);

                break;
        }
    }

    private String messageForProfileMetadata(String userToken) {
        ProfileMetadata profileMetadata = UserPersistence.getInstance().getUserProfileMetadata(userToken);
        return profileMetadata.toJSON().toString();
    }
}
