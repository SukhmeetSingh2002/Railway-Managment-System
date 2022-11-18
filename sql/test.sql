

SELECT *
from passenger p1, passenger p2 
where p1.passenger_id <> p2.passenger_id AND
p1.coach_number = p2.coach_number and 
p1.seat_number = p2.seat_number AND
((p1.pnr LIKE '465220221102%ac'  AND
p2.pnr LIKE '465220221102%ac') OR
(p1.pnr LIKE '465220221102%sl'  AND
p2.pnr LIKE '465220221102%sl') OR
(p1.pnr LIKE '2251720221102%ac'  AND
p2.pnr LIKE '2251720221102%ac') OR
(p1.pnr LIKE '2251720221102%sl'  AND
p2.pnr LIKE '2251720221102%sl'));


-- drop table t_22517_20221101_ac,t_22517_20221101_sl,t_4652_20221101_ac,t_4652_20221101_sl;
-- drop table passenger,ticket;