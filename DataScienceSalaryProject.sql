-- CREATE A DATABASE 'DataScienceSalariesProject.
-- I created a database that could store our data. This was created in an editor(VS CODE) but with a PostgreSQL extension.
CREATE DATABASE DatascienceSalariesProject;

-- Create Schema
-- A schema, which serves as a subfolder was meant to store the Analysis Tables
CREATE SCHEMA Analysis;

-- Create Table Finaldata into the Schema


CREATE TABLE Analysis.finaldata (
    work_year VARCHAR(50),
    experience_level VARCHAR(50),
    employment_type VARCHAR(100),
    job_title VARCHAR(220),
    job_category VARCHAR(100),
    salary_in_usd INT,
    employee_residence VARCHAR(220),
    job_type VARCHAR(100),
    company_location VARCHAR(220),
    company_size VARCHAR(100),
    years_of_experience INT
);

-- Importing csv file into our table

-- Above step completed in postgres(PGADMIN)

-- Preview The Data

SELECT *
FROM analysis.finaldata;

-- Maximum Salary
-- Aggregate function: This query returns the maximum salary in the data field

SELECT MAX(salary_in_usd) AS max_salary
FROM analysis.finaldata; -- 800,000 usd

-- Min Salary: This shows us the minimum salary in the data field according to our dataset.
SELECT MIN(salary_in_usd) AS min_salary
FROM analysis.finaldata; -- 15000 usd

-- Jobs with the lowest Salary ( 15000USD)
-- We're now able to view the job_title,
SELECT job_title,employment_type,years_of_experience
FROM analysis.finaldata
WHERE salary_in_usd=15000; -- data analyst, bi developer, ml developer  & all fulltime with over 3 yrs of experience

-- Checking for Missing Values
-- The query below checks for missing values.

SELECT job_category, COUNT(*) AS no_count
FROM analysis.finaldata
WHERE salary_in_usd IS NULL
GROUP BY job_category; -- No missing values!

-- SALARY DISTRIBUTION ANALYSIS

-- Average Salary by Job_Category
-- Identifies the highest and lowest paying roles

SELECT job_category, ROUND(AVG(salary_in_usd), 2) AS avg_salary
FROM analysis.finaldata
GROUP BY job_category
ORDER BY avg_salary DESC; -- AI & ML - Highest with avg of 183,855 USD and Data Analysis with avg of 116,525.00 USD

-- Salary Distribution by Experience Level
-- Shows the differene in salary between 

SELECT experience_level, 
       ROUND(AVG(salary_in_usd), 2) AS avg_salary, 
       MIN(salary_in_usd) AS min_salary, 
       MAX(salary_in_usd) AS max_salary
FROM analysis.finaldata
GROUP BY experience_level
ORDER BY avg_salary DESC; -- Expert level leads, senior,middle,entry

-- Salary Distribution by Years of Experience

SELECT years_of_experience, 
       ROUND(AVG(salary_in_usd), 2) AS avg_salary, 
       MIN(salary_in_usd) AS min_salary, 
       MAX(salary_in_usd) AS max_salary
FROM analysis.finaldata
GROUP BY years_of_experience
ORDER BY avg_salary DESC; -- 2 yrs of experience attracted highest salary while, 1, 3, 5, 4

-- Salary Trend Over Time

SELECT work_year AS year, 
       ROUND(AVG(salary_in_usd), 2) AS avg_salary
FROM analysis.finaldata
GROUP BY work_year
ORDER BY work_year; -- 2020-2021-2022-2023-2024(increasing)


-- Top-Paying Locations for Data Aficionados
SELECT company_location, 
       ROUND(AVG(salary_in_usd), 2) AS avg_salary
FROM analysis.finaldata
GROUP BY company_location
ORDER BY avg_salary DESC
LIMIT 10; -- GA had the highest pay(300,000USD) followed by IL(217,332USD)

-- Salary by Job Type
-- To check if remote jobs pays well compared to onsite

SELECT job_type, 
       ROUND(AVG(salary_in_usd), 2) AS avg_salary
FROM analysis.finaldata
GROUP BY job_type
ORDER BY avg_salary DESC; -- On-site had the highest avg salary across all job types(153847.45USD) and Hybrid having the lowest(83056.98)

-- Average Salary by Company_Size

SELECT company_size, 
       ROUND(AVG(salary_in_usd), 2) AS avg_salary
FROM analysis.finaldata
GROUP BY company_size
ORDER BY avg_salary DESC; -- Medium sized companies pay the highest(151450.54) and Small companies paying the least with 86614.57

-- Top 10 Earners
-- Introducing sub queries

SELECT * FROM analysis.finaldata
WHERE salary_in_usd > (
    SELECT percentile_cont(0.95) 
    WITHIN GROUP (ORDER BY salary_in_usd) 
    FROM analysis.finaldata
)
ORDER BY salary_in_usd DESC
LIMIT 10;


-- Bottom 10 Earners

SELECT * FROM analysis.finaldata
WHERE salary_in_usd < (
    SELECT percentile_cont(0.05) 
    WITHIN GROUP (ORDER BY salary_in_usd) 
    FROM analysis.finaldata
)
ORDER BY salary_in_usd ASC
LIMIT 10;

-- Rank sales by job category and corresponding salary for each job title
-- Window Function
SELECT job_category,job_title,salary_in_usd,
       RANK() OVER (PARTITION BY job_category ORDER BY salary_in_usd DESC) AS salary_rank
FROM analysis.finaldata;

-- Difference between each job_title's salary and the average salary in the job category
-- Window Function
SELECT job_title, job_category, salary_in_usd, 
       ROUND(AVG(salary_in_usd) OVER (PARTITION BY job_category), 2) AS avg_salary_per_role,
       salary_in_usd - AVG(salary_in_usd) OVER (PARTITION BY job_category) AS salary_difference
FROM analysis.finaldata;

-- Grouping jobs with respective salary bracket( low,medium, high)
-- CASE Statemts
SELECT job_title, salary_in_usd, 
       CASE 
           WHEN salary_in_usd < 100000 THEN 'Low'
           WHEN salary_in_usd BETWEEN 100000 AND 500000 THEN 'Medium'
           ELSE 'High'
       END AS salary_category
FROM analysis.finaldata;

