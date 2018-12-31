package Servlets;

import Database.DB;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;



public class TestServlet extends javax.servlet.http.HttpServlet {
    protected void doPost(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws javax.servlet.ServletException, IOException {

    }

    protected void doGet(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws javax.servlet.ServletException, IOException {
        print();
    }

    private void print(){
        try(Connection connection = DB.getConnection()){
            try(PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM survey.users")){
                try(ResultSet resultSet = preparedStatement.executeQuery()){
                    while (resultSet.next()){
                        System.out.println(resultSet.getString(2));
                        System.out.println(resultSet.getString(3));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
