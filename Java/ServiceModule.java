import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.net.ServerSocket;
import java.net.Socket;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

class QueryRunner implements Runnable
{
    String[] berth_type_ac = {"LB","LB","UB","UB","SL","SU"};
    String[] berth_type_sl = {"LB","MB","UB","LB","MB","UB","SL","SU"};

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
     
    public Connection connect() throws IOException
    {
        // Connect to the database postgres
        Properties props = readPropertiesFile("config.properties");
        String url = "jdbc:postgresql://localhost:5432/"+props.getProperty("database");
        String user = props.getProperty("user");
        String password = props.getProperty("password");
        Connection c = null;
        try {
            c = DriverManager.getConnection(url, user, password);
            // System.out.println("Opened database successfully");
        } catch (Exception e) {
            System.err.println("ERROR:"+e.getClass().getName() + ": " + e.getMessage());
        }
        return c;
    }
    
    //  Declare socket for client access
    protected Socket socketConnection;
    
    public QueryRunner(Socket clientSocket)
    {
        this.socketConnection =  clientSocket;
    }
    
    public void run()
    {
      try
      {
          //  Reading data from client
            InputStreamReader inputStream = new InputStreamReader(socketConnection
                                                                  .getInputStream()) ;
            BufferedReader bufferedInput = new BufferedReader(inputStream) ;
            OutputStreamWriter outputStream = new OutputStreamWriter(socketConnection
                                                                     .getOutputStream()) ;
                                                                     BufferedWriter bufferedOutput = new BufferedWriter(outputStream) ;
            PrintWriter printWriter = new PrintWriter(bufferedOutput, true) ;
            String clientCommand = "" ;
            String responseQuery = "" ;
            // String responseQuery = "" ;

            // Read client query from the socket endpoint
            clientCommand = bufferedInput.readLine(); 
            
            // connecting to the database
            Connection c = connect();
            String[] InpArr = null;
            while( ! clientCommand.equals("#"))
            {
                // System.out.println(clientCommand);
                //print clientCommand
                /*******************************************
                 Your DB code goes here
                 ********************************************/
                // connect to the database
                
                InpArr = clientCommand.split(" ");
                Integer number_passengers = Integer.parseInt(InpArr[0]);
                Integer train_id = Integer.parseInt(InpArr[number_passengers+1]);
                String train_date = InpArr[number_passengers+2].replace("-", "");
                String coach_type = InpArr[number_passengers+3].toLowerCase();
                String train_name = coach_type + "_" + train_id.toString() + "_" + train_date;

                String passenger_name="";
                for (int i = 1; i <= number_passengers; i++) {
                    passenger_name+=InpArr[i];
                }
                
                String query_book_ticket=String.format("call book_ticket(\'%s\', %d, \'%s\',18,24,\'1\')", train_name, number_passengers, passenger_name);
                // System.out.println(query_book_ticket);
                
                // printing the query
                // System.out.println("query_book_ticket: " + query_book_ticket);
                try {
                    ResultSet rs = c.createStatement().executeQuery(query_book_ticket);
                    // get the response from the database
                    // ResultSetMetaData rsmd = rs.getMetaData();
                    // System.out.println("values of result set is: "+ rs.getInt("return_variable"));
                    
                    while (rs.next()) {
                        responseQuery = rs.getString("return_variable");
                        // System.out.println(responseQuery);
                    }
                    rs.close();
                    // System.out.println("response: " + response);
                    
                    
                    if( responseQuery.equals("-1")){
                        responseQuery = "Sorry,Train with id: " + train_id.toString() + " is full on date: " + InpArr[number_passengers+2] + " for " + coach_type + " coach type.\n";
                        // System.out.println("exiting -1");
                    }
                    else if(responseQuery.equals("-2")){
                        responseQuery = "Sorry,Train with id: " + train_id.toString() + " is not released on date: " + InpArr[number_passengers+2] + ".\n";
                        // System.out.println("exiting -2");
                    }
                    else{
                        String[] seat_info = responseQuery.split(" ");
                        // print seat_info array 
                        // assert seat_info.length == number_passengers+1;

                        // System.out.println("length seat info: " +seat_info.length);
                        // for (int i = 0; i < seat_info.length; i++) {
                        //     System.out.println("AT index: "+ i + " "+seat_info[i]);
                        // }

                        responseQuery = "Your ticket has been booked for train with id: " + train_id.toString() + " on date: " + InpArr[number_passengers+2] + " for " + coach_type + " coach type with PNR: " +train_id+train_date+seat_info[1]+coach_type + "\n";
                        // System.out.println("enter else");
                        for (int i = 1; i <= number_passengers; i++) {
                            // System.out.println("debug "+ number_passengers + " and i: " +i);
                            Integer seat = Integer.parseInt(seat_info[i]);
                            if(coach_type.equals("ac")){
                                responseQuery += "Passenger :" + InpArr[i]  + " has been allotted coach number: " + seat/100 +" with seat number: "+ seat%100 + " with berth type: "+berth_type_ac[(seat%100-1)%6] +".\n";
                            }
                            else{
                                responseQuery += "Passenger :" + InpArr[i]  + " has been allotted coach number: " + seat/100 +" with seat number: "+ seat%100 + " with berth type: "+berth_type_sl[(seat%100-1)%8] +".\n";
                            }

                        }
                        // System.out.println("exit else");

                    }
                } catch (Exception e) {
                    System.err.println("ERROR:"+e.getClass().getName() + ": " + e.getMessage());
                    System.err.println("CLIENT COMMAND: " + clientCommand);
                    System.err.println("reponse: " + responseQuery);
                    e.printStackTrace();
                }
                printWriter.println(responseQuery);

                // Read next client query
                clientCommand = bufferedInput.readLine(); 
                // System.out.println(clientCommand.charAt(0));
            }
            // close the connection
            try {
                c.close();
            } catch (Exception e) {
                System.err.println("ERROR:"+e.getClass().getName() + ": " + e.getMessage());
            }
            inputStream.close();
            bufferedInput.close();
            outputStream.close();
            bufferedOutput.close();
            printWriter.close();
            socketConnection.close();
        }
        catch(IOException e)
        {
            return;
        }
    }
}

/**
 * Main Class to controll the program flow
 */
public class ServiceModule 
{
    // Server listens to port
    static int serverPort = 7008;
    // Max no of parallel requests the server can process
    static int numServerCores = 50 ;         
    //------------ Main----------------------
    public static void main(String[] args) throws IOException 
    {    
        // Creating a thread pool
        ExecutorService executorService = Executors.newFixedThreadPool(numServerCores);
        
        try (//Creating a server socket to listen for clients
        ServerSocket serverSocket = new ServerSocket(serverPort)) {
            Socket socketConnection = null;
            
            // Always-ON server
            while(true)
            {
                // System.out.println("Listening port : " + serverPort 
                //                     + "\nWaiting for clients...");
                socketConnection = serverSocket.accept();   // Accept a connection from a client
                // System.out.println("Accepted client :" 
                //                     + socketConnection.getRemoteSocketAddress().toString() 
                //                     + "\n");
                //  Create a runnable task
                Runnable runnableTask = new QueryRunner(socketConnection);
                //  Submit task for execution   
                executorService.submit(runnableTask);   
            }
        }
    }
}

