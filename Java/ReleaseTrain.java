import java.io.IOException;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;
import java.util.Scanner;
import java.io.File;


public class ReleaseTrain {

  public static Properties readPropertiesFile(String fileName) throws IOException {
    FileInputStream fis = null;
    Properties prop = null;
    try {
      fis = new FileInputStream(fileName);
      prop = new Properties();
      prop.load(fis);
    } catch(FileNotFoundException fnfe) {
      fnfe.printStackTrace();
    } catch(IOException ioe) {
      ioe.printStackTrace();
    } finally {
      fis.close();
    }
    return prop;
}

  public static Connection connect() throws IOException
  {
      // Connect to the database postgres
      Properties props = readPropertiesFile("config.properties");
      String url = "jdbc:postgresql://localhost:5432/"+props.getProperty("database");
      String user = props.getProperty("user");
      String password = props.getProperty("password");
      Connection c = null;
      try {
          c = DriverManager.getConnection(url, user, password);
          System.out.println("Opened database successfully");
      } catch (Exception e) {
          System.err.println("ERROR:"+e.getClass().getName() + ": " + e.getMessage());
      }
      return c;
  }
  
  public static void  release_trains(String file_name){
    try{
      Connection c = connect();
      Scanner sc = new Scanner(new File(file_name));
      while(sc.hasNextLine()){
        String line = sc.nextLine();
        
        if(line.equals("#")){
          break;
        }
        String[] values = line.split(" ");
        // print the values array
        // for (int i = 0; i < values.length; i++) {
        //   System.out.println("i: "+i+" = "+values[i]);
        // }
        String train_name = "t_" + values[0] + "_" + values[1].replace("-", "");
        String query_release_train=String.format("select release_train(\'%s\', %d, 18,\'%d\',24)", train_name, Integer.parseInt(values[2]), Integer.parseInt(values[4]));
        //print query_relase_train
        System.out.println(query_release_train);
        c.createStatement().execute(query_release_train);
      }
      sc.close();
    }catch(Exception e){
      System.out.println(e);
    }
  }
  public static void main(String[] args) throws IOException{
    Scanner input = new Scanner(System.in);
    System.out.print("Enter name of the file for releasing trains: ");
    String file = input.nextLine();
    release_trains(file);
    input.close();
  }
}
