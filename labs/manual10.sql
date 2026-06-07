

-- 1. Create the Team table
CREATE TABLE team (
    tname VARCHAR(25) NOT NULL,
    tid INT NOT NULL PRIMARY KEY,
    coach VARCHAR(25),
    home_city VARCHAR(25)
);

-- 2. Create the Player table
CREATE TABLE player (
    pname VARCHAR(25) NOT NULL,
    pid INT NOT NULL PRIMARY KEY,
    age INT,
    role VARCHAR(15), 
    salary DECIMAL(10,2),
    tid INT NOT NULL,
    captain_id INT,
    FOREIGN KEY (tid) REFERENCES team(tid),
    FOREIGN KEY (captain_id) REFERENCES player(pid)
);

-- 3. Create the Tournament table
CREATE TABLE tournament (
    tour_id INT NOT NULL PRIMARY KEY,
    tour_name VARCHAR(30),
    year INT
);

-- 4. Create the Match table
CREATE TABLE match (
    mid INT NOT NULL PRIMARY KEY,
    mdate DATE,
    venue VARCHAR(30),
    team1_id INT,
    team2_id INT,
    winner_id INT,
    tour_id INT,
    FOREIGN KEY (team1_id) REFERENCES team(tid),
    FOREIGN KEY (team2_id) REFERENCES team(tid),
    FOREIGN KEY (winner_id) REFERENCES team(tid),
    FOREIGN KEY (tour_id) REFERENCES tournament(tour_id)
);

-- 5. Create the Player_Match_Performance table
CREATE TABLE performance (
    pid INT NOT NULL,
    mid INT NOT NULL,
    runs INT DEFAULT 0,
    wickets INT DEFAULT 0,
    catches INT DEFAULT 0,
    PRIMARY KEY (pid, mid),
    FOREIGN KEY (pid) REFERENCES player(pid),
    FOREIGN KEY (mid) REFERENCES match(mid)
);

-- Disable constraints to allow insertion in any order
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Insert data into Team table
INSERT INTO team VALUES
('Lahore Lions', 1, 'Mickey Arthur', 'Lahore'),
('Karachi Kings', 2, 'Wasim Akram', 'Karachi'),
('Islamabad United', 3, 'Dean Jones', 'Islamabad'),
('Peshawar Zalmi', 4, 'Darren Sammy', 'Peshawar');

-- Insert data into Player table
INSERT INTO player VALUES
('Babar Azam', 101, 29, 'Batsman', 90000, 1, NULL),
('Shaheen Afridi', 102, 27, 'Bowler', 85000, 1, 101),
('Rizwan', 103, 31, 'Wicketkeeper', 88000, 2, NULL),
('Amir', 104, 32, 'Bowler', 70000, 2, 103),
('Shadab Khan', 105, 26, 'All-Rounder', 80000, 3, NULL),
('Hasan Ali', 106, 30, 'Bowler', 75000, 3, 105),
('Wahab Riaz', 107, 35, 'Bowler', 72000, 4, NULL),
('Tom Kohler', 108, 28, 'Batsman', 65000, 4, 107);

-- Insert data into Tournament table
INSERT INTO tournament VALUES
(1, 'PSL', 2024),
(2, 'Champions Cup', 2025);

-- Insert data into Match table
INSERT INTO match VALUES
(201, '2024-02-01', 'Lahore', 1, 2, 1, 1),
(202, '2024-02-05', 'Karachi', 2, 3, 3, 1),
(203, '2024-02-10', 'Islamabad', 3, 4, 4, 1),
(204, '2025-03-01', 'Peshawar', 1, 3, 3, 2),
(205, '2025-03-05', 'Lahore', 2, 4, 2, 2);

-- Insert data into Performance table
INSERT INTO performance VALUES
(101, 201, 75, 0, 1),
(102, 201, 10, 3, 0),
(103, 201, 50, 0, 2),
(104, 202, 5, 2, 0),
(105, 202, 40, 1, 1),
(106, 203, 15, 4, 0),
(107, 203, 20, 2, 1),
(108, 204, 60, 0, 0),
(101, 204, 55, 0, 1),
(105, 205, 35, 2, 0);

-- Enable constraints again
EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT ALL";
GO

-- Q1
BEGIN TRANSACTION;
INSERT INTO team VALUES ('Multan Sultans', 6, 'Andy Flower', 'Multan');
COMMIT;
GO

-- Q2
BEGIN TRANSACTION;
INSERT INTO player VALUES ('Fakhar Zaman', 109, 34, 'Batsman', 85000, 1, NULL);
ROLLBACK;
GO

-- Q3
BEGIN TRANSACTION;
INSERT INTO team VALUES ('Sialkot Stallions', 7, 'Shoaib Malik', 'Sialkot');
INSERT INTO player VALUES ('Anwar Ali', 110, 38, 'All-Rounder', 60000, 7, NULL);
INSERT INTO player VALUES ('Bilal Asif', 111, 40, 'Bowler', 55000, 7, 110);
COMMIT;
GO

-- Q4
BEGIN TRANSACTION;
UPDATE player 
SET salary = salary + 15000 
WHERE pid = 105;
IF (SELECT salary FROM player WHERE pid = 105) > 100000
BEGIN
    ROLLBACK;
END
ELSE
BEGIN
    COMMIT;
END
GO

-- Q5
BEGIN TRANSACTION;
DELETE FROM match WHERE mid = 205;
IF @@ROWCOUNT = 0
BEGIN
    ROLLBACK;
END
ELSE
BEGIN
    COMMIT;
END
GO

-- Q6
BEGIN TRANSACTION;
INSERT INTO team VALUES ('Faisalabad Wolves', 8, 'Misbah-ul-Haq', 'Faisalabad');
SAVE TRANSACTION AfterTeamInsert;
INSERT INTO player VALUES ('Saeed Ajmal', 112, 46, 'Bowler', 50000, 8, NULL);
INSERT INTO player VALUES ('Asad Ali', 113, 37, 'Bowler', 45000, 8, 112);
ROLLBACK TRANSACTION AfterTeamInsert;
COMMIT;
GO

-- Q7
BEGIN TRANSACTION;
UPDATE player 
SET tid = 3 
WHERE pid = 103;
INSERT INTO performance VALUES (103, 203, 45, 0, 1);
IF NOT EXISTS (
    SELECT 1 
    FROM match m 
    JOIN player p ON p.pid = 103 
    WHERE m.mid = 203 AND (p.tid = m.team1_id OR p.tid = m.team2_id)
)
BEGIN
    ROLLBACK;
END
ELSE
BEGIN
    COMMIT;
END
GO