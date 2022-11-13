-- create table seperately for each coach type
-- train tabele contains seat_no,birth_no,available,coach_type

---Function to release trains

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

-- generate unique PNR for each ticket randomly 
create or replace function generate_pnr() returns int as $$
begin
    return random() * 1000000000;
end;
$$ language plpgsql;

-- booking seats
create or replace function book_seats(train_name VARCHAR, number_of_passengers INT) 
returns integer as $$
-- declare a cursor to store rows from train table
declare
    c1 refcursor;
-- declare a variable to store the number of rows updated
    last_coach int;
    last_seat int;
    concatenated_string varchar;
    available int;
    return_value int;
begin
    return_value := -1;
    open c1  for execute format(
        'select * from %I where available = 1 LIMIT (
        CASE
            WHEN (select Count(*) from (select * from %I where available = 1 for key share skip locked limit $1 ) as t) >= $1 THEN $1 
            ELSE 0
            END
        )  for update skip locked',train_name,train_name)
        USING number_of_passengers;
----------------------NEED to add available =1--------------------------
    if (c1 is not NULL) then
        loop
            fetch c1 into last_coach,last_seat,available;
            exit when not found;
            return_value := last_coach*100 + last_seat;
            -- raise notice 'last_coach: %, last_seat: %', last_coach, last_seat;
            execute  format('update %I set available = 0 where coach_number = $1 and  seat_number = $2',train_name)
            USING last_coach,last_seat;
        end loop;
        -- raise notice 'return value: %', return_value;
        close c1;
        return return_value;
    end if;
    close c1;
    return -1;
end;
$$ language plpgsql;


-- book ticket if train exists and available seats are more than number of passengers using for update
create or replace procedure book_ticket(trainName VARCHAR, number_passenger INT, passenger_names varchar,seats_ac_coach INT,seats_sl_coach INT,INOUT return_variable INT)   
as $$
declare 
    seats_available boolean := false;
    passenger_name varchar;
    train_details varchar[] :=string_to_array(trainName,'_');
    pnr_number int:=random() * 1000000000;
    coach_number int:=0;
    seat_number int:=0;
    seat_info integer;
    temp_seat_info varchar[];
    passenger_name_array varchar[] :=string_to_array(passenger_names,',');
begin
    return_variable :=1;
    if (check_train_exists(trainName)) then
        for i in 1..3 loop
            seat_info := book_seats(trainName, number_passenger);
            -- raise notice 'Your seat: %  where i is : %',seat_info,i;
            if (seat_info <>-1) then
                seats_available := true;
                COMMIT;
                exit;
            end if;
        end loop;

        if (seats_available) then
            coach_number := seat_info/100;
            seat_number := seat_info%100;
            raise notice 'train details: %, ',train_details;
            insert into ticket  values (pnr_number,train_details[2] ::DECIMAL, to_date(train_details[3],'YYYYMMDD'), number_passenger, train_details[4]);
            foreach passenger_name in array passenger_name_array loop
                -- insert into ticket table 
                insert into passenger(passenger_name,PNR,coach_number,seat_number) values (passenger_name, pnr_number, coach_number, seat_number);
                seat_number := seat_number - 1;
                if (seat_number = 0) then
                    coach_number := coach_number - 1;
                    seat_number := seats_ac_coach;
                    if(train_details[2] = 'sl') then
                        seat_number := seats_sl_coach;
                    end if;
                end if;
            end loop;
        else
            raise exception 'No seats available';
            return_variable := 0;
        end if;
    else
        -- ? To check this
        raise exception 'train does not exist';
        return_variable := 0;
    end if;
end;
$$ language plpgsql;


