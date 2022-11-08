-- create table seperately for each coach type


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
