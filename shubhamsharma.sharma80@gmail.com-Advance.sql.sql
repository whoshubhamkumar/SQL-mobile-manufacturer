--SQL Advance Case Study
CREATE DATABASE db_SQLCaseStudies


select * from [dbo].[DIM_CUSTOMER] 
select * from [dbo].[DIM_DATE]
select * from [dbo].[DIM_LOCATION]
select * from [dbo].[DIM_MANUFACTURER]
select * from [dbo].[DIM_MODEL]
select * from [dbo].[FACT_TRANSACTIONS]

--Q1--BEGIN 


select State from FACT_TRANSACTIONS F
inner join DIM_LOCATION L ON F.IDLocation= L.IDLocation
where [Date] BETWEEN '2005-01-01' AND GETDATE()


--Q1--END

--Q2--BEGIN
	

select  top 1 state from DIM_LOCATION L
inner join FACT_TRANSACTIONS F on  L.IDLocation= F.IDLocation
inner join DIM_MODEL M on F.IDModel = M.IDModel
inner join DIM_MANUFACTURER  MA on MA.IDManufacturer= M.IDManufacturer
where Manufacturer_Name = 'samsung' and country ='us'
group by State
order by SUM(Quantity) desc


--Q2--END

--Q3--BEGIN      
	

select Model_Name, zipcode, state, count(IDCustomer) as no_of_transactions from DIM_LOCATION L
inner join FACT_TRANSACTIONS F on  L.IDLocation= F.IDLocation
inner join DIM_MODEL M on F.IDModel= M.IDModel
group by Model_Name, state, ZipCode


--Q3--END

--Q4--BEGIN


select top 1 idmodel, model_name, Unit_price from DIM_MODEL
order by Unit_price asc


--Q4--END

--Q5--BEGIN


select Model_Name, AVG(Unit_price) [AVG_PRICE] from DIM_MODEL M
inner join DIM_MANUFACTURER MA on MA.IDManufacturer = M.IDManufacturer
where Manufacturer_Name in (
select top 5 Manufacturer_Name from FACT_TRANSACTIONS F
inner join  DIM_MODEL M ON F.IDMODEL = M.IDMODEL
inner join  DIM_MANUFACTURER MA ON MA.IDMANUFACTURER = M.IDMANUFACTURER
GROUP BY Manufacturer_Name
ORDER BY SUM(Quantity)
)
GROUP BY Model_Name
ORDER BY AVG(Unit_price) DESC


--Q5--END

--Q6--BEGIN


select Customer_Name, AVG(TotalPrice) [average amount spent] from DIM_CUSTOMER C
Inner join FACT_TRANSACTIONS F ON C.IDCustomer = F.IDCustomer
where year(Date) = 2009 
Group by Customer_Name
Having AVG(TotalPrice)>500


--Q6--END
	
--Q7--BEGIN  
	

Select T1.Model_Name  from (select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
where YEAR(F.[Date])=2008 
group by Mo.Model_Name,Mo.IDmodel
order by TotQty desc) as T1 inner join
(select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
where YEAR(F.[Date])=2009
group by Mo.Model_Name,Mo.IDmodel
order by TotQty desc) as T2 on T1.Model_Name=T2.Model_Name inner join
(select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
where YEAR(F.[Date])=2010
group by Mo.Model_Name,Mo.IDmodel
order by TotQty desc) as T3 on T3.Model_Name=T2.Model_Name


--Q7--END	

--Q8--BEGIN


WITH cte AS
(
SELECT Manufacturer_name, DATEPART(Year,date) as yr,
DENSE_RANK() OVER (PARTITION BY DATEPART(Year,date) ORDER BY SUM(TotalPrice) DESC) AS Rank 
    FROM Fact_Transactions FT
    LEFT JOIN DIM_Model DM ON FT.IDModel = DM.IDModel
    LEFT JOIN DIM_MANUFACTURER MFC  ON MFC.IDManufacturer = DM.IDManufacturer
    group by Manufacturer_name,DATEPART(Year,date) 
),
cte2 AS
(
SELECT Manufacturer_Name, yr
FROM cte WHERE rank = 2
AND yr IN ('2009','2010')
)
SELECT c.Manufacturer_Name [manufacturer with the 2nd top sales in the year of 2009] ,t.Manufacturer_Name [manufacturer with the 2nd top sales in the year of 2009]
FROM cte2 AS c, cte2 AS t
WHERE c.yr < t.yr


--Q8--END

--Q9--BEGIN
	

select Manufacturer_Name from DIM_MANUFACTURER MA
inner join DIM_MODEL M on MA.IDManufacturer= M.IDManufacturer
inner join FACT_TRANSACTIONS F on M.IDModel= F.IDModel
where year(Date) = 2010 
except
select Manufacturer_Name from DIM_MANUFACTURER MA
inner join DIM_MODEL M on MA.IDManufacturer= M.IDManufacturer
inner join FACT_TRANSACTIONS F on M.IDModel= F.IDModel
where year(Date) = 2009


--Q9--END

--Q10--BEGIN
	

select TBL1.IDCustomer,TBL1.Customer_Name , TBL1.[Year],TBL1.Avg_Spend,TBL1.Avg_Qty,case when TBL2.[Year] is not null then
((TBL1.Avg_Spend-TBL2.Avg_Spend)/TBL2.Avg_Spend )* 100 
else NULL
end as 'YOY in Average Spend' from
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL1 
left join 
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL2 
on TBL1.IDCustomer=TBL2.IDCustomer and TBL2.[Year]=TBL1.[Year]-1;


--Q10--END
	