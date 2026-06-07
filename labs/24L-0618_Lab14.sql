-- Roll No: 24L-0618
-- Lab 14

USE Safegaurd;
GO

-- Part 1: Q1 - Nested Query
SELECT Name
FROM Patients
WHERE PatientID IN (
    SELECT PatientID
    FROM Infections
    WHERE GermID = (
        SELECT GermID
        FROM Germs
        WHERE Name = 'Dartu Virus'
    )
);
GO

-- Part 2: Q8 - View
CREATE VIEW vw_HighImpactGerms AS
SELECT *
FROM Germs
WHERE ImpactLevel >= 8;
GO

-- Part 3: Q13 - Stored Procedure
CREATE PROCEDURE sp_AddPatient
    @Name NVARCHAR(100),
    @Age INT,
    @Gender NVARCHAR(10)
AS
BEGIN
    INSERT INTO Patients (Name, Age, Gender)
    VALUES (@Name, @Age, @Gender)
END;
GO

-- Part 4: Q18 - Trigger
CREATE TRIGGER tr_AuditPrescriptions
ON Prescriptions
AFTER INSERT
AS
BEGIN
    INSERT INTO Prescriptions_History (PrescriptionID, PatientID, PrescriptionDate, ValidFrom)
    SELECT PrescriptionID, PatientID, PrescriptionDate, GETDATE()
    FROM inserted
END;
GO

-- Part 5: Q23 - Transaction
BEGIN TRANSACTION
BEGIN TRY
    INSERT INTO Prescriptions (PatientID, PrescriptionDate)
    VALUES (1, GETDATE())

    DECLARE @PrescriptionID INT = SCOPE_IDENTITY()

    INSERT INTO Prescription_Remedies (PrescriptionID, RemedyID, Dosage)
    VALUES (@PrescriptionID, 1, 'Once daily')

    INSERT INTO Prescription_Remedies (PrescriptionID, RemedyID, Dosage)
    VALUES (@PrescriptionID, 2, 'Twice daily')

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
END CATCH
GO
