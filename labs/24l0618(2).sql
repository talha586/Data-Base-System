
--QUESTION 1
--CREATE TABLE Patient(
--PatientID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--PatientName varchar(15) NOT NULL,
--PatientAge INT,
--Gender varchar(5),
--PatientAddress varchar(20),
--Disease varchar(10),
--DoctorID varchar(15),

--CONSTRAINT chk_PatientAge CHECK(PatientAge > 5)
--);

----QUESTION 2
--ALTER TABLE Patient
--ALTER COLUMN Gender CHAR;

------QUESTION 3
--CREATE TABLE Doctor(
--DoctorID varchar(15) PRIMARY KEY,
--DoctorName varchar(15) NOT NULL,
--DoctorAge INT,
--Gender CHAR,
--DoctorAddres varchar(20),

--CONSTRAINT chk_DoctorAge CHECK (DoctorAge>18)
--);

------QUESTION 4 
--ALTER TABLE Doctor
--ADD DrSpecialization varchar(20);

------QUESTION 5
--ALTER TABLE Patient
--ADD CONSTRAINT foreignkey_DoctorID
--FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)

------QUESTION 6
--CREATE TABLE LabTest(
--LabID varchar(15) PRIMARY KEY,
--LabNo varchar(10) UNIQUE,
--TestDate DATE DEFAULT GETDATE(),
--TestAmount FLOAT,
--PatientID INT IDENTITY(1,1) FOREIGN KEY REFERENCES Patient(PatientID),
--DoctorID varchar(15) FOREIGN KEY REFERENCES Doctor(DoctorID)
--)

------QUESTION 7
--CREATE TABLE PatientBill(
--BillID varchar(15) PRIMARY KEY,
--BillDate DATE,
--Amount varchar(20),
--PatientID INT IDENTITY(1,1) FOREIGN KEY REFERENCES Patient(PatientID),
--DoctorID varchar(15) FOREIGN KEY REFERENCES Doctor(DoctorID)
--)

------QUESTION 8
--DROP TABLE LabTest

------QUESTION 9
--INSERT INTO Doctor (DoctorID, DoctorName, DoctorAge, Gender, DoctorAddres, DrSpecialization)
--VALUES 
--('D001','Dr Ali', 45, 'M', 'Johar Town', 'Cardiology'),
--('D002', 'Dr Irha', 34, 'F', 'Wapda Town', 'Neurology'),
--('D003', 'Dr Talha', 50, 'M', 'Township', 'General'),
--('D004', 'Dr Warda', 29, 'F', 'Iqbal Town', 'Pediatrics');

------QUESTION 10
--INSERT INTO Patient (PatientName, PatientAge, Gender, PatientAddress, Disease, DoctorID)
--VALUES 
--('Hamza', 25, 'M', 'Johar Town', 'Flu', 'D001'),
--('Komal', 30, 'F', 'Wapda Town', 'Fever', 'D002'),
--('Abdullah', 12, 'M', 'Township', 'Flu', 'D001'),
--('Aleena', 60, 'F', 'Iqbal Town', 'Diabetes', 'D003');

------QUESTION 11
--INSERT INTO PatientBill (BillID, BillDate, Amount, DoctorID)
--VALUES 
--('B001', '2023-10-01', '500', 'D001'),
--('B002', '2023-10-02', '50', 'D002');

------QUESTION 12
--SELECT * FROM Patient
--SELECT * FROM PatientBill WHERE CAST(Amount AS INT)>100;

------QUESTION 13
--DELETE FROM PatientBill

----QUESTION 14
--DELETE FROM Patient WHERE PatientName='Aleena'

----QUESTION 15
UPDATE Patient
SET Disease='COVID'
WHERE Disease='Flu'

--DROP TABLE PatientBill
--DROP TABLE Patient
--DROP TABLE Doctor
