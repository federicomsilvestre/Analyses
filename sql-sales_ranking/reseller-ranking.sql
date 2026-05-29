use AdventureWorksDW2019

select top 10
EmployeeKey
,sum (SalesAmount) as Total_sales
,DENSE_RANK () over (order by sum (SalesAmount) desc) as Sales_Rank

from dbo.FactResellerSales
group by EmployeeKey
order by sum (SalesAmount) desc
