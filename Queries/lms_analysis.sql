-- PROJECT: Learning Managemanent System Analysis
-- AUTHOR: Lerato Mazibuko

-----------------------------------------------
-- DATA EXPLORATION
-----------------------------------------------
--View table structure
PRAGMA table_info(Students);

-- View data on each table
SELECT *
FROM Students;

SELECT *
FROM Instructors;

SELECT *
FROM Courses;

SELECT *
FROM Enrollments;

SELECT *
FROM Assignments;

SELECT *
FROM Grades;

-- Query displaying the total records on each table
SELECT count(*) as TotalStudents
FROM Students;

SELECT count(*) as TotalInstructors
FROM Instructors;

SELECT count(*) as TotalEnrollments
FROM Enrollments;

SELECT count(*) as TotalCourses
FROM Courses;

SELECT count(*) as TotalAssignments
FROM Assignments;

SELECT count(*) as TotalGrades
FROM Grades;

-- Check NULL values
SELECT *
FROM Students
WHERE studentid is NULL
	or firstname is NULL
    or lastname IS NULL
    or registrationdate is NULL;
    
SELECT * 
FROM Enrollments
WHERE enrollmentdate IS NULL;

-- Check Duplicates
SELECT studentid, COUNT(*) as count
FROM Students
GROUP by studentid
HAVING COUNT(*) > 1;

-- Check inconsistent date format
SELECT studentid , registrationdate
FROM Students
WHERE length(registrationdate) != 10;

------------------------------------------------
-- Data Cleaning
------------------------------------------------
-- Fix date formats
UPDATE Students
set registrationdate = substr(registrationdate, 1, 8) || '0' || substr(registrationdate, 9)
WHERE length(registrationdate)  = 9;

------------------------------------------------
-- Data Validation
------------------------------------------------
-- Ensure that no incorrect date formats remain
SELECT *
FROM Students
WHERE length(registrationdate) != 10;

-- Check logical errors 
SELECT *
FROM Enrollments e
JOIN Students s 
	on e.StudentID = s.StudentID
WHERE e.EnrollmentDate < s.RegistrationDate;

-----------------------------------------------
-- Data transformation
-----------------------------------------------
-- Assign enrollment date bsed on registration month
UPDATE Enrollments
SET EnrollmentDate = (
    CASE strftime('%m', (
        SELECT RegistrationDate 
        FROM Students 
        WHERE Students.StudentID = Enrollments.StudentID
    ))
        WHEN '01' THEN '2024-04-05'
        WHEN '02' THEN '2024-04-15'
        WHEN '03' THEN '2024-04-25'
        ELSE EnrollmentDate
    END
)
WHERE EnrollmentDate IS NULL;

------------------------------------------------
-- Data Analysis
------------------------------------------------
-- Analyze monthly student registration trends

SELECT strftime('%m', registrationdate) as Month,
	COUNT(*) as Total_Registrations
FROM Students
group by Month
ORDER BY Month;

-- Identify peak registration month
SELECT strftime('%m', registrationdate) as Month,
	COUNT(*) as Total_Registrations
FROM Students
GROUP by Month
ORDER by Total_Registrations DESC
;

-- Calculating the average score per course 
SELECT c.CourseID, c.CourseName, ROUND(AVG(g.Score),2) as AverageScore
FROM Courses c
JOIN Assignments a 
ON c.CourseID = a.CourseID
JOIN Grades g 
on a.AssignmentID= g.AssignmentID
GROUP by c.CourseID
ORDER by AverageScore desc;

-- Find Instructors whose students have the highest average score
SELECT i.InstructorID, i.InstructorName, i.Department, ROUND(AVG(g.Score),2) as AverageScore
FROM Instructors i
JOIN Courses c 
ON i.InstructorID = c.InstructorID
JOIN Assignments a 
ON c.CourseID = a.CourseID
JOIN Grades g 
ON a.AssignmentID = g.AssignmentID
GROUP BY i.InstructorID
ORDER BY AverageScore DESC;

-- Average number of days it takes for students to be enrolled
SELECT 
    AVG(julianday(e.EnrollmentDate) - julianday(s.RegistrationDate)) AS AvgEnrollmentDays
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID;

-- Highest,lowest and average scores of students per course
SELECT c.CourseName, ROUND(AVG(g.score),2) AS Avg_Score, MAX(g.Score) AS Highest_Score, MIN(g.Score) AS Lowest_Score   
FROM Grades g
JOIN Assignments a ON g.AssignmentID = a.AssignmentID
JOIN Courses c ON a.CourseID = c.CourseID
GROUP BY c.CourseName;

-- Categorize student performance levels
SELECT s.StudentID, s.FirstName, s.LastName,  ROUND(AVG(g.Score),2) AS AvgScore,
CASE 
WHEN AVG(g.Score) >= 85 THEN 'Excellent'
WHEN AVG(g.Score) >= 70 THEN 'Good'
ELSE 'Needs Improvement'
END AS Performance_Level
FROM Students s
JOIN Grades g ON s.StudentID = g.StudentID
GROUP BY s.StudentID;