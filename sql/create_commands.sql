
drop table if exists Ticket CASCADE;
drop table if exists Passenger;

CREATE TABLE Ticket (
    PNR varchar ,
    train_id INT NOT NULL,
    date_of_journey DATE NOT NULL,
    number_passenger INT NOT NULL,
    coach_type CHAR(2) NOT NULL,
    PRIMARY KEY (PNR)
);  


-- table for passengers

CREATE TABLE passenger (
    passenger_id SERIAL,
    passenger_name VARCHAR(50) NOT NULL,
    -- passenger_age INT NOT NULL,
    -- passenger_gender CHAR NOT NULL,
    PNR VARCHAR,
    coach_number INT NOT NULL,
    seat_number INT NOT NULL,
    FOREIGN KEY (PNR) references Ticket(PNR) ON delete CASCADE,
    PRIMARY KEY (passenger_id)
);

-- Ticket

