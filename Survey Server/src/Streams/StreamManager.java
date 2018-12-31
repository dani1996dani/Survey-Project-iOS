package Streams;

import java.io.IOException;
import java.io.InputStream;

public class StreamManager {

    public static String decodeInputStream(InputStream inputStream) throws IOException {
        int actuallyRead = 0;
        byte[] buffer = new byte[1024];
        String result = "";
        while ((actuallyRead = inputStream.read(buffer)) != -1) {
            result += new String(buffer, 0, actuallyRead);
        }
        return result;
    }

}
