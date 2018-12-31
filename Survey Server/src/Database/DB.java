package Database;

import org.apache.commons.dbcp2.BasicDataSource;

import java.sql.*;
import java.util.Properties;

public class DB {

    private static BasicDataSource ds = new BasicDataSource();

    static {

//        try {
//            Class.forName("org.postgresql.Driver");
//            System.out.println("loaded");
//        } catch (ClassNotFoundException e) {
//            e.printStackTrace();
//        }
        ds.setDriverClassName("org.postgresql.Driver");
        ds.setUrl("jdbc:postgresql://ec2-54-228-197-249.eu-west-1.compute.amazonaws.com:5432/d784maflcrvkau");
        ds.setUsername("vgxnvgfekibwmq");
        ds.setPassword("58c22827dafaa1dd7cc6abaedee67c809815612139e83cf8cb6a5e2c4bf40afc");
        ds.setMinIdle(5);
        ds.setMaxIdle(10);
        ds.setMaxOpenPreparedStatements(100);
        System.out.println("Init of commons ds pool");


    }



    public static Connection getConnection() throws SQLException {

//        String url = "jdbc:postgresql://ec2-54-228-197-249.eu-west-1.compute.amazonaws.com:5432/d784maflcrvkau";
//        Properties props = new Properties();
//        props.setProperty("user","vgxnvgfekibwmq");
//        props.setProperty("password","58c22827dafaa1dd7cc6abaedee67c809815612139e83cf8cb6a5e2c4bf40afc");
////        props.setProperty("ssl","true");
//
//        Connection conn = DriverManager.getConnection(url, props);
//        return conn;
        return ds.getConnection();
    }

}
