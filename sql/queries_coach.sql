drop table if exists ac_coach;
drop table if exists sl_coach;


CREATE TABLE ac_coach (
  berth_number INT PRIMARY KEY,
  berth_type CHAR(2) NOT NULL
);

CREATE TABLE sl_coach (
  berth_number INT PRIMARY KEY,
  berth_type CHAR(2) NOT NULL
);



INSERT INTO ac_coach VALUES(1,'LB');
INSERT INTO ac_coach VALUES(2,'LB');
INSERT INTO ac_coach VALUES(3,'UB');
INSERT INTO ac_coach VALUES(4,'UB');
INSERT INTO ac_coach VALUES(5,'SL');
INSERT INTO ac_coach VALUES(6,'SU');
INSERT INTO ac_coach VALUES(7,'LB');
INSERT INTO ac_coach VALUES(8,'LB');
INSERT INTO ac_coach VALUES(9,'UB');
INSERT INTO ac_coach VALUES(10,'UB');
INSERT INTO ac_coach VALUES(11,'SL');
INSERT INTO ac_coach VALUES(12,'SU');
INSERT INTO ac_coach VALUES(13,'LB');
INSERT INTO ac_coach VALUES(14,'LB');
INSERT INTO ac_coach VALUES(15,'UB');
INSERT INTO ac_coach VALUES(16,'UB');
INSERT INTO ac_coach VALUES(17,'SL');
INSERT INTO ac_coach VALUES(18,'SU');



INSERT INTO sl_coach VALUES(1,'LB');
INSERT INTO sl_coach VALUES(2,'MB');
INSERT INTO sl_coach VALUES(3,'UB');
INSERT INTO sl_coach VALUES(4,'LB');
INSERT INTO sl_coach VALUES(5,'MB');
INSERT INTO sl_coach VALUES(6,'UB');
INSERT INTO sl_coach VALUES(7,'SL');
INSERT INTO sl_coach VALUES(8,'SU');
INSERT INTO sl_coach VALUES(9,'LB');
INSERT INTO sl_coach VALUES(10,'MB');
INSERT INTO sl_coach VALUES(11,'UB');
INSERT INTO sl_coach VALUES(12,'LB');
INSERT INTO sl_coach VALUES(13,'MB');
INSERT INTO sl_coach VALUES(14,'UB');
INSERT INTO sl_coach VALUES(15,'SL');
INSERT INTO sl_coach VALUES(16,'SU');
INSERT INTO sl_coach VALUES(17,'LB');
INSERT INTO sl_coach VALUES(18,'MB');
INSERT INTO sl_coach VALUES(19,'UB');
INSERT INTO sl_coach VALUES(20,'LB');
INSERT INTO sl_coach VALUES(21,'MB');
INSERT INTO sl_coach VALUES(22,'UB');
INSERT INTO sl_coach VALUES(23,'SL');
INSERT INTO sl_coach VALUES(24,'SU');



