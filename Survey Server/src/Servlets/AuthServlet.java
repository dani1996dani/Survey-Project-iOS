package Servlets;

import Database.DB;
import Database.UserPersistence;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet(name = "Servlets.AuthServlet")
public class AuthServlet extends HttpServlet {

    public static final String ACTION = "action";
    public static final String REGISTER = "register";
    public static final String LOGIN = "login";
    public static final String USERNAME = "username";
    public static final String HASHED_PASSWORD = "hashed_password";
    public static final String ERROR = "Error";
    public static final int SHA256_LENGTH = 64;
    public static final int UUID_LENGTH = 36;
    public static final String USERNAME_TAKEN = "Username Taken";
    public static final String INVALID_CREDENTIALS = "Invalid Credentials";


    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter(ACTION);
        if (action == null || action.isEmpty()) {
            return;
        }

        switch (action) {
            case REGISTER:
                String username = request.getParameter(USERNAME);
                String hashedPassword = request.getParameter(HASHED_PASSWORD);

                if (username == null || hashedPassword == null || hashedPassword.length() != SHA256_LENGTH) {
                    return;
                }
                String registerResult = register(username, hashedPassword);
                response.setContentType("text/plain;");
                response.setCharacterEncoding("UTF-8");

                if (registerResult == null) {
                    registerResult = ERROR;
                }
                response.getWriter().write(registerResult);
                break;

            case LOGIN:
                username = request.getParameter(USERNAME);
                hashedPassword = request.getParameter(HASHED_PASSWORD);

                if (username == null || hashedPassword == null || hashedPassword.length() != SHA256_LENGTH) {
                    return;
                }
                String savedToken = login(username, hashedPassword);
                response.setContentType("text/plain;");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(savedToken != null ? savedToken : INVALID_CREDENTIALS);
                break;
        }

    }

    private String register(String username, String receivedPassword) {
        String salt = generateSalt();
        String saltedPassword = receivedPassword + salt;
        String hashedPassword = sha256(saltedPassword);
        String newUserToken = generateRandomUUID();

        try (Connection connection = DB.getConnection()) {

            boolean isUsernameAvailable = UserPersistence.getInstance().isUsernameAvailable(connection, username);

            if (!isUsernameAvailable)
                return USERNAME_TAKEN;

            try (PreparedStatement preparedStatement = connection.prepareStatement("INSERT INTO survey.users (user_name,password_hash,password_salt,user_token) VALUES(?,?,?,?)")) {
                preparedStatement.setString(1, username);
                preparedStatement.setString(2, hashedPassword);
                preparedStatement.setString(3, salt);
                preparedStatement.setString(4, newUserToken);

                int rowsAffected = preparedStatement.executeUpdate();
                return rowsAffected == 1 ? newUserToken : ERROR;

            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ERROR;
    }

    private String login(String username, String receivedPassword) {
        String savedSalt = "";
        String savedPassword = "";
        String savedToken = "";

        try (Connection connection = DB.getConnection()) {
            try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM survey.users WHERE user_name = ?")) {
                preparedStatement.setString(1, username);
                try (ResultSet resultSet = preparedStatement.executeQuery()) {
                    if (resultSet.next()) {
                        savedSalt = resultSet.getString("password_salt");
                        savedPassword = resultSet.getString("password_hash");
                        savedToken = resultSet.getString("user_token");
                    } else
                        return null;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        String passwordToTest = sha256(receivedPassword + savedSalt);
        boolean correctPassword = passwordToTest.equals(savedPassword);

        if (correctPassword)
            return savedToken;
        else
            return null;
    }

    private String generateSalt() {
        return generateRandomUUID();
    }

    private String generateRandomUUID() {
        return UUID.randomUUID().toString();
    }

    private String sha256(String originalString) {
        MessageDigest digest = null;
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return "";
        }
        byte[] encodedhash = digest.digest(
                originalString.getBytes(StandardCharsets.UTF_8));
        StringBuffer hexString = new StringBuffer();
        for (int i = 0; i < encodedhash.length; i++) {
            String hex = Integer.toHexString(0xff & encodedhash[i]);
            if (hex.length() == 1)
                hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    }


}
