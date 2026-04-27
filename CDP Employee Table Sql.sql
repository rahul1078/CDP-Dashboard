-- Employees Dimension Table
SELECT DISTINCT
    Ae.AgencyEmployeeId,
    Ae.employeelastname,
    emp.shortname,
    CONCAT(emp.shortname, ' ', Ae.employeelastname) AS EmployeeName
FROM data_marts.AgencyEmployees AS Ae
LEFT JOIN curated_ams.afw_employee emp
    ON Ae.AgencyEmployeeId = emp.empid
WHERE
    (Ae.EmployeeType = 'Business Development Associate')
    AND Ae.AgencyId IN ('0001', '0054')