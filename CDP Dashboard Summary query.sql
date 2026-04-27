--Part 1: Insurance Quotes with cdpname and sales lead
SELECT 
createdon,
YEAR(createdon) 'Quote_Year', 
MONTH(createdon) 'Quote_Month', 
COUNT(DISTINCT new_insurancequoteid) 'Quote_Count',
ae.EmployeeLastName,
emp.shortname
FROM curated_dataverse.new_insurancequote iq
INNER JOIN data_marts.AgencyEmployees ae
ON ae.DataverseEmployeeId = iq.createdby
LEFT JOIN curated_ams.afw_employee emp
ON ae.AgencyEmployeeId = emp.empid
WHERE (ae.employeeType = 'Business Development Associate')
AND ae.AgencyId IN ('0001','0054')
AND YEAR(createdon) >=2025
GROUP BY createdon, YEAR(createdon), MONTH(createdon), ae.EmployeeLastName, emp.shortname







--Part 2: NBS with cdpname and sales lead
WITH AnnualCheckIn_Employees AS (
    SELECT 
        e.AgencyEmployeeId,
        e.AgencyId,
        e.EmployeeLastName,
        emp.shortname,
        e.EmployeeType,
        CASE 
            WHEN (e.EmployeeType = 'Business Development Associate')
                 AND e.AgencyID IN ('0001', '0054')
            THEN 1 ELSE 0
        END AS AnnualCheckIn_Flag
    FROM data_marts.AgencyEmployees e
    LEFT JOIN curated_ams.afw_employee emp
        ON e.AgencyEmployeeId = emp.empid
),
AnnualCheckIn_Policies AS (
    SELECT 
        p.PolicyId,
        p.PolicyEnteredDate,
        p.ProducerId,
        e.AgencyEmployeeId,
        e.AgencyId,
        e.EmployeeLastName,
        e.shortname,
        p.[FirstPolicyTransactionType]
    FROM data_marts.Policies_V2 p
    INNER JOIN AnnualCheckIn_Employees e
        ON e.AgencyEmployeeId = p.ProducerId
    WHERE e.AnnualCheckIn_Flag = 1
      AND YEAR(p.PolicyEnteredDate) >= 2025
)
SELECT 
	ap.PolicyEnteredDate,
    YEAR(ap.PolicyEnteredDate) AS PolicyYear,
    MONTH(ap.PolicyEnteredDate) AS PolicyMonth,
    COUNT(DISTINCT ap.PolicyId) AS AnnualCheckIn_NBS_Shells,
    ap.EmployeeLastName,
    ap.shortname
FROM AnnualCheckIn_Policies ap
WHERE ap.[FirstPolicyTransactionType] = 'New Business'
GROUP BY ap.PolicyEnteredDate, YEAR(ap.PolicyEnteredDate), MONTH(ap.PolicyEnteredDate), ap.EmployeeLastName, ap.shortname
ORDER BY PolicyYear, PolicyMonth;





--Part 3: REW with cdpname and sales lead
WITH AnnualCheckIn_Employees AS (
    SELECT 
        e.AgencyEmployeeId,
        e.AgencyId,
        e.EmployeeLastName,
        emp.shortname,
        e.EmployeeType,
        CASE 
            WHEN (e.EmployeeType = 'Business Development Associate')
                 AND e.AgencyID IN ('0001', '0054')
            THEN 1 ELSE 0
        END AS AnnualCheckIn_Flag
    FROM data_marts.AgencyEmployees e
    LEFT JOIN curated_ams.afw_employee emp
        ON e.AgencyEmployeeId = emp.empid
),
AnnualCheckIn_Policies AS (
    SELECT 
        p.PolicyId,
        p.PolicyEnteredDate,
        p.ProducerId,
        e.AgencyEmployeeId,
        e.AgencyId,
        e.EmployeeLastName,
        e.shortname,
        p.PolicyTransactionType,
		p.[FirstPolicyTransactionType]
    FROM data_marts.Policies_V2 p
    INNER JOIN AnnualCheckIn_Employees e
        ON e.AgencyEmployeeId = p.ProducerId
    WHERE e.AnnualCheckIn_Flag = 1
      AND YEAR(p.PolicyEnteredDate) >= 2025
)
SELECT 
	ap.PolicyEnteredDate,
    YEAR(ap.PolicyEnteredDate) AS PolicyYear,
    MONTH(ap.PolicyEnteredDate) AS PolicyMonth,
    COUNT(DISTINCT ap.PolicyId) AS AnnualCheckIn_REW_Shells,
    ap.EmployeeLastName,
    ap.shortname
FROM AnnualCheckIn_Policies ap
WHERE ap.[FirstPolicyTransactionType] = 'Rewrites'
GROUP BY ap.PolicyEnteredDate, YEAR(ap.PolicyEnteredDate), MONTH(ap.PolicyEnteredDate), ap.EmployeeLastName, ap.shortname
ORDER BY PolicyYear, PolicyMonth;





--Part 4: Active CDP Employee Count with cdpname and sales lead
WITH MonthEnds AS (
    SELECT 
        EOMONTH(DATEFROMPARTS(YEAR(DATEADD(MONTH, n, '2024-01-01')), 
                              MONTH(DATEADD(MONTH, n, '2024-01-01')), 1)) AS MonthEnd
    FROM (
        SELECT TOP (DATEDIFF(MONTH, '2024-01-01', GETDATE()) + 1)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.objects
    ) AS nums
),
ActiveEmployees AS (
    SELECT 
        e.AgencyEmployeeId,
        e.AgencyId,
        e.EmployeeType,
        e.EmployeeLastName,
        emp.shortname,
        e.OriginalHireDate,
        e.EmploymentEndDate
    FROM data_marts.AgencyEmployees e
    LEFT JOIN curated_ams.afw_employee emp
        ON e.AgencyEmployeeId = emp.empid
    WHERE 
        (e.EmployeeType = 'Business Development Associate')
        AND e.AgencyID IN ('0001', '0054')
)
SELECT 
    m.MonthEnd,
    YEAR(m.MonthEnd) AS YearNum,
    MONTH(m.MonthEnd) AS MonthNum,
    COUNT(DISTINCT a.AgencyEmployeeId) AS ActiveEmployeeCount,
    a.EmployeeLastName,
    a.shortname
FROM MonthEnds m
CROSS JOIN ActiveEmployees a
WHERE 
    DATEADD(DAY, 45, a.OriginalHireDate) <= m.MonthEnd
    AND (a.EmploymentEndDate IS NULL OR a.EmploymentEndDate > m.MonthEnd)
    AND YEAR(m.MonthEnd) >= 2025
GROUP BY 
    m.MonthEnd,
    YEAR(m.MonthEnd),
    MONTH(m.MonthEnd),
    a.EmployeeLastName,
    a.shortname
ORDER BY 
    m.MonthEnd;
