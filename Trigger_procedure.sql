-- trigger before insert in Train language postgresql

CREATE OR REPLACE FUNCTION CHECK_TRAIN() RETURNS TRIGGER 
AS 
	$$ begin if (new.total_ac_coaches < 0) then raise exception 'total ac coaches cannot be negative';
	end if;
	if (new.total_non_sl_coaches < 0) then raise exception 'total non sl coaches cannot be negative';
	end if;
	if (new.available_ac_coaches < 0) then raise exception 'available ac coaches cannot be negative';
	end if;
	if (new.available_sl_coaches < 0) then raise exception 'available sl coaches cannot be negative';
	end if;
	if (
	    new.available_ac_coaches > new.total_ac_coaches
	) then raise exception 'available ac coaches cannot be more than total ac coaches';
	end if;
	if (
	    new.available_sl_coaches > new.total_non_sl_coaches
	) then raise exception 'available sl coaches cannot be more than total sl coaches';
	end if;
	return new;
END; 

$$ language plpgsql;

CREATE TRIGGER CHECK_TRAIN BEFORE INSERT OR UPDATE 
ON "TRAIN" FOR EACH ROW EXECUTE PROCEDURE CHECK_TRAIN
() ; -- PROCEDURE TO UPDATE AVAILABLE COACHES LANGUAGE POSTGRESQL 
CREATE OR REPLACE FUNCTION UPDATE_COACHES(TRAINNAME 
VARCHAR(10)) RETURNS VOID AS 
	$$ begin
	update Train
	set
		available_ac_coaches = available_ac_coaches - ac_coaches,
		available_sl_coaches = available_sl_coaches - sl_coaches
	where
		train_id = trainId
		and date_of_journey = dateofjourney;
END; 

$$ language plpgsql;

-- create table seperately for each coach type

CREATE OR REPLACE FUNCTION add_train(train_name  VARCHAR(10), AC INT, SL INT) 
RETURNS VOID AS $$
DECLARE
	traniname_ac = train_name || 'AC'
	traniname_sl = train_name || 'SL'

BEGIN 

	execute 'CREATE TABLE '|| traniname_ac ||'(
		coach_number INT NOT NULL,
		seat_number INT NOT NULL,
		available INT NOT NULL,
	)' ;

	execute 'CREATE TABLE '|| traniname_sl ||'(
		coach_number INT NOT NULL,
		seat_number INT NOT NULL,
		available INT NOT NULL,
	)' ;


END; 
$$ language plpgsql;

