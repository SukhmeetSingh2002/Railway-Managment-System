# Railway-Managment-System

[rel_train]: https://github.com/SukhmeetSingh2002/Railway-Managment-System/blob/master/Java/ReleaseTrain.java
[train_sch]: https://github.com/SukhmeetSingh2002/Railway-Managment-System/blob/master/Java/Trainschedule.txt
[Server]: https://github.com/SukhmeetSingh2002/Railway-Managment-System/blob/master/Java/ServiceModule.java
[client]: https://github.com/SukhmeetSingh2002/Railway-Managment-System/blob/master/Java/client.java

[locking]: https://www.postgresql.org/docs/current/explicit-locking.html
[jdbc]: https://jdbc.postgresql.org/download/postgresql-42.5.0.jar

## Overview :octocat:
Railway reservation system which handles concurrent requests for booking tickets in postgress. It uses [explicit locking][locking]
to handle parallel requests.

## Setup before running
- Make a `config.properties` file in the `Java/` directory and store the name of the `database`,`user` and its `password` as following
  ``` .properties
  database=XXXXXX
  user=XXXXXX
  password=XXXXXX
  ```
- Make a database in postgresql  then run `setup.sql` (change the paths before running)
  ``` sql
  \i setup.sql
  ```
- Download *[JDBC driver][jdbc]* and keep it in `Java/` directory
- Make two directories `Input/` and `Output/` and keep in `input files` in `Input/` folder
- Make a `Trainschedule.txt` file in `Java/` folder

## How to Run :zap: 
- First we need to add all the train by running [ReleaseTrain ][rel_Train] and Train schedule resides in [Trainschedule ][train_sch] `or` specify the path of the file
  ``` bash
  javac ReleaseTrain.java && java ReleaseTrain
  ```

- Then, run [Service Module][Server] which will keep listening for connections from the client and book tickets using multithreading.
  ``` bash
  javac ServiceModule.java && java ServiceModule
  ```

- Now, open a new terminal and run the [Client][client] which will send parallel requests to Service Module. This will read the input files present in `Input/` directory and give the output in `Output/` directory
  ``` bash
  javac *.java && java client
  ``` 

  ### Below are all the commands used above
  > `&` is added so that the Service module runs in background (*no need to open a new terminal :v:*)

    ``` bash
    javac ReleaseTrain.java && java ReleaseTrain
    javac ServiceModule.java && java ServiceModule &
    javac *.java && java client

    ```

## Contributors  
  <b>Under the guidance of Dr. Vishwanath Gunturi : </b><br>
  | **Name**      | **Entry Number** | 
  | :---        |    :----:   |  
  | Sukhmeet Singh     | 2020CSB1129      | 
  | Vishnusai Janjanam   | 2020CSB1142        | 
