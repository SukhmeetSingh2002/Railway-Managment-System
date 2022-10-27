-- trigger before insert in Train language postgresql


create or replace function check_train() returns trigger as $$
begin
    if (new.total_ac_coaches < 0) then
        raise exception 'total ac coaches cannot be negative';
    end if;
    if (new.total_non_sl_coaches < 0) then
        raise exception 'total non sl coaches cannot be negative';
    end if;
    if (new.available_ac_coaches < 0) then
        raise exception 'available ac coaches cannot be negative';
    end if;
    if (new.available_sl_coaches < 0) then
        raise exception 'available sl coaches cannot be negative';
    end if;
    if (new.available_ac_coaches > new.total_ac_coaches) then
        raise exception 'available ac coaches cannot be more than total ac coaches';
    end if;
    if (new.available_sl_coaches > new.total_non_sl_coaches) then
        raise exception 'available sl coaches cannot be more than total sl coaches';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger check_train before insert or update on "Train" for each row execute procedure check_train();

-- procedure to update available coaches language postgresql
create or replace function update_coaches(trainName VARCHAR(10)) returns void as $$
begin
    update Train set available_ac_coaches = available_ac_coaches - ac_coaches, available_sl_coaches = available_sl_coaches - sl_coaches where train_id = trainId and date_of_journey = dateofjourney;
end;
$$ language plpgsql;
