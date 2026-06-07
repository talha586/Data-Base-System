USE [24L-0618];

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

-- Q1 
CREATE TRIGGER trg_AfterPlayerInsert
ON player 
AFTER INSERT
AS
BEGIN
PRINT 'A new player has been added to the database'; 
END;

-- Q2 
CREATE TRIGGER trg_AfterTeamDelete
ON team 
AFTER DELETE
AS
BEGIN
SELECT tname FROM deleted; 
END;

-- Q3 

CREATE TRIGGER trg_AfterSalaryUpdate
ON player 
AFTER UPDATE
AS
BEGIN
IF EXISTS (
SELECT 1
FROM inserted i
JOIN deleted d ON i.pid = d.pid
WHERE ABS(i.salary - d.salary) > 5000 
)
BEGIN
PRINT 'A player’s salary has been updated by more than 5000'; 
END
END;

-- Q4 

CREATE TRIGGER trg_InsteadOfPlayerInsert
ON player 
INSTEAD OF INSERT
AS
BEGIN
IF EXISTS (SELECT 1 FROM inserted WHERE age < 17) 
BEGIN
PRINT 'Insertion prevented: Player age must be at least 17'; 
END
ELSE
BEGIN
INSERT INTO player (pname, pid, age, role, salary, tid, captain_id)
SELECT pname, pid, age, role, salary, tid, captain_id FROM inserted;
END
END;

-- Q5 

ALTER TABLE player ADD total_runs INT DEFAULT 0, total_wickets INT DEFAULT 0; CREATE TRIGGER trg_UpdatePlayerStats
ON performance 
AFTER INSERT
AS
BEGIN
UPDATE player
SET total_runs = total_runs + (SELECT SUM(runs) FROM inserted WHERE inserted.pid = player.pid),
total_wickets = total_wickets + (SELECT SUM(wickets) FROM inserted WHERE inserted.pid = player.pid)
WHERE pid IN (SELECT pid FROM inserted); 
END;
-- Q6 
CREATE TRIGGER trg_CascadeDeletePlayers
ON team 
AFTER DELETE
AS
BEGIN
DELETE FROM player
WHERE tid IN (SELECT tid FROM deleted); 
END;

-- Q7 

CREATE TRIGGER trg_AfterMatchWinnerUpdate
ON match 
AFTER UPDATE
AS
BEGIN
IF UPDATE(winner_id) 
BEGIN
PRINT 'The winner of the match has been changed'; 
END
END;

-- Q8 

CREATE TRIGGER trg_RestrictPlayerDelete
ON player 
INSTEAD OF DELETE
AS
BEGIN
IF EXISTS (
SELECT 1
FROM performance
WHERE pid IN (SELECT pid FROM deleted) 
)
BEGIN
PRINT 'Deletion prevented: Player has performance records'; 
END
ELSE
BEGIN
DELETE FROM player WHERE pid IN (SELECT pid FROM deleted);
END
END;

-- Q9 

CREATE TRIGGER trg_MultiRowPerformanceInsert
ON performance 
AFTER INSERT
AS
BEGIN
DECLARE @totalInsertedRuns INT;
SELECT @totalInsertedRuns = SUM(runs) FROM inserted; PRINT 'Total runs added in this operation: ' + CAST(@totalInsertedRuns AS VARCHAR); 
END;

-- Q10
CREATE TABLE audit_salary ( 
audit_id INT IDENTITY PRIMARY KEY,
pid INT,
old_salary DECIMAL(10,2),
new_salary DECIMAL(10,2),
change_date DATETIME DEFAULT GETDATE() 
);CREATE TRIGGER trg_AuditPlayerSalary
ON player 
AFTER UPDATE
AS
BEGIN
IF UPDATE(salary) 
BEGIN
INSERT INTO audit_salary (pid, old_salary, new_salary)
SELECT i.pid, d.salary, i.salary
FROM inserted i
JOIN deleted d ON i.pid = d.pid; 
END
END;