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
    nick_name text not null,
    "date" date default current_date not null,
    "time" time default current_time(0) not null,
    state smallint not null,
    FOREIGN KEY (nick_name) REFERENCES main.Peers(nick_name)
);

CREATE TABLE IF NOT EXISTS main.Transferred_Points (
    id serial PRIMARY KEY,
    checking_peer text not null,
    checked_peer text not null,
    points_amount bigint not null,
    FOREIGN KEY (checked_peer) references main.Peers(nick_name),
    FOREIGN KEY (checking_peer) references main.Peers(nick_name)
);

CREATE TABLE IF NOT EXISTS main.Task (
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
    FOREIGN KEY (task) REFERENCES main.Task(title)
);

CREATE TABLE IF NOT EXISTS main.P2P (
    id serial primary key,
    "check" serial not null,
    Checking_peer text not null,
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
  time timestamp with time zone default now(),
  foreign key ("check") references main.Checks(id)
);
