USE l240618;
GO

CREATE VIEW v_ManagerDepth AS
WITH Hierarchy AS (
    SELECT ssn, superssn, 0 AS Depth
    FROM doctor
    WHERE superssn IS NULL
    UNION ALL
    SELECT d.ssn, d.superssn, h.Depth + 1
    FROM doctor d
    INNER JOIN Hierarchy h ON d.superssn = h.ssn
)
SELECT 
    d.fname + ' ' + d.lname AS FullName, 
    s.sname AS Specialization, 
    h.Depth AS SupervisorChainCount
FROM doctor d
JOIN specialization s ON d.sno = s.snumber
JOIN Hierarchy h ON d.ssn = h.ssn;
GO

-- Q2
CREATE VIEW v_CrossSpecDoctors AS
SELECT 
    d.fname + ' ' + d.lname AS DoctorName, 
    s.sname AS Specialization, 
    COUNT(p.sno) AS OutsideSurgeryCount
FROM doctor d
JOIN specialization s ON d.sno = s.snumber
JOIN performed_by p ON d.ssn = p.essn
JOIN surgery sur ON p.sno = sur.snumber
WHERE sur.snum <> d.sno
GROUP BY d.fname, d.lname, s.sname;
GO

-- Q3
CREATE VIEW v_InvalidSurgeryLocations AS
SELECT 
    sur.sname AS SurgeryName, 
    sur.slocation, 
    spec.sname AS SpecName,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM spec_locations sl 
            WHERE sl.snumber = sur.snum AND sl.slocation = sur.slocation
        ) THEN 'VALID' 
        ELSE 'INVALID' 
    END AS Status
FROM surgery sur
JOIN specialization spec ON sur.snum = spec.snumber;
GO

-- Q4
CREATE VIEW v_OverloadedManagers 
WITH SCHEMABINDING AS
SELECT 
    m.fname, 
    m.lname, 
    COUNT_BIG(*) AS SupervisedDoctors, 
    SUM(ISNULL(p.hours, 0)) AS TotalTeamHours
FROM dbo.doctor m
JOIN dbo.specialization s ON m.ssn = s.mgrssn
JOIN dbo.doctor sub ON s.snumber = sub.sno
JOIN dbo.performed_by p ON sub.ssn = p.essn
GROUP BY m.fname, m.lname;
GO

CREATE UNIQUE CLUSTERED INDEX IDX_v_OverloadedManagers 
ON v_OverloadedManagers (fname, lname);
GO

-- Q5
CREATE VIEW v_DependencyBurden 
WITH SCHEMABINDING AS
SELECT 
    d.fname, 
    d.lname, 
    d.salary, 
    COUNT_BIG(*) AS DependentCount, 
    (COUNT_BIG(*) * d.salary) AS BurdenIndex
FROM dbo.doctor d
JOIN dbo.dependent dep ON d.ssn = dep.essn
GROUP BY d.fname, d.lname, d.salary;
GO

CREATE UNIQUE CLUSTERED INDEX IDX_v_DependencyBurden 
ON v_DependencyBurden (BurdenIndex, fname, lname);
GO

-- Q6
CREATE PROCEDURE sp_ReassignToBalancedSpec @DocSSN CHAR(9) AS
BEGIN
    DECLARE @TargetSno INT, @NewSup CHAR(9);
    SELECT TOP 1 @TargetSno = s.snumber 
    FROM specialization s 
    LEFT JOIN doctor d ON s.snumber = d.sno 
    GROUP BY s.snumber 
    ORDER BY COUNT(d.ssn) ASC;
    
    SELECT @NewSup = mgrssn FROM specialization WHERE snumber = @TargetSno;
    UPDATE doctor SET sno = @TargetSno, superssn = @NewSup WHERE ssn = @DocSSN;
END;
GO

-- Q7
CREATE PROCEDURE sp_RedistributeSurgeryHours AS
BEGIN
    DECLARE @ssn CHAR(9), @sno INT, @reduced DECIMAL(10,2), @others INT;
    DECLARE cur CURSOR FOR SELECT essn, sno, hours * 0.2 FROM performed_by WHERE hours > 30;
    OPEN cur;
    FETCH NEXT FROM cur INTO @ssn, @sno, @reduced;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @others = COUNT(*) FROM performed_by WHERE sno = @sno AND essn <> @ssn;
        IF @others > 0
        BEGIN
            UPDATE performed_by SET hours = hours - @reduced WHERE essn = @ssn AND sno = @sno;
            UPDATE performed_by SET hours = hours + (@reduced / @others) WHERE sno = @sno AND essn <> @ssn;
        END
        FETCH NEXT FROM cur INTO @ssn, @sno, @reduced;
    END;
    CLOSE cur; DEALLOCATE cur;
END;
GO

-- Q8
CREATE PROCEDURE sp_FixSupervisorCycles AS
BEGIN
    UPDATE d1 SET d1.superssn = NULL 
    FROM doctor d1 
    JOIN doctor d2 ON d1.superssn = d2.ssn 
    WHERE d2.superssn = d1.ssn;
END;
GO

-- Q9
CREATE PROCEDURE sp_ReplaceManager @SpecNo INT, @NewMgrSSN CHAR(9) AS
BEGIN
    DECLARE @OldMgr CHAR(9);
    SELECT @OldMgr = mgrssn FROM specialization WHERE snumber = @SpecNo;
    UPDATE specialization SET mgrssn = @NewMgrSSN WHERE snumber = @SpecNo;
    UPDATE doctor SET superssn = @NewMgrSSN WHERE sno = @SpecNo AND superssn = @OldMgr;
END;
GO

-- Q10
CREATE PROCEDURE sp_DeleteDoctorCascade @TargetSSN CHAR(9) AS
BEGIN
    DECLARE @Sup CHAR(9), @Sno INT, @Repl CHAR(9);
    SELECT @Sup = superssn, @Sno = sno FROM doctor WHERE ssn = @TargetSSN;
    UPDATE dependent SET essn = @Sup WHERE essn = @TargetSSN;
    SELECT TOP 1 @Repl = ssn FROM doctor WHERE sno = @Sno AND ssn <> @TargetSSN;
    UPDATE performed_by SET essn = @Repl WHERE essn = @TargetSSN;
    IF EXISTS (SELECT 1 FROM specialization WHERE mgrssn = @TargetSSN)
        EXEC sp_ReplaceManager @Sno, @Repl;
    DELETE FROM doctor WHERE ssn = @TargetSSN;
END;
GO

-- Q11
CREATE VIEW v_DoctorRanking AS
SELECT essn, sno, TotalHours, DENSE_RANK() OVER(PARTITION BY sno ORDER BY TotalHours DESC) as rnk
FROM (SELECT essn, d.sno, SUM(hours) as TotalHours FROM performed_by pb JOIN doctor d ON pb.essn = d.ssn GROUP BY essn, d.sno) t;
GO

CREATE PROCEDURE sp_RewardTopDoctors AS
BEGIN
    UPDATE doctor SET salary = salary * 1.15 WHERE ssn IN (SELECT essn FROM v_DoctorRanking WHERE rnk <= 2);
END;
GO

-- Q12
CREATE VIEW v_LocationViolations AS
SELECT * FROM v_InvalidSurgeryLocations WHERE Status = 'INVALID';
GO

CREATE PROCEDURE sp_FixLocations AS
BEGIN
    UPDATE s SET s.slocation = sl.slocation
    FROM surgery s CROSS APPLY (SELECT TOP 1 slocation FROM spec_locations WHERE snumber = s.snum) sl
    WHERE s.sname IN (SELECT SurgeryName FROM v_LocationViolations);
END;
GO

-- Q13
CREATE VIEW v_WorkloadStats AS
SELECT sno, AVG(TotalHours) as AvgWorkload 
FROM (SELECT essn, d.sno, SUM(hours) as TotalHours FROM performed_by pb JOIN doctor d ON pb.essn = d.ssn GROUP BY essn, d.sno) t 
GROUP BY sno;
GO

CREATE PROCEDURE sp_NormalizeWorkload @Threshold DECIMAL(10,2) AS
BEGIN
    UPDATE pb SET hours = hours * 0.95 
    FROM performed_by pb 
    JOIN doctor d ON pb.essn = d.ssn 
    JOIN v_WorkloadStats vs ON d.sno = vs.sno
    WHERE pb.hours > vs.AvgWorkload + @Threshold;
END;
GO

-- Q14
CREATE PROCEDURE sp_RecommendHiring AS
BEGIN
    SELECT s.sname, ISNULL(d.cnt, 0) as DocCount, ws.AvgWorkload
    FROM specialization s
    LEFT JOIN (SELECT sno, COUNT(*) as cnt FROM doctor GROUP BY sno) d ON s.snumber = d.sno
    LEFT JOIN v_WorkloadStats ws ON s.snumber = ws.sno
    WHERE ISNULL(d.cnt, 0) < 2 OR ws.AvgWorkload > 25;
END;
GO

-- Q15
CREATE PROCEDURE sp_EnforceSalaryRules AS
BEGIN
    UPDATE m SET m.salary = (SELECT MAX(salary) FROM doctor WHERE superssn = m.ssn)
    FROM doctor m 
    WHERE EXISTS (SELECT 1 FROM doctor s WHERE s.superssn = m.ssn AND s.salary > m.salary);
END;
GO