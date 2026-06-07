
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
    role VARCHAR(15), -- Batsman, Bowler, All-Rounder, Wicketkeeper
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
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO match VALUES (206, '2025-04-01', 'Karachi', 1, 4, 1, 1);
    
    INSERT INTO performance VALUES (101, 206, 45, 0, 1);
    INSERT INTO performance VALUES (107, 206, 12, 3, 0);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO


-- Q2
BEGIN TRY
    BEGIN TRANSACTION;

    
    UPDATE player 
    SET tid = 2, captain_id = NULL 
    WHERE pid = 101;

 
    UPDATE player 
    SET captain_id = NULL 
    WHERE captain_id = 101;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
GO


-- Q3
BEGIN TRANSACTION;

INSERT INTO match VALUES (207, '2025-04-10', 'Islamabad', 2, 3, 2, 1);

IF EXISTS (SELECT 1 FROM team WHERE tid = 2) AND EXISTS (SELECT 1 FROM team WHERE tid = 3)
BEGIN
    COMMIT TRANSACTION;
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
END
GO


-- Q4
BEGIN TRANSACTION;

INSERT INTO tournament VALUES (3, 'Asia Cup', 2026);

SAVE TRANSACTION TournamentSaved;

INSERT INTO match VALUES (208, '2026-05-01', 'Lahore', 1, 99, NULL, 3);
INSERT INTO match VALUES (209, '2026-05-03', 'Karachi', 2, 4, NULL, 3);

IF EXISTS (
    SELECT 1 
    FROM match m
    LEFT JOIN team t1 ON m.team1_id = t1.tid
    LEFT JOIN team t2 ON m.team2_id = t2.tid
    WHERE m.tour_id = 3 AND (t1.tid IS NULL OR t2.tid IS NULL)
)
BEGIN
    ROLLBACK TRANSACTION TournamentSaved;
    COMMIT TRANSACTION;
END
ELSE
BEGIN
    COMMIT TRANSACTION;
END
GO


-- Q5
BEGIN TRANSACTION;

UPDATE player
SET salary = salary * 1.10
WHERE tid = 1;

IF (SELECT AVG(salary) FROM player WHERE tid = 1) > 90000
BEGIN
    ROLLBACK TRANSACTION;
END
ELSE
BEGIN
    COMMIT TRANSACTION;
END
GO


-- Q6
BEGIN TRANSACTION;

INSERT INTO performance VALUES (102, 205, 40, 1, 0);
INSERT INTO performance VALUES (107, 205, 30, 2, 1);

IF (SELECT SUM(runs) FROM performance WHERE mid = 205) > 500
BEGIN
    ROLLBACK TRANSACTION;
END
ELSE
BEGIN
    COMMIT TRANSACTION;
END
GO


-- Q7
BEGIN TRANSACTION;

INSERT INTO team VALUES ('Quetta Gladiators', 5, 'Viv Richards', 'Quetta');

SAVE TRANSACTION TeamSaved;

INSERT INTO player VALUES ('Sarfaraz Ahmed', 201, 36, 'Wicketkeeper', 75000, 5, NULL);
INSERT INTO player VALUES ('Jason Roy', 202, 33, 'Batsman', -5000, 5, 201); -- Invalid salary data

IF EXISTS (SELECT 1 FROM player WHERE tid = 5 AND salary < 0)
BEGIN
    ROLLBACK TRANSACTION TeamSaved;
    COMMIT TRANSACTION;
END
ELSE
BEGIN
    COMMIT TRANSACTION;
END
GO