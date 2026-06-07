use [l240618];

-- Create the Department table
CREATE TABLE department (
    dname VARCHAR(25) NOT NULL,
    dnumber INT NOT NULL PRIMARY KEY,
    mgrssn CHAR(9),
    mgrstartdate DATE
);

-- Create the Employee table
CREATE TABLE employee (
    fname VARCHAR(15) NOT NULL,
    minit CHAR(1),
    lname VARCHAR(15) NOT NULL,
    ssn CHAR(9) NOT NULL PRIMARY KEY,
    bdate DATE,
    address VARCHAR(50),
    sex CHAR(1),
    salary DECIMAL(10,2),
    superssn CHAR(9),
    dno INT NOT NULL,
    FOREIGN KEY (dno) REFERENCES department(dnumber),
    FOREIGN KEY (superssn) REFERENCES employee(ssn)
);

-- Add the foreign key for mgrssn in department (after employee table is created)
ALTER TABLE department
ADD FOREIGN KEY (mgrssn) REFERENCES employee(ssn);

-- Create the Dependent table
CREATE TABLE dependent (
    essn CHAR(9) NOT NULL,
    dependent_name VARCHAR(15) NOT NULL,
    sex CHAR(1),
    bdate DATE,
    relationship VARCHAR(8),
    PRIMARY KEY (essn, dependent_name),
    FOREIGN KEY (essn) REFERENCES employee(ssn)
);

-- Create the Dept_Locations table
CREATE TABLE dept_locations (
    dnumber INT NOT NULL,
    dlocation VARCHAR(15) NOT NULL,
    PRIMARY KEY (dnumber, dlocation),
    FOREIGN KEY (dnumber) REFERENCES department(dnumber)
);

-- Create the Project table
CREATE TABLE project (
    pname VARCHAR(25) NOT NULL,
    pnumber INT NOT NULL PRIMARY KEY,
    plocation VARCHAR(15),
    dnum INT NOT NULL,
    FOREIGN KEY (dnum) REFERENCES department(dnumber)
);

-- Create the Works_On table
CREATE TABLE works_on (
    essn CHAR(9) NOT NULL,
    pno INT NOT NULL,
    hours DECIMAL(4,1),
    PRIMARY KEY (essn, pno),
    FOREIGN KEY (essn) REFERENCES employee(ssn),
    FOREIGN KEY (pno) REFERENCES project(pnumber)
);

EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

-- Insert data into Department table
INSERT INTO department (dname, dnumber, mgrssn, mgrstartdate) VALUES
('HR', 1, '123456789', '2023-01-01'),
('Finance', 2, '987654321', '2023-02-01'),
('IT', 3, '456123789', '2023-03-01'),
('Marketing', 4, '789456123', '2023-04-01'),
('Operations', 5, '321654987', '2023-05-01'),
('R&D', 6, '159753486', '2023-06-01'),
('Sales', 7, '951357486', '2023-07-01'),
('Legal', 8, '753951486', '2023-08-01'),
('Support', 9, '852741963', '2023-09-01'),
('Logistics', 10, '654852963', '2023-10-01');

-- Insert data into Employee table
INSERT INTO employee (fname, minit, lname, ssn, bdate, address, sex, salary, superssn, dno) VALUES
('John', 'D', 'Smith', '123456789', '1980-01-01', '123 Main St', 'M', 50000.00, NULL, 1),
('Jane', 'A', 'Doe', '987654321', '1990-02-02', '456 Elm St', 'F', 60000.00, '123456789', 2),
('Emily', 'B', 'Jones', '456123789', '1985-03-03', '789 Oak St', 'F', 55000.00, '123456789', 3),
('Michael', 'C', 'Brown', '789456123', '1975-04-04', '321 Pine St', 'M', 75000.00, '987654321', 4),
('Chris', 'E', 'Davis', '321654987', '1988-05-05', '654 Maple St', 'M', 65000.00, '987654321', 5),
('Sara', 'F', 'Wilson', '159753486', '1992-06-06', '987 Spruce St', 'F', 47000.00, '456123789', 6),
('David', 'G', 'Taylor', '951357486', '1983-07-07', '135 Birch St', 'M', 52000.00, '159753486', 7),
('Sophia', 'H', 'Anderson', '753951486', '1991-08-08', '864 Cedar St', 'F', 48000.00, '951357486', 8),
('Ethan', 'I', 'Thomas', '852741963', '1995-09-09', '246 Walnut St', 'M', 56000.00, '753951486', 9),
('Olivia', 'J', 'Moore', '654852963', '1994-10-10', '579 Chestnut St', 'F', 62000.00, '753951486', 10);

-- Insert data into Dependent table
INSERT INTO dependent (essn, dependent_name, sex, bdate, relationship) VALUES
('123456789', 'Anna', 'F', '2005-01-01', 'Daughter'),
('123456789', 'Mark', 'M', '2008-02-02', 'Son'),
('987654321', 'Sam', 'M', '2007-03-03', 'Son'),
('456123789', 'Ella', 'F', '2010-04-04', 'Daughter'),
('789456123', 'Max', 'M', '2012-05-05', 'Son'),
('321654987', 'Liam', 'M', '2013-06-06', 'Son'),
('159753486', 'Emma', 'F', '2015-07-07', 'Daughter'),
('951357486', 'Olive', 'F', '2016-08-08', 'Daughter'),
('753951486', 'Lucas', 'M', '2017-09-09', 'Son'),
('852741963', 'Sophia', 'F', '2018-10-10', 'Daughter');

-- Insert data into Dept_Locations table
INSERT INTO dept_locations (dnumber, dlocation) VALUES
(1, 'New York'),
(1, 'Chicago'),
(2, 'Los Angeles'),
(2, 'Houston'),
(3, 'San Francisco'),
(3, 'Boston'),
(4, 'Seattle'),
(4, 'Denver'),
(5, 'Austin'),
(5, 'Dallas'),
(6, 'Atlanta'),
(6, 'Miami'),
(7, 'Phoenix'),
(7, 'Philadelphia'),
(8, 'San Diego'),
(8, 'San Jose'),
(9, 'Orlando'),
(9, 'Tampa'),
(10, 'Detroit'),
(10, 'Cleveland');

-- Insert data into Project table
INSERT INTO project (pname, pnumber, plocation, dnum) VALUES
('Alpha', 1, 'New York', 1),
('Beta', 2, 'Los Angeles', 2),
('Gamma', 3, 'San Francisco', 3),
('Delta', 4, 'Seattle', 4),
('Epsilon', 5, 'Austin', 5),
('Zeta', 6, 'Atlanta', 6),
('Eta', 7, 'Phoenix', 7),
('Theta', 8, 'San Diego', 8),
('Iota', 9, 'Orlando', 9),
('Kappa', 10, 'Detroit', 10);

-- Insert data into Works_On table
INSERT INTO works_on (essn, pno, hours) VALUES
('123456789', 1, 20.5),
('987654321', 2, 30.0),
('456123789', 3, 25.0),
('789456123', 4, 35.0),
('321654987', 5, 40.0),
('159753486', 6, 15.0),
('951357486', 7, 22.0),
('753951486', 8, 18.0),
('852741963', 9, 28.5),
('654852963', 10, 33.0);

-- Insert additional employees (some without projects)
INSERT INTO employee (fname, minit, lname, ssn, bdate, address, sex, salary, superssn, dno) VALUES
('Tom', 'K', 'Holland', '112233445', '1993-11-11', '789 Cedar St', 'M', 57000.00, '456123789', 2), -- No project
('Lucy', 'L', 'Miller', '223344556', '1996-12-12', '999 Birch St', 'F', 60000.00, '987654321', 5); -- No project

-- Insert additional projects (some without employees)
INSERT INTO project (pname, pnumber, plocation, dnum) VALUES
('Lambda', 11, 'Las Vegas', 3), -- No employees assigned
('Omega', 12, 'Seattle', 6); -- No employees assigned

-- Insert additional departments (some without projects)
INSERT INTO department (dname, dnumber, mgrssn, mgrstartdate) VALUES
('Public Relations', 11, '951753258', '2023-11-01'); -- No projects

-- Assign some employees to multiple projects
INSERT INTO works_on (essn, pno, hours) VALUES
('123456789', 2, 10.0), -- John Smith works on another project
('987654321', 4, 15.5), -- Jane Doe works on another project
('951357486', 6, 10.0); -- David Taylor works on another project

-- Insert a department without employees
INSERT INTO department (dname, dnumber, mgrssn, mgrstartdate) VALUES
('Strategy', 12, '123789456', '2023-12-01'); -- No employees

-- Insert some employees without dependents (not inserting any dependent data for them)
-- Employees Ethan Thomas (852741963) and Olivia Moore (654852963) have no dependents

-- Modify supervisors to create employees with more than one supervisor
UPDATE employee SET superssn = '753951486' WHERE ssn = '951357486'; -- David Taylor has two supervisors

-- Duplicate locations for UNION queries
INSERT INTO dept_locations (dnumber, dlocation) VALUES
(3, 'Seattle'); -- Same as a project location

--Q1
SELECT fname+lname,ssn FROM employee WHERE fname LIKE 'J%'

--Q2
SELECT fname+lname,ssn FROM employee WHERE fname LIKE '%son'

--Q3
SELECT fname+lname,ssn FROM employee WHERE fname LIKE 'A%' OR fname LIKE 'S%'

--Q4
SELECT TOP 5 * FROM employee

--Q5
SELECT e.fname+e.lname ,d.dname FROM employee e FULL JOIN department d ON e.dno=d.dnumber

--Q6
SELECT e.fname+e.lname,count(p.pno) AS counts FROM employee e JOIN works_on p ON e.ssn=p.essn GROUP BY e.fname+e.lname HAVING COUNT(p.pno)>1;

--Q7
SELECT e.fname+e.lname AS Names, d.dependent_name FROM employee e LEFT JOIN dependent d ON e.ssn=d.essn 

--Q8
SELECT d.dname, AVG(e.salary) AS Avg_Salary  FROM employee e JOIN department d ON e.dno=d.dnumber GROUP BY d.dname ORDER BY Avg_Salary DESC

--Q9
SELECT e.fname+ e.lname, e.salary FROM employee e ORDER BY e.salary ASC

--Q10
SELECT d.dname FROM department d LEFT JOIN project p ON d.dnumber=p.dnum WHERE p.dnum IS NULL

--Q11
SELECT d.dname, COUNT(*) FROM employee e JOIN department d ON e.dno=d.dnumber GROUP BY d.dname

--Q12
SELECT d.dnumber,d.dname, e.fname,e.dno FROM employee e RIGHT JOIN department d ON e.dno=d.dnumber 

--Q13
SELECT p.pname, p.pnumber, e.fname,e.ssn FROM project p LEFT JOIN employee e ON e.dno=p.dnum

--Q14
SELECT d.dname,d.dnumber,e.fname+' '+e.lname, e.ssn FROM department d LEFT JOIN employee e  ON d.mgrssn = e.ssn;

--Q15
SELECT d.dname,count(e.ssn) FROM department d JOIN employee e  ON e.dno=d.dnumber GROUP BY d.dname HAVING count(e.ssn)>3;

--Q16
SELECT dl.dlocation,count(d.dnumber) AS Department_Counter FROM dept_locations dl JOIN department d ON dl.dnumber=d.dnumber GROUP BY dl.dlocation HAVING count(d.dnumber)>1;