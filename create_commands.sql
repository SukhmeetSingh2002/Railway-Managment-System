-- table for passengers

CREATE TABLE passenger (
    passenger_id INT NOT NULL AUTO_INCREMENT,
    passenger_name VARCHAR(50) NOT NULL,
    passenger_age INT NOT NULL,
    passenger_gender CHAR NOT NULL,
    PNR INT NOT NULL,
    seat_no INT NOT NULL,
    coach_type INT NOT NULL,
    FOREIGN KEY (PNR) references Ticket(PNR),
    PRIMARY KEY (passenger_id)
);

-- Ticket

CREATE TABLE Ticket (
    PNR SERIAL ,
    train_id INT NOT NULL,
    date_of_journey DATE NOT NULL,
    number_passenger INT NOT NULL,
    coach_type INT NOT NULL,
    PRIMARY KEY (PNR),
);  