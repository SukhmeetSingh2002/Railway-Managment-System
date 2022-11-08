-- create table seperately for each coach type
-- train tabele contains seat_no,birth_no,available,coach_type


CREATE OR REPLACE FUNCTION add_train(train_name  VARCHAR, ac_coaches INT, seats_ac_coach INT, sl_coaches INT, seats_sl_coach INT) 
RETURNS VOID AS $$
DECLARE
	traniname_ac VARCHAR := train_name || '_AC';
	traniname_sl VARCHAR := train_name || '_SL';
	total_ac_seats INTEGER := ac_coaches * seats_ac_coach;
	total_sl_seats INTEGER := sl_coaches * seats_sl_coach;
BEGIN 

	execute 'CREATE TABLE '|| traniname_ac ||'(
		coach_number INT,
		seat_number INT,
		available INT,
		PRIMARY KEY(coach_number, seat_number)
	)' ;

	execute 'CREATE TABLE '|| traniname_sl ||'(
		coach_number INT,
		seat_number INT,
		available INT,
		PRIMARY KEY(coach_number, seat_number)
	)' ;

	FOR seat in 0..(total_ac_seats-1) LOOP
		execute 'INSERT INTO '|| traniname_ac ||' VALUES('|| seat/seats_ac_coach +1 ||','|| mod(seat,seats_ac_coach)+1 ||',1)';
	END LOOP;

	FOR seat in 0..(total_sl_seats-1) LOOP
		execute 'INSERT INTO '|| traniname_sl ||' VALUES('|| seat/seats_sl_coach +1 ||','|| mod(seat,seats_sl_coach)+1 ||',1)';
	END LOOP;
END; 
$$ language plpgsql;



-- check if train exists using information_schema 
create or replace function check_train_exists(trainName VARCHAR(10)) returns boolean as $$
begin
    return exists(select table_name from information_schema.tables where table_name = trainName);
end;
$$ language plpgsql;


-- booking seats
create or replace function book_seats(train_name VARCHAR, number_of_passengers INT) returns boolean as $$
-- declare a cursor to store rows from train table

declare
    c1 CURSOR for select * from train_name
    LIMIT (
        CASE
            WHEN (select Count(*) from (select * from train_name for key share skip locked limit number_of_passengers) as t) >= number_of_passengers THEN number_of_passengers
            else 0
            end
        ) for update;
-- declare a variable to store the number of rows updated
last_coach int;
last_seat int;
concatenated_string varchar;
    
begin
    if (select count(*) from c1) > 0 then
        for row in c1 loop
            update train_name set available = 0 where seat_number = row.seat_number;
            last_coach = row.coach_number;
            last_seat = row.seat_number;
        end loop;
        concatenated_string =  last_coach ||' '||  last_seat;
        return concatenated_string;
    end if;
return '0';
end;
$$ language plpgsql;

-- book ticket if train exists and available seats are more than number of passengers using for update
create or replace procedure book_ticket(trainName VARCHAR, number_passenger INT, passenger_names varchar,seats_ac_coach INT,seats_sl_coach INT)   
as $$
declare 
    seats_available boolean;
    passenger_name varchar;
    train_details varchar[] :=string_to_array(trainName,'_');
    pnr_number int:=random() * 1000000000;
    coach_number int:=0;
    seat_number int:=0;
    seat_info varchar;
begin
    if (check_train_exists(trainName)) then
        for i in 1..3 loop
            seat_info = book_seats(trainName, number_passenger);
            if (seat_info<>'0') then
                commit;
                seats_available := true;
                exit;
            end if;
        end loop;
        
        coach_number := string_to_array(seat_info,' ')[0]::int;
        seat_number := string_to_array(seat_info,' ')[1]::int;

        if (seats_available) then
            insert into ticket  values (pnr_number,train_details[0] ::DECIMAL, to_date(train_details[1],'YYYYMMDD'), number_passenger, train_details[2]);
            for passenger_name in array select * from string_to_array(passenger_names, ' ') loop
                -- insert into ticket table 
                insert into passenger values (passenger_name, pnr_number, coach_number, seat_number);
                seat_number := seat_number - 1;
                if (seat_number = 0) then
                    coach_number := coach_number - 1;
                    seat_number := seats_ac_coach;
                    if(train_details[2] = 'SL') then
                        seat_number := seats_sl_coach;
                    end if;
                end if;
            end loop;
        end if;
    else
        raise exception 'train does not exist';
    end if;
end;
$$ language plpgsql;

-- generate unique PNR for each ticket randomly 
create or replace function generate_pnr() returns int as $$
begin
    return random() * 1000000000;
end;
$$ language plpgsql;
