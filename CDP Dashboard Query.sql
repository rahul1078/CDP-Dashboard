--Changed query with shell date logic and added Opportunity type
--Added Sales lead for Frazier 

with CDPEmp as (
SELECT 
        e.AgencyEmployeeId,
        e.dataverseemployeeid,
        e.AgencyId,
        cast(e.EmployeeType as varchar(255)) EmployeeType,
		e.employeelastname,
		emp.shortname,
        e.OriginalHireDate,
        e.EmploymentEndDate
    FROM data_marts.AgencyEmployees e
	left join curated_ams.afw_employee emp on e.agencyemployeeid = emp.empid
    WHERE 
        (e.EmployeeType = 'Business Development Associate')
        AND e.AgencyID IN ('0001', '0054')
		),
		CDPopportunities as (
select distinct op.accountid,
op.opportunitytype,op.opportunityid,op.agencyemployeeid,op.createddate,op.initialquotedate,lob.lobsummary as opportunity_LOB,
case when op.opportunitytype = 'Renewal' then 'Renewals'
when op.opportunitytype = 'Rewrite' then 'Rewrites'
else 'New Business' end as opportunityTypePol,
op.quotedate,stage,CDP.employeelastname,CDP.shortname from data_marts.opportunities op 
LEFT JOIN data_marts.ProductOffers
    ON ProductOffers.OpportunityId = op.OpportunityId
LEFT JOIN data_marts.LineOfBusiness lob
    ON lob.LOBId = ProductOffers.LOBId
join CDPEmp CDP on op.agencyemployeeid = CDP.agencyemployeeid
where statusreason != 'Duplicate'
),
CDPQuotes as (
select *  from (
select o.*,t1.createdon,t1.id as quoteid,
row_number() over (partition by o.opportunityid,o.opportunity_LOB order by datediff(DAY, o.createddate,COALESCE(t1.createdon,'2100-01-01')) asc) rn1
from CDPopportunities o
left join curated_Dataverse.account a on o.accountid = a.new_customerid
left join (select di.id,di.new_account,di.createdon,di.modifiedby,lob.lobsummary from curated_dataverse.new_insurancequote di 
left join data_marts.lineofbusiness lob on lob.detailedname = di.new_producttypename) t1
on a.accountid=t1.new_account and t1.createdon >= o.createddate and t1.lobsummary = o.opportunity_lob) t
where rn1=1 or quoteid is null
)
select accountid,opportunitytype,opportunityid,agencyemployeeid,producerid,createddate as opportunitydate,quotedate as quotedate_opp,
stage,employeelastname,shortname,cast(createdon as date) as quotedate,quoteid,shelldate,policyentereddate,policyinforcestartdate,policyinforceenddate,policyid,firstpolicytransactiontype,
datediff(day,createddate,createdon) days_to_quote,
datediff(day,createddate,shelldate) days_to_shell,
case when quoteid is null then 0 else 1 end as quotecount,
case when policyid is null then 0 else 1 end as policycount
from (
select q.*,p.shelldate,p.policyid,policyentereddate,policyinforcestartdate,policyinforceenddate,p.producerid,firstpolicytransactiontype,
row_number() over (partition by q.opportunityid,q.opportunity_LOB order by abs(datediff(DAY,q.createddate,coalesce(p.shelldate,'2100-01-01'))) asc) rn2
from CDPQuotes q
left join data_marts.policies_v2 p on q.accountid = p.accountid and p.shelldate >= dateadd(day,-10,q.createddate) and p.firstpolicytransactiontype = q.opportunityTypePol and q.opportunity_LOB = p.lobsummary and q.agencyemployeeid = p.producerid) t
where rn2=1