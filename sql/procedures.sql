


-- create table seperately for each coach type
-- train tabele contains seat_no,birth_no,available,coach_type

---Function to release trains

CREATE OR REPLACE FUNCTION release_train(trainName  VARCHAR, ac_coaches INT, seats_ac_coach INT, sl_coaches INT, seats_sl_coach INT) 
RETURNS VOID AS $$
DECLARE
	traniname_ac VARCHAR := 'ac_' || trainName ;
	traniname_sl VARCHAR := 'sl_' || trainName  ;
	total_ac_seats INTEGER := ac_coaches * seats_ac_coach;
	total_sl_seats INTEGER := sl_coaches * seats_sl_coach;
BEGIN 
------------------------- For testing begin-------------------
execute 'Drop table if exists '|| traniname_ac ;
execute 'Drop table if exists '|| traniname_sl;

------------------------- For testing end-------------------

	execute 'CREATE TABLE '|| traniname_ac ||' (
		coach_number INT,
		seat_number INT,
		available INT,
		PRIMARY KEY(coach_number, seat_number)
	)' ;

	execute 'CREATE TABLE '|| traniname_sl ||' (
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
DECLARE
    -- train_exists boolean;
begin
    return exists(select table_name from information_schema.tables where table_name = trainName);
    -- execute format('exists(select table_name from information_schema.tables where table_name = %I)',trainName)
    -- Into train_exists;
    -- return train_exists;
end;
$$ language plpgsql;

-- generate unique PNR for each ticket randomly 
-- create or replace function generate_pnr() returns int as $$
-- begin
--     return random() * 1000000000;
-- end;
-- $$ language plpgsql;

-- booking seats
create or replace function book_seats(trainName VARCHAR, number_passenger INT, passenger_names varchar) 
returns text as $$
-- declare a cursor to store rows from train table
declare
    c1 refcursor;
    -- c2 refcursor;
    coach int;
    seat int;
    available int;
    concatenated_string text := 't';
    train_details varchar[] :=string_to_array(trainName,'_');
    passenger_name_array varchar[] :=string_to_array(passenger_names,',');
    pnr_number varchar;
    idx int:=1;
    -- seat_type char(2);
    -- seat_type varchar;
    -- coach_name varchar;
    indicator int :=0;
    train_date DATE;
begin

    open c1  for execute format(
        'select * from %I where available = 1 
        for update skip locked
        LIMIT (
        CASE
            WHEN (select Count(*) from (
                select * from %I where available = 1 
                for update  skip locked
                limit $1 ) as temp) >= $1 
                THEN $1 
            ELSE 0
            END
        )',trainName,trainName)
        USING number_passenger;
----------------------NEED to add available =1--------------------------
        -- raise notice 'concatenated_string: %', concatenated_string;  
        -- raise notice 'passenger_name_array: %', passenger_name_array[1];
    -- concatenated_string := concatenated_string || number_passenger;
    train_date := to_date(train_details[3],'YYYYMMDD');
    -- coach_name := train_details[1] || '_coach';
    -- concatenated_string :="";
    -- update train set available = 0 where train_name = trainName and train_date = train_date curent in CURSOR
    loop
        fetch c1 into coach,seat,available;
        exit when not found;
        indicator :=1;
        if idx = 1 then
            pnr_number :=train_details[2] || train_details[3]|| coach*100 + seat ||train_details[1];
            insert into ticket  values (pnr_number,train_details[2] ::DECIMAL, train_date, number_passenger, train_details[1]);
            -- concatenated_string :=pnr;
            -- concatenated_string := 'Ticket booked successfully for train id: '||  train_details[2] || ', on date: ' || train_date || ' for ' || train_details[1]|| ' coach type. PNR number is: ' || pnr_number || E' and the passengers are:\n';
            --     ;
        end if;
        -- raise notice 'coach: %, seat: %', coach, seat;
        -- raise notice 'trainName: %', trainName;
        execute  format('update ' || trainName || ' set available = 0 where coach_number = $1 and  seat_number = $2')
        USING coach,seat,number_passenger;
        
        -- execute format('select berth_type from ' || coach_name || ' where berth_number = $1')
        -- using seat
        -- into seat_type;

        -- raise notice 'passenger_name: %, coach: %, seat: %, seat_type: %', passenger_name_array[idx], coach, seat, seat_type;


        insert into passenger(passenger_name,PNR,coach_number,seat_number) values (passenger_name_array[idx],pnr_number,coach,seat);
        -- raise notice 'coach: %, seat: %', coach, seat;
        concatenated_string := concatenated_string || ' ' || coach*100 + seat;
        -- raise notice 'concatenated_string: %', concatenated_string;
        idx := idx + 1;
    end loop;
    -- raise notice 'return value: %', return_value;
    close c1;
    IF indicator = 0 then
            concatenated_string := '-1';
        -- concatenated_string := E'Train with id: ' || train_details[2] || E' is full on date: ' || train_date || E' for ' || train_details[1] || E' coach type.\n';
    else 
    -- concatenated_string := concatenated_string || ' ' || idx;
    END IF;
        -- raise notice 'concatenated_string : %', concatenated_string;
    return concatenated_string;
end;
$$ language plpgsql;


-- book ticket if train exists and available seats are more than number of passengers using for update
create or replace procedure book_ticket(trainName VARCHAR, number_passenger INT, passenger_names varchar,seats_ac_coach INT,seats_sl_coach INT,INOUT return_variable text)   
as $$
declare 
    train_details varchar[] :=string_to_array(trainName,'_');
    temp int;
begin
            -- SET Transaction Isolation Level SERIALIZABLE;
    if (check_train_exists(trainName)) then
        for i in 1..3 loop
            return_variable := book_seats(trainName, number_passenger,passenger_names);
            -- raise return_variable;
            -- raise notice 'return_variable: %', return_variable;
            if (return_variable <>'-1') then
                COMMIT;
                exit;
            ELSE
                execute format('select count(*) from (select available from '|| trainName|| ' where available =1 for key share skip locked) as t1')
                into temp;
                if temp < number_passenger THEN
                    COMMIT;
                    exit;
                END IF;
                ROLLBACK;
            end if;
        end loop;
    else
        -- ? To check this
        -- raise exception 'train does not exist';
        return_variable :='-2';
        -- return_variable := 'Train with id: ' || train_details[2] || ' is not released on date: ' || to_date(train_details[3],'YYYYMMDD') || E'. \n';
        COMMIT;
    end if;
    COMMIT;
end;
$$ language plpgsql;


