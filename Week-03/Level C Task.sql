--Aditya kumar

--TASK 1
IF OBJECT_ID('dbo.Projects', 'U') IS NOT NULL
    DROP TABLE dbo.Projects;
CREATE TABLE Projects (
    Task_ID INT,
    Start_Date DATE,
    End_Date DATE
);
INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

-- Step 4: Run the main query to find the start and end dates of projects
WITH NumberedTasks AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        LAG(End_Date) OVER (ORDER BY Start_Date) AS Prev_End_Date
    FROM Projects
),
ProjectGroups AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        CASE 
            WHEN Prev_End_Date IS NULL OR DATEDIFF(day, Prev_End_Date, Start_Date) > 1 THEN 1
            ELSE 0
        END AS IsNewProject
    FROM NumberedTasks
),
RunningTotal AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        SUM(IsNewProject) OVER (ORDER BY Start_Date ROWS UNBOUNDED PRECEDING) AS ProjectGroup
    FROM ProjectGroups
),
GroupedProjects AS (
    SELECT
        MIN(Start_Date) AS ProjectStartDate,
        MAX(End_Date) AS ProjectEndDate,
        DATEDIFF(day, MIN(Start_Date), MAX(End_Date)) AS ProjectDuration
    FROM RunningTotal
    GROUP BY ProjectGroup
)
SELECT
    ProjectStartDate,
    ProjectEndDate
FROM GroupedProjects
ORDER BY
    ProjectDuration,
    ProjectStartDate;


--Task 2

CREATE TABLE Students (
    ID INT,
    Name VARCHAR(50)
);

CREATE TABLE Friends (
    ID INT,
    Friend_ID INT
);

CREATE TABLE Packages (
    ID INT,
    Salary FLOAT
);

INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

-- SQL Query to get the names of students whose best friends have a higher salary
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON f.Friend_ID = p1.ID
JOIN Packages p2 ON s.ID = p2.ID
WHERE p1.Salary > p2.Salary
ORDER BY p1.Salary;


--Task 3
-- Drop the table if it exists
IF OBJECT_ID('Functions', 'U') IS NOT NULL
    DROP TABLE Functions;

-- Create the Functions table
CREATE TABLE Functions (
    X INTEGER,
    Y INTEGER
);

-- Insert sample data into the Functions table
INSERT INTO Functions (X, Y) VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);

-- Query to find symmetric pairs
SELECT DISTINCT f1.X, f1.Y
FROM Functions f1
JOIN Functions f2 ON f1.X = f2.Y AND f1.Y = f2.X
WHERE f1.X <= f1.Y -- Optional: To ensure (X, Y) is considered same as (Y, X)
ORDER BY f1.X;


--Task 4

CREATE TABLE Contests (
    contest_id INTEGER,
    hacker_id INTEGER,
    name VARCHAR(50)
);

INSERT INTO Contests (contest_id, hacker_id, name)
VALUES 
    (66406, 17973, 'Rose'),
    (66556, 79153, 'Angela'),
    (94828, 80275, 'Frank');

CREATE TABLE Colleges (
    college_id INTEGER,
    contest_id INTEGER
);

INSERT INTO Colleges (college_id, contest_id)
VALUES 
    (11219, 66406),
    (32473, 66556),
    (56685, 94828);

CREATE TABLE Challenges (
    challenge_id INTEGER,
    college_id INTEGER
);

INSERT INTO Challenges (challenge_id, college_id)
VALUES 
    (18765, 11219),
    (47127, 11219),
    (60292, 32473),
    (72974, 56685);

CREATE TABLE View_Stats (
    challenge_id INTEGER,
    total_views INTEGER,
    total_unique_views INTEGER
);

INSERT INTO View_Stats (challenge_id, total_views, total_unique_views)
VALUES 
    (47127, 26, 19),
    (47127, 15, 14),
    (18765, 43, 10),
    (18765, 72, 13),
	(75516, 35, 17),
    (60292, 11, 10),
    (72974, 41, 15),
    (75516, 75, 11);

CREATE TABLE Submission_Stats (
    challenge_id INTEGER,
    total_submissions INTEGER,
    total_accepted_submissions INTEGER
);

INSERT INTO Submission_Stats (challenge_id, total_submissions, total_accepted_submissions)
VALUES 
    (75516, 34, 12),
    (47127, 27, 10),
    (47127, 56, 18),
    (75516, 74, 12),
    (75516, 83, 8),
    (72974, 68, 24),
    (72974, 82, 14),
    (47127, 28, 11);

-- Query to retrieve the desired output
SELECT 
    c.contest_id,
    c.hacker_id,
    c.name,
    COALESCE(SUM(s.total_submissions), 0) AS total_submissions,
    COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions,
    COALESCE(SUM(v.total_views), 0) AS total_views,
    COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views
FROM Contests c
JOIN Colleges cl ON c.contest_id = cl.contest_id
JOIN Challenges ch ON cl.college_id = ch.college_id
LEFT JOIN Submission_Stats s ON ch.challenge_id = s.challenge_id
LEFT JOIN View_Stats v ON ch.challenge_id = v.challenge_id
GROUP BY c.contest_id, c.hacker_id, c.name
HAVING 
    COALESCE(SUM(s.total_submissions), 0) <> 0 OR
    COALESCE(SUM(s.total_accepted_submissions), 0) <> 0 OR
    COALESCE(SUM(v.total_views), 0) <> 0 OR
    COALESCE(SUM(v.total_unique_views), 0) <> 0
ORDER BY c.contest_id;

--Task 5

CREATE TABLE Hackers (
    hacker_id INTEGER,
    name VARCHAR(50)
);

INSERT INTO Hackers (hacker_id, name)
VALUES 
    (15758, 'Rose'),
    (20703, 'Angela'),
    (36396, 'Frank'),
    (38289, 'Patrick'),
    (44065, 'Lisa'),
    (53473, 'Kimberly'),
    (62529, 'Bonnie'),
    (79722, 'Michael');

CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INTEGER,
    hacker_id INTEGER,
    score INTEGER
);

INSERT INTO Submissions (submission_date, submission_id, hacker_id, score)
VALUES 
    ('2016-03-01', 8494, 20703, 0),
    ('2016-03-01', 22403, 53473, 15),
    ('2016-03-01', 23965, 79722, 60),
    ('2016-03-01', 30173, 36396, 70),
    ('2016-03-02', 34928, 20703, 0),
    ('2016-03-02', 38740, 15758, 60),
    ('2016-03-02', 42769, 79722, 25),
    ('2016-03-02', 44364, 79722, 60),
    ('2016-03-03', 45440, 20703, 0),
    ('2016-03-03', 49050, 36396, 70),
    ('2016-03-03', 50273, 79722, 5),
    ('2016-03-04', 50344, 20703, 0),
    ('2016-03-04', 51360, 44065, 90),
    ('2016-03-04', 54404, 53473, 65),
    ('2016-03-04', 61533, 79722, 45),
    ('2016-03-05', 72852, 20703, 0),
    ('2016-03-05', 74546, 38289, 0),
    ('2016-03-05', 76487, 62529, 0),
    ('2016-03-05', 82439, 36396, 10),
    ('2016-03-05', 90006, 36396, 40),
    ('2016-03-06', 90404, 20703, 0);

-- Query to retrieve the desired output
WITH SubmissionCounts AS (
    SELECT 
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers,
        MAX(total_submissions) AS max_submissions
    FROM (
        SELECT 
            submission_date,
            hacker_id,
            COUNT(*) AS total_submissions,
            ROW_NUMBER() OVER (PARTITION BY submission_date ORDER BY COUNT(*) DESC, hacker_id ASC) AS rn
        FROM Submissions
        WHERE submission_date >= '2016-03-01' AND submission_date <= '2016-03-15'
        GROUP BY submission_date, hacker_id
    ) AS sub_counts
    WHERE rn = 1
    GROUP BY submission_date
)

SELECT 
    sc.submission_date,
    sc.unique_hackers,
    h.hacker_id,
    h.name
FROM SubmissionCounts sc
JOIN (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(*) AS total_submissions,
        ROW_NUMBER() OVER (PARTITION BY submission_date ORDER BY COUNT(*) DESC, hacker_id ASC) AS rn
    FROM Submissions
    WHERE submission_date >= '2016-03-01' AND submission_date <= '2016-03-15'
    GROUP BY submission_date, hacker_id
) AS max_sub_counts ON sc.submission_date = max_sub_counts.submission_date AND max_sub_counts.rn = 1
JOIN Hackers h ON max_sub_counts.hacker_id = h.hacker_id
ORDER BY sc.submission_date;


--Task 6
-- Create STATION table
CREATE TABLE STATION (
    ID INT,
    CITY VARCHAR(50),
    STATE VARCHAR(2),
    LAT_N FLOAT,
    LONG_W FLOAT
);

-- Insert sample data
INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES
(1, 'New York', 'NY', 40.7128, -74.0060),
(2, 'Los Angeles', 'CA', 34.0522, -118.2437),
(3, 'Chicago', 'IL', 41.8781, -87.6298),
(4, 'Houston', 'TX', 29.7604, -95.3698),
(5, 'Phoenix', 'AZ', 33.4484, -112.0740);

-- Query to compute Manhattan Distance between New York (ID = 1) and Los Angeles (ID = 2)
SELECT ROUND(ABS(P1.LAT_N - P2.LAT_N) + ABS(P1.LONG_W - P2.LONG_W), 4) AS Manhattan_Distance
FROM STATION P1
CROSS JOIN STATION P2
WHERE P1.ID = 1
  AND P2.ID = 2;
  

--Task 7
-- Generate numbers from 2 to 1000
WITH Numbers AS (
    SELECT number
    FROM (
        VALUES (2), (3), (5), (7), (11), (13), (17), (19), (23), (29),
               (31), (37), (41), (43), (47), (53), (59), (61), (67), (71),
               (73), (79), (83), (89), (97), (101), (103), (107), (109), (113),
               (127), (131), (137), (139), (149), (151), (157), (163), (167), (173),
               (179), (181), (191), (193), (197), (199), (211), (223), (227), (229),
               (233), (239), (241), (251), (257), (263), (269), (271), (277), (281),
               (283), (293), (307), (311), (313), (317), (331), (337), (347), (349),
               (353), (359), (367), (373), (379), (383), (389), (397), (401), (409),
               (419), (421), (431), (433), (439), (443), (449), (457), (461), (463),
               (467), (479), (487), (491), (499), (503), (509), (521), (523), (541),
               (547), (557), (563), (569), (571), (577), (587), (593), (599), (601),
               (607), (613), (617), (619), (631), (641), (643), (647), (653), (659),
               (661), (673), (677), (683), (691), (701), (709), (719), (727), (733),
               (739), (743), (751), (757), (761), (769), (773), (787), (797), (809),
               (811), (821), (823), (827), (829), (839), (853), (857), (859), (863),
               (877), (881), (883), (887), (907), (911), (919), (929), (937), (941),
               (947), (953), (967), (971), (977), (983), (991), (997)
    ) AS Numbers(number)
),
-- Find primes using the Sieve of Eratosthenes method
Primes AS (
    SELECT number, ROW_NUMBER() OVER (ORDER BY number) AS rn
    FROM Numbers
)
SELECT STRING_AGG(CONVERT(VARCHAR(10), number), '&') AS PrimeNumbers
FROM Primes
WHERE number <= 1000;


--Task 8
-- Create OCCUPATIONS table
CREATE TABLE OCCUPATIONS (
    Name VARCHAR(50),
    Occupation VARCHAR(50)
);

-- Insert sample data
INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashley', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');

-- Pivot query to display names under each occupation
WITH Numbered AS (
    SELECT 
        Name, 
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
)
SELECT 
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM Numbered
GROUP BY rn
ORDER BY rn;


--Task 9

CREATE TABLE BST (
    N Integer,
    P Integer
);

INSERT INTO BST (N, P) VALUES
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, null),
(5, 2),
(8, 5);

-- Query to find node types
WITH NodeTypes AS (
    SELECT
        N,
        CASE
            WHEN P IS NULL THEN 'Root'
            WHEN N IN (SELECT P FROM BST) THEN 'Inner'
            ELSE 'Leaf'
        END AS NodeType
    FROM BST
)
SELECT N, NodeType
FROM NodeTypes
ORDER BY N;


--Task 10
-- Create and populate the tables
CREATE TABLE Company (
    company_code VARCHAR(10),
    founder VARCHAR(50)
);

INSERT INTO Company (company_code, founder) VALUES
('C1', 'Monika'),
('C2', 'Samantha');

CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Lead_Manager (lead_manager_code, company_code) VALUES
('LM1', 'C1'),
('LM2', 'C2');

CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Senior_Manager (senior_manager_code, lead_manager_code, company_code) VALUES
('SM1', 'LM1', 'C1'),
('SM2', 'LM1', 'C1'),
('SM3', 'LM2', 'C2');

CREATE TABLE Manager (
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Manager (manager_code, senior_manager_code, lead_manager_code, company_code) VALUES
('M1', 'SM1', 'LM1', 'C1'),
('M2', 'SM3', 'LM2', 'C2'),
('M3', 'SM3', 'LM2', 'C2');

CREATE TABLE Employee (
    employee_code VARCHAR(10),
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

INSERT INTO Employee (employee_code, manager_code, senior_manager_code, lead_manager_code, company_code) VALUES
('E1', 'M1', 'SM1', 'LM1', 'C1'),
('E2', 'M1', 'SM1', 'LM1', 'C1'),
('E3', 'M2', 'SM3', 'LM2', 'C2'),
('E4', 'M3', 'SM3', 'LM2', 'C2');

-- Query to retrieve the required output
WITH Counts AS (
    SELECT 
        c.company_code,
        c.founder,
        COUNT(DISTINCT lm.lead_manager_code) AS num_lead_managers,
        COUNT(DISTINCT sm.senior_manager_code) AS num_senior_managers,
        COUNT(DISTINCT m.manager_code) AS num_managers,
        COUNT(DISTINCT e.employee_code) AS num_employees
    FROM Company c
    LEFT JOIN Lead_Manager lm ON c.company_code = lm.company_code
    LEFT JOIN Senior_Manager sm ON lm.lead_manager_code = sm.lead_manager_code AND c.company_code = sm.company_code
    LEFT JOIN Manager m ON sm.senior_manager_code = m.senior_manager_code AND lm.lead_manager_code = m.lead_manager_code AND c.company_code = m.company_code
    LEFT JOIN Employee e ON m.manager_code = e.manager_code AND sm.senior_manager_code = e.senior_manager_code AND lm.lead_manager_code = e.lead_manager_code AND c.company_code = e.company_code
    GROUP BY c.company_code, c.founder
)
SELECT 
    company_code,
    founder,
    COALESCE(num_lead_managers, 0) AS total_lead_managers,
    COALESCE(num_senior_managers, 0) AS total_senior_managers,
    COALESCE(num_managers, 0) AS total_managers,
    COALESCE(num_employees, 0) AS total_employees
FROM Counts
ORDER BY company_code;


--Task 11
IF OBJECT_ID('Students','U') IS NOT NULL
DROP TABLE Students;
-- Create and populate the tables
CREATE TABLE Students (
    ID Integer,
    Name VARCHAR(50)
);

INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');
IF OBJECT_ID('Friends','U') IS NOT NULL
DROP TABLE Friends;
CREATE TABLE Friends (
    ID Integer,
    Friend_ID Integer
);

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);
IF OBJECT_ID('Packages','U') IS NOT NULL
DROP TABLE Packages;
CREATE TABLE Packages (
    ID Integer,
    Salary Float
);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

-- Query to retrieve names of students whose friends have higher salary offers
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages sp ON f.Friend_ID = sp.ID
JOIN Packages sp_self ON s.ID = sp_self.ID
WHERE sp.Salary > sp_self.Salary
ORDER BY sp.Salary;


--Task 12
CREATE TABLE SimulationData (
    JobFamily VARCHAR(50),
    Location VARCHAR(50),
    Cost FLOAT
);
INSERT INTO SimulationData (JobFamily, Location, Cost) VALUES
('Engineering', 'India', 5000),
('Engineering', 'International', 8000),
('Sales', 'India', 3000),
('Sales', 'International', 4000),
('Marketing', 'India', 2000),
('Marketing', 'International', 3000),
('HR', 'India', 1500),
('HR', 'International', 2000);
WITH JobFamilyCosts AS (
    SELECT
        JobFamily,
        Location,
        SUM(Cost) AS TotalCost
    FROM SimulationData
    WHERE Location IN ('India', 'International')
    GROUP BY JobFamily, Location
),
TotalCosts AS (
    SELECT
        JobFamily,
        SUM(CASE WHEN Location = 'India' THEN TotalCost ELSE 0 END) AS TotalCostIndia,
        SUM(CASE WHEN Location = 'International' THEN TotalCost ELSE 0 END) AS TotalCostInternational
    FROM JobFamilyCosts
    GROUP BY JobFamily
)
SELECT
    JobFamily,
    ROUND(TotalCostIndia / NULLIF(TotalCostIndia + TotalCostInternational, 0) * 100, 2) AS IndiaPercentage,
    ROUND(TotalCostInternational / NULLIF(TotalCostIndia + TotalCostInternational, 0) * 100, 2) AS InternationalPercentage
FROM TotalCosts
ORDER BY JobFamily;


--Task 13
IF OBJECT_ID('BusinessUnitCost','U') IS NOT NULL
DROP TABLE BusinessUnitCost;
-- Create BusinessUnitCost table
CREATE TABLE BusinessUnitCost (
    BU VARCHAR(50),
    Month DATE,
    Cost FLOAT
);
IF OBJECT_ID('BusinessUnitRevenue','U') IS NOT NULL
DROP TABLE BusinessUnitRevenue;
-- Create BusinessUnitRevenue table
CREATE TABLE BusinessUnitRevenue (
    BU VARCHAR(50),
    Month DATE,
    Revenue FLOAT
);
-- Sample data for BusinessUnitCost
INSERT INTO BusinessUnitCost (BU, Month, Cost) VALUES
('BU1', '2023-01-01', 50000),
('BU1', '2023-02-01', 60000),
('BU1', '2023-03-01', 55000),
('BU2', '2023-01-01', 45000),
('BU2', '2023-02-01', 48000),
('BU2', '2023-03-01', 50000);

-- Sample data for BusinessUnitRevenue
INSERT INTO BusinessUnitRevenue (BU, Month, Revenue) VALUES
('BU1', '2023-01-01', 120000),
('BU1', '2023-02-01', 130000),
('BU1', '2023-03-01', 125000),
('BU2', '2023-01-01', 100000),
('BU2', '2023-02-01', 110000),
('BU2', '2023-03-01', 105000);
WITH CostRevenue AS (
    SELECT
        c.BU,
        c.Month,
        c.Cost,
        r.Revenue,
        ROUND(c.Cost / NULLIF(r.Revenue, 0), 2) AS CostToRevenueRatio
    FROM BusinessUnitCost AS c
    INNER JOIN BusinessUnitRevenue AS r ON c.BU = r.BU AND c.Month = r.Month
)
SELECT
    BU,
    Month,
    Cost,
    Revenue,
    CostToRevenueRatio
FROM CostRevenue
ORDER BY BU, Month;


--Task 14 (Compile this in parts)

IF OBJECT_ID('Employee','U') IS NOT NULL
    DROP TABLE Employee;
CREATE TABLE Employee (
    EmployeeID INT,
    SubBand VARCHAR(10)
);

INSERT INTO Employee (EmployeeID, SubBand) VALUES
(1, 'A'),
(2, 'A'),
(3, 'B'),
(4, 'C'),
(5, 'B'),
(6, 'C'),
(7, 'A'),
(8, 'B'),
(9, 'C'),
(10, 'A');

WITH Headcount AS (
    SELECT
        SubBand,
        COUNT(*) AS TotalCount,
        SUM(COUNT(*)) OVER () AS TotalEmployees
    FROM Employee
    GROUP BY SubBand
)
SELECT
    SubBand,
    TotalCount,
    ROUND(TotalCount * 100.0 / TotalEmployees, 2) AS Percentage
FROM Headcount
ORDER BY SubBand;


--Task 15
CREATE TABLE Employees (
    EmployeeID INT,
    EmployeeName VARCHAR(50),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employees (EmployeeID, EmployeeName, Salary) VALUES
(1, 'John', 50000.00),
(2, 'Jane', 60000.00),
(3, 'Alice', 55000.00),
(4, 'Bob', 62000.00),
(5, 'Carol', 58000.00),
(6, 'David', 53000.00),
(7, 'Eve', 64000.00),
(8, 'Frank', 59000.00),
(9, 'Grace', 57000.00),
(10, 'Henry', 61000.00);
WITH RankedEmployees AS (
    SELECT
        EmployeeID,
        EmployeeName,
        Salary,
        ROW_NUMBER() OVER (ORDER BY Salary DESC) AS Rank
    FROM Employees
)
SELECT TOP 5
    EmployeeID,
    EmployeeName,
    Salary
FROM RankedEmployees
WHERE Rank <= 5;


--Task 16
CREATE TABLE SampleTable (
    Column1 INT,
    Column2 INT
);

INSERT INTO SampleTable (Column1, Column2) VALUES
(10, 20);
-- Before swapping
SELECT * FROM SampleTable;

-- Swap values
UPDATE SampleTable
SET
    Column1 = CASE WHEN Column1 <> Column2 THEN Column2 ELSE Column1 END,
    Column2 = CASE WHEN Column1 <> Column2 THEN Column1 ELSE Column2 END;

-- After swapping
SELECT * FROM SampleTable;


--Task 17
CREATE DATABASE SampleDB;
GO
USE SampleDB;
GO

CREATE LOGIN Ayush WITH PASSWORD = '1234';
CREATE USER Ayush FOR LOGIN Ayush;
GO
USE SampleDB;
GO
ALTER ROLE db_owner ADD MEMBER	Ayush;
GO
USE SampleDB;
GO

-- Check user roles
EXEC sp_helpuser 'Ayush';
GO


--Task 18

CREATE TABLE EmployeeCost (
    EmployeeID INT,
    BU VARCHAR(50),
    Month DATE,
    Cost DECIMAL(10, 2)
);

CREATE TABLE EmployeeHeadcount (
    EmployeeID INT,
    BU VARCHAR(50),
    Month DATE,
    Headcount INT
);

-- Insert sample data into EmployeeCost table
INSERT INTO EmployeeCost (EmployeeID, BU, Month, Cost)
VALUES
    (1, 'BU1', '2023-01-01', 5000),
    (2, 'BU1', '2023-01-01', 6000),
    (3, 'BU1', '2023-01-01', 4500),
    (4, 'BU1', '2023-02-01', 5200),
    (5, 'BU1', '2023-02-01', 6300),
    (6, 'BU1', '2023-02-01', 4800);

-- Insert sample data into EmployeeHeadcount table
INSERT INTO EmployeeHeadcount (EmployeeID, BU, Month, Headcount)
VALUES
    (1, 'BU1', '2023-01-01', 10),
    (2, 'BU1', '2023-01-01', 12),
    (3, 'BU1', '2023-01-01', 9),
    (4, 'BU1', '2023-02-01', 11),
    (5, 'BU1', '2023-02-01', 13),
    (6, 'BU1', '2023-02-01', 10);
-- Calculate weighted average cost month on month for BU1
SELECT
    ec.Month,
    SUM(ec.Cost * eh.Headcount) / SUM(eh.Headcount) AS WeightedAverageCost
FROM
    EmployeeCost ec
INNER JOIN
    EmployeeHeadcount eh ON ec.EmployeeID = eh.EmployeeID AND ec.Month = eh.Month AND ec.BU = eh.BU
WHERE
    ec.BU = 'BU1'
GROUP BY
    ec.Month
ORDER BY
    ec.Month;


--Task 19

IF OBJECT_ID('EMPLOYEES','U') IS NOT NULL
    DROP TABLE EMPLOYEES;
CREATE TABLE EMPLOYEES (
    EmployeeID INT,
    Name VARCHAR(50),
    Salary DECIMAL(10, 2)
);

INSERT INTO EMPLOYEES (EmployeeID, Name, Salary)
VALUES
    (1, 'Alice', 4500.00),
    (2, 'Bob', 3200.00),
    (3, 'Charlie', 5000.00),
    (4, 'David', 3800.00),
    (5, 'Eve', 4200.00),
    (6, 'Frank', 5500.00);

-- Calculate the actual average salary
DECLARE @ActualAvgSalary DECIMAL(10, 2);

SELECT @ActualAvgSalary = ROUND(AVG(Salary), 2)
FROM EMPLOYEES;

-- Calculate the miscalculated average salary (salaries with any zeroes removed)
DECLARE @MiscalculatedAvgSalary DECIMAL(10, 2);

SELECT @MiscalculatedAvgSalary = ROUND(AVG(CAST(REPLACE(CAST(Salary AS VARCHAR), '0', '') AS DECIMAL(10, 2))), 2)
FROM EMPLOYEES;

-- Calculate the difference and round up to the next integer
DECLARE @Difference INT;

SET @Difference = CEILING(@ActualAvgSalary - @MiscalculatedAvgSalary);

-- Output the result
SELECT 
    'Actual Avg Salary' AS Calculation,
    @ActualAvgSalary AS AvgSalary,
    'Miscalculated Avg Salary' AS Miscalculation,
    @MiscalculatedAvgSalary AS MiscalculatedAvgSalary,
    'Difference (rounded up)' AS Difference,
    @Difference AS RoundedDifference;


--Task 20

CREATE TABLE SourceTable (
    ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Age INT
);

INSERT INTO SourceTable (ID, Name, Age)
VALUES
    (1, 'Alice', 25),
    (2, 'Bob', 30),
    (3, 'Charlie', 28);
-- Create DestinationTable (empty initially)
CREATE TABLE DestinationTable (
    ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Age INT
);
-- Copy new data from SourceTable to DestinationTable
INSERT INTO DestinationTable (ID, Name, Age)
SELECT ID, Name, Age
FROM SourceTable src
WHERE NOT EXISTS (
    SELECT 1
    FROM DestinationTable dest
    WHERE dest.ID = src.ID
);
-- Check the contents of DestinationTable
SELECT * FROM DestinationTable;