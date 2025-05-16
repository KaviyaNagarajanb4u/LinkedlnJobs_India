USE HR;

SELECT*FROM [Human Resources (1)];

select termdate 
from [Human Resources (1)]
order by termdate DESC;

update [Human Resources (1)]
set termdate=format(convert(datetime,left(termdate,19),120),'yyyy-mm-dd');

alter Table [Human Resources (1)]
add new_termdate date;

--copy converted values to new_termdate--

update [Human Resources (1)]
set new_termdate = case
 when termdate is not null and ISDATE(termdate)=1 then cast(termdate as datetime)else null end;


--add new column for age--

alter table [Human Resources (1)]
add age nvarchar(50);

update [Human Resources (1)]
set age=DATEDIFF(year,birthdate,GETDATE());


select age
from [Human Resources (1)];

---age distribution in the company--

select 
MIN (age) as youngest,
MAX (age) as oldest
from [Human Resources (1)];

--age group by gender--
select age from [Human Resources (1)]
order by age;




--Age group distribution----

SELECT 
    age_group,

    COUNT(*) AS count
FROM (
    SELECT 
        CASE 
            WHEN age <= 30 THEN '21 to 30'
            WHEN age <= 40 THEN '31 to 40'
            WHEN age <= 50 THEN '41 to 50'
            ELSE '50+'
        END AS age_group
		
    FROM [Human Resources (1)]
    WHERE new_termdate IS NULL
) AS subquery
GROUP BY age_group
ORDER BY age_group;

--Age group by gender----

SELECT 
    age_group,gender,

    COUNT(*) AS count
FROM (
    SELECT 
        CASE 
            WHEN age <= 30 THEN '21 to 30'
            WHEN age <= 40 THEN '31 to 40'
            WHEN age <= 50 THEN '41 to 50'
            ELSE '50+'
        END AS age_group,gender
		
    FROM [Human Resources (1)]
    WHERE new_termdate IS NULL
) AS subquery
GROUP BY age_group,gender
ORDER BY age_group,gender;

--Gender breakdown in the company--


select gender,
count(gender)as count
from [Human Resources (1)]
where new_termdate is null
group by gender
order by gender ASC;

--Gender vary across department and job title---

select department,gender,
count(gender)as count
from [Human Resources (1)]
where new_termdate is null
group by department,gender
order by department,gender ASC;

---Job title---

select department,jobtitle,gender,
count(gender)as count
from [Human Resources (1)]
where new_termdate is null
group by department,jobtitle,gender
order by department,jobtitle,gender ASC;

----race count---

select race,
count(*)as count
from [Human Resources (1)]
where new_termdate is null
group by race
order by count DESC;

--average length of employment---

select AVG
(DATEDIFF(YEAR,hire_date,new_termdate)) as tenure
from [Human Resources (1)]
where new_termdate is not null and new_termdate<=getdate();


--highest turnover rate----

select department,
total_count,
terminated_count,
round((cast(terminated_count as float)/total_count),2)*100 as turnover_rate
from 
(select department,
count(*) as total_count,
sum (case 
when new_termdate is not null and new_termdate<=getdate() then 1 else 0
end)
as terminated_count
from [Human Resources (1)]
group by department)
as subquery
order by turnover_rate desc;

--tenure distribution of each department--


select department,
AVG
(DATEDIFF(YEAR,hire_date,new_termdate)) as tenure
from [Human Resources (1)]
where new_termdate is not null and new_termdate<=getdate()
group by department
order by tenure desc;


--employees work for each department

select location,
count(*)as count
from [Human Resources (1)]
where new_termdate is null
group by location;

--distribution of employees across different states--

select location_state,
count(*)as count
from [Human Resources (1)]
where new_termdate is null
group by location_state
order by count desc;

----job title distributed in the company

select jobtitle,
count(*) as count
from [Human Resources (1)]
where new_termdate is null
group by jobtitle
order by count desc;

--employee hire counts varied over time--

SELECT 
    YEAR(hire_date) AS hire_year,
    COUNT(*) AS hires,
    SUM(CASE 
            WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1
            ELSE 0
        END) AS terminations
FROM [Human Resources (1)]
GROUP BY YEAR(hire_date);


---calculate hires/termainations,hires percent hire change--
 select
 hire_year,hires,terminations,
 hires-terminations as net_change,
(round(cast(hires-terminations as float)/hires,2))*100 as percent_hire_change
 from(
 SELECT 
    YEAR(hire_date) AS hire_year,
    COUNT(*) AS hires,
    SUM(CASE 
            WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1
            ELSE 0
        END) AS terminations
FROM [Human Resources (1)]
GROUP BY YEAR(hire_date)
)as subquery
order by percent_hire_change asc;








