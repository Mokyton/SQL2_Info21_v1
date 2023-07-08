DROP SCHEMA IF EXISTS main CASCADE ;

CREATE SCHEMA IF NOT EXISTS main;

CREATE TABLE IF NOT EXISTS main.Peers (
    Nick_Name text PRIMARY KEY,
    Birth_Day date
);

CREATE TABLE IF NOT EXISTS main.Friends (
    id serial PRIMARY KEY,
    peer_1 text not null,
    peer_2 text not null,
    FOREIGN KEY (peer_1) REFERENCES main.Peers(nick_name),
    FOREIGN KEY (peer_2) REFERENCES main.Peers(nick_name)
);

CREATE TABLE IF NOT EXISTS main.Recommendations (
    id serial PRIMARY KEY,
    peer text not null,
    recommended_peer text not null,
    FOREIGN KEY (peer) REFERENCES main.Peers(nick_name),
    FOREIGN KEY (recommended_peer) REFERENCES main.Peers(nick_name)
);

CREATE TABLE IF NOT EXISTS main.Time_Tracking (
    id serial PRIMARY KEY,
    peer text not null,
    "date" date default current_date not null,
    time time default current_time(0) not null,
    state smallint not null,
    FOREIGN KEY (peer) REFERENCES main.Peers(nick_name)
);

CREATE TABLE IF NOT EXISTS main.Transferred_Points (
    id serial PRIMARY KEY,
    checking_peer text not null,
    checked_peer text not null,
    points_amount bigint not null,
    FOREIGN KEY (checked_peer) references main.Peers(nick_name),
    FOREIGN KEY (checking_peer) references main.Peers(nick_name)
);

CREATE TABLE IF NOT EXISTS main.Tasks (
    title text primary key,
    parent_task text,
    max_xp int
);


CREATE TABLE IF NOT EXISTS main.Checks (
    id serial PRIMARY KEY,
    peer text not null,
    task text not null,
    "date" date default current_date not null,
    FOREIGN KEY (peer) REFERENCES main.Peers(nick_name),
    FOREIGN KEY (task) REFERENCES main.Tasks(title)
);

-- Создание перечисления "Статус проверки"
DROP TYPE IF EXISTS check_status CASCADE;
CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');

CREATE TABLE IF NOT EXISTS main.P2P (
    id serial primary key,
    "check" serial not null,
    Checking_peer text not null,
    state check_status not null,
    time time default current_time(0) not null,
    FOREIGN KEY (Checking_peer) REFERENCES main.Peers(nick_name)
);


CREATE TABLE IF NOT EXISTS main.XP (
    id serial primary key ,
    "check" serial not null,
    xp_amount bigint not null,
    FOREIGN KEY ("check") REFERENCES main.Checks(id)
);

CREATE TABLE IF NOT EXISTS main.Verter (
  id serial primary key ,
  "check" serial not null,
  state text not null,
  time time default now(),
  foreign key ("check") references main.Checks(id)
);


-- Добавление пользователей в таблицу Peers
INSERT INTO main.peers (nick_name, birth_day)
VALUES ('changeli', '1996-01-01'),
       ('tamelabe', '1996-01-02'),
       ('yonnarge', '1996-01-03'),
       ('alesande', '1996-01-04'),
       ('violette', '1996-01-05'),
       ('curranca', '1996-01-06'),
       ('milagros', '1996-01-07'),
       ('keyesdar', '1996-01-08'),
       ('mikaelag', '1996-01-09'),
       ('rossetel', '1996-01-10');


-- Добавление значений в таблицу Tasks
INSERT INTO main.Tasks
VALUES ('C2_SimpleBashUtils', NULL, 250),
       ('C3_s21_string+', 'C2_SimpleBashUtils', 500),
       ('C4_s21_math', 'C2_SimpleBashUtils', 300),
       ('C5_s21_decimal', 'C4_s21_math', 350),
       ('C6_s21_matrix', 'C5_s21_decimal', 200),
       ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 500),
       ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 750),
       ('DO1_Linux', 'C3_s21_string+', 300),
       ('DO2_Linux Network', 'DO1_Linux', 250),
       ('DO3_LinuxMonitoring v1.0', 'DO2_Linux Network', 350),
       ('DO4_LinuxMonitoring v2.0', 'DO3_LinuxMonitoring v1.0', 350),
       ('DO5_SimpleDocker', 'DO3_LinuxMonitoring v1.0', 300),
       ('DO6_CICD', 'DO5_SimpleDocker', 300),
       ('CPP1_s21_matrix+', 'C8_3DViewer_v1.0', 300),
       ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350),
       ('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 600),
       ('CPP4_3DViewer_v2.0', 'CPP3_SmartCalc_v2.0', 750),
       ('CPP5_3DViewer_v2.1', 'CPP4_3DViewer_v2.0', 600),
       ('CPP6_3DViewer_v2.2', 'CPP4_3DViewer_v2.0', 800),
       ('CPP7_MLP', 'CPP4_3DViewer_v2.0', 700),
       ('CPP8_PhotoLab_v1.0', 'CPP4_3DViewer_v2.0', 450),
       ('CPP9_MonitoringSystem', 'CPP4_3DViewer_v2.0', 1000),
       ('A1_Maze', 'CPP4_3DViewer_v2.0', 300),
       ('A2_SimpleNavigator v1.0', 'A1_Maze', 400),
       ('A3_Parallels', 'A2_SimpleNavigator v1.0', 300),
       ('A4_Crypto', 'A2_SimpleNavigator v1.0', 350),
       ('A5_s21_memory', 'A2_SimpleNavigator v1.0', 400),
       ('A6_Transactions', 'A2_SimpleNavigator v1.0', 700),
       ('A7_DNA Analyzer', 'A2_SimpleNavigator v1.0', 800),
       ('A8_Algorithmic trading', 'A2_SimpleNavigator v1.0', 800),
       ('SQL1_Bootcamp', 'C8_3DViewer_v1.0', 1500),
       ('SQL2_Info21 v1.0', 'SQL1_Bootcamp', 500),
       ('SQL3_RetailAnalitycs v1.0', 'SQL2_Info21 v1.0', 600);


INSERT INTO main.Checks (id, peer, task, date)
VALUES (1, 'changeli', 'C2_SimpleBashUtils', '2022-06-01'),
       (2, 'changeli', 'C2_SimpleBashUtils', '2022-06-06'),
       (3, 'tamelabe', 'C4_s21_math', '2022-05-06'),
       (4, 'yonnarge', 'C6_s21_matrix', '2022-07-16'),
       (5, 'yonnarge', 'C6_s21_matrix', '2022-07-20'),
       (6, 'keyesdar', 'DO1_Linux', '2022-06-16'),
       (7, 'rossetel', 'DO2_Linux Network', '2022-07-16'),
       (8, 'changeli', 'DO2_Linux Network', '2022-07-16'),
       (9, 'changeli', 'DO3_LinuxMonitoring v1.0', '2022-08-21'),
       (10, 'mikaelag', 'C5_s21_decimal', '2022-05-21'),
       (11, 'changeli', 'C3_s21_string+', '2022-06-06'),
       (12, 'milagros', 'C4_s21_math', '2022-07-08'),
       (13, 'tamelabe', 'C3_s21_string+', '2022-08-08'),
       (14, 'violette', 'DO1_Linux', '2022-06-01'),
       (15, 'alesande', 'C6_s21_matrix', '2022-10-10'),
       (16, 'curranca', 'DO1_Linux', '2022-07-07'),
       (17, 'changeli', 'C2_SimpleBashUtils', '2022-06-07');



-- Добавление значений в таблицу P2P Часть 2
INSERT INTO main.P2P (id, "check", checking_peer, state, time)
VALUES (1, 1, 'tamelabe', 'Start', '09:00:00'),
       (2, 1, 'tamelabe', 'Failure', '10:00:00'),  -- Пир завалил

       (3, 2, 'yonnarge', 'Start', '13:00:00'),
       (4, 2, 'yonnarge', 'Success', '14:00:00'),

       (5, 3, 'changeli', 'Start', '22:00:00'),
       (6, 3, 'changeli', 'Success', '23:00:00'),

       (7, 4, 'curranca', 'Start', '15:00:00'),
       (8, 4, 'curranca', 'Success', '16:00:00'),  -- Verter завалил

       (9, 5, 'rossetel', 'Start', '14:00:00'),
       (10, 5, 'rossetel', 'Success', '15:00:00'),

       (11, 6, 'violette', 'Start', '01:00:00'),
       (12, 6, 'violette', 'Success', '02:00:00'),

       (13, 7, 'keyesdar', 'Start', '10:00:00'),
       (14, 7, 'keyesdar', 'Success', '12:00:00'),

       (15, 8, 'mikaelag', 'Start', '12:00:00'),
       (16, 8, 'mikaelag', 'Success', '13:00:00'),

       (17, 9, 'tamelabe', 'Start', '12:00:00'),
       (18, 9, 'tamelabe', 'Success', '13:00:00'),

       (19, 10, 'alesande', 'Start', '19:00:00'),

       (20, 11, 'keyesdar', 'Start', '15:00:00'),
       (21, 11, 'keyesdar', 'Success', '15:01:00'),

       (22, 12, 'curranca', 'Start', '22:00:00'),
       (23, 12, 'curranca', 'Failure', '23:00:00'),

       (24, 13, 'rossetel', 'Start', '22:00:00'),
       (25, 13, 'rossetel', 'Success', '23:00:00'),

       (26, 14, 'changeli', 'Start', '22:00:00'),
       (27, 14, 'changeli', 'Success', '23:00:00'),

       (28, 15, 'curranca', 'Start', '04:00:00'),
       (29, 15, 'curranca', 'Success', '05:00:00'),

       (30, 16, 'milagros', 'Start', '05:00:00'),
       (31, 16, 'milagros', 'Failure', '06:00:00'),

       (32, 17, 'milagros', 'Start', '05:00:00'),
       (33, 17, 'milagros', 'Success', '06:00:00');


-- Добавление значений в таблицу Verter
INSERT INTO main.Verter (id, "check", State, Time)
VALUES (1, 2, 'Start', '13:01:00'),
       (2, 2, 'Success', '13:02:00'),

       (3, 3, 'Start', '23:01:00'),
       (4, 3, 'Success', '23:02:00'),

       (5, 4, 'Start', '16:01:00'),
       (6, 4, 'Failure', '16:02:00'),

       (7, 5, 'Start', '15:01:00'),
       (8, 5, 'Success', '15:02:00'),

       (9, 13, 'Start', '23:01:00'),
       (10, 13, 'Success', '23:02:00'),

       (11, 15, 'Start', '05:01:00'),
       (12, 15, 'Failure', '05:02:00'),

       (13, 17, 'Start', '06:01:00'),
       (14, 17, 'Success', '06:02:00');


-- Добавление значений в таблицу Friends
-- Добавить ограничения, чтобы строки не дублировались (changeli - tamelabe, tamelabe - changeli)
INSERT INTO main.Friends (id, peer_1, peer_2)
VALUES (1, 'changeli', 'tamelabe'),
       (2, 'changeli', 'mikaelag'),
       (3, 'tamelabe', 'mikaelag'),
       (4, 'tamelabe', 'rossetel'),
       (5, 'violette', 'milagros'),
       (6, 'curranca', 'changeli'),
       (7, 'yonnarge', 'tamelabe'),
       (8, 'alesande', 'yonnarge'),
       (9, 'milagros', 'keyesdar'),
       (10, 'yonnarge', 'alesande');


-- Добавление значений в таблицу Recommendations
INSERT INTO main.Recommendations (id, Peer, recommended_peer)
VALUES (1, 'changeli', 'tamelabe'),
       (2, 'changeli', 'violette'),
       (3, 'tamelabe', 'yonnarge'),
       (4, 'curranca', 'changeli'),
       (5, 'alesande', 'curranca'),
       (6, 'alesande', 'milagros'),
       (7, 'keyesdar', 'alesande'),
       (8, 'milagros', 'tamelabe'),
       (9, 'mikaelag', 'keyesdar'),
       (10, 'mikaelag', 'rossetel');

-- Добавление значений в таблицу XP
INSERT INTO main.XP (id, "check", xp_amount)
VALUES (1, 2, 240),
       (2, 3, 300),
       (3, 5, 200),
       (4, 6, 250),
       (5, 7, 250),
       (6, 8, 250),
       (7, 9, 350),
       (8, 10, 299),
       (9, 17, 250);

-- Добавление значений в таблицу TimeTracking
INSERT INTO main.time_tracking (id, peer, Date, Time, State)
VALUES (1, 'changeli', '2022-05-02', '08:00:00', 1),
       (2, 'changeli', '2022-05-02', '18:00:00', 2),
       (3, 'tamelabe', '2022-05-02', '18:30:00', 1),
       (4, 'tamelabe', '2022-05-02', '23:30:00', 2),
       (5, 'changeli', '2022-05-02', '18:10:00', 1),
       (6, 'changeli', '2022-05-02', '21:00:00', 2),
       (7, 'curranca', '2022-06-22', '10:00:00', 1),
       (8, 'tamelabe', '2022-06-22', '11:00:00', 1),
       (9, 'tamelabe', '2022-06-22', '21:00:00', 2),
       (10, 'curranca', '2022-06-22', '23:00:00', 2);

-- Создание процедуры для экпорта данных в файлы
DROP PROCEDURE IF EXISTS main.export() CASCADE;

CREATE OR REPLACE PROCEDURE main.export(IN tablename varchar, IN path text, IN separator char)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        EXECUTE format('COPY %s TO ''%s'' DELIMITER ''%s'' CSV HEADER;',
            tablename, path, separator);
    END;
$$ ;

-- Создание процедуры для импорта данных из файлов
DROP PROCEDURE IF EXISTS main.import() CASCADE;

CREATE OR REPLACE PROCEDURE main.import(IN tablename varchar, IN path text, IN separator char)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        EXECUTE format('COPY %s FROM ''%s'' DELIMITER ''%s'' CSV HEADER;',
            tablename, path, separator);
    END;
$$ ;