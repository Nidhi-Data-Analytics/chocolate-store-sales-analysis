/*
Exercise 1 – Understand order dates and statuses
Write queries to find:
1. The earliest order date.
2. The latest order date.
3. The total number of orders.
4. The number of unique order statuses.
5. The number of orders under each status.
Hints:
- MIN()
- MAX()
- COUNT(DISTINCT ...)
- GROUP BY
- ORDER BY
For the status analysis, display OrderStatus and TotalOrders.
*/

select *
from OrderDetails;
select *
from Orders;

select
	MIN(OrderDate) as EarliestOrder,
	MAX(OrderDate) as LatestOrder,
	COUNT(Distinct OrderID) as TotOrders,
	COUNT(Distinct OrderStatus) as TotOrderStatuses
from Orders;


select
	Distinct OrderStatus,
	COUNT(Distinct OrderID) as  NmbrofOrders
from Orders
group by OrderStatus;


/*
Exercise 2 – Monthly sales analysis
Calculate total revenue for each month.

Display:
- Year
- Month
- Number of orders
- Total quantity sold
- Total revenue
Hint: Use YEAR(), MONTH(), COUNT(DISTINCT OrderID) and SUM().

Make sure you group by both year and month, not just month. Otherwise, January from different years could be combined.
*/

select *
from OrderDetails;

select 
	YEAR(EOMonth(b.OrderDate)) as YearofOrder,
	MONTH(EOMonth(b.OrderDate)) as MonthofOrder,
	EOMONTH(b.OrderDate) as EndofMonth,
	COUNT(Distinct a.OrderID) as NmbrofOrderMonthly,
	SUM(a.Quantity) as TotQuantityMonthly,
	SUM(a.Quantity * a.UnitPrice * (1 - a.DiscountPercent)) as TotRevMonthly
from OrderDetails as a
left join Orders as b
	on a.OrderID = b.OrderID
group by EOMonth(b.OrderDate);

/*
Exercise 3 – Best-performing month
Find the month with the highest revenue.

Display:
- Year
- Month
- Total revenue
Hint: You can reuse your Exercise 2 query as a CTE and then use TOP 1 with ORDER BY TotalRevenue DESC.

Bonus: Try TOP 3 to find the three best-performing months.
*/

select Top 3 
	YEAR(EOMonth(b.OrderDate)) as YearofOrder,
	MONTH(EOMonth(b.OrderDate)) as MonthofOrder,
	EOMONTH(b.OrderDate) as EndofMonth,
	COUNT(Distinct a.OrderID) as NmbrofOrderMonthly,
	SUM(a.Quantity) as TotQuantityMonthly,
	SUM(a.Quantity * a.UnitPrice * (1 - a.DiscountPercent)) as TotRevMonthly
from OrderDetails as a
left join Orders as b
	on a.OrderID = b.OrderID
group by EOMonth(b.OrderDate)
order by TotRevMonthly Desc;

/*
Exercise 4 – Order status analysis
Find:
- Total orders for each order status.
- Revenue associated with each order status.
- Percentage of total orders represented by each status.
Hint: Use GROUP BY OrderStatus and a window function such as SUM(COUNT(...)) OVER() or calculate the overall order count in a separate CTE.
Be careful: the status percentage should be based on distinct orders, not order-detail rows.
*/

select
	*,
	Sum(NmbrofOrdersbyStatus) over() as TotOrders,
	concat(round((NmbrofOrdersbyStatus *100) / Sum(NmbrofOrdersbyStatus) over(),2),'%') as TotOrdersPercentbyStatus
from
(
select
	Distinct b.OrderStatus,
	COUNT(Distinct a.OrderID) as NmbrofOrdersbyStatus,
	SUM(a.Quantity * a.UnitPrice * (1 - a.DiscountPercent)) as TotRevbyStatus
from OrderDetails as a
left join Orders as b
	on a.OrderID = b.OrderID
group by b.OrderStatus
)t;

/*
Exercise 5 – Average monthly revenue
Calculate:
- Total revenue
- Number of months with orders
- Average monthly revenue
Hint: First calculate revenue by month using a CTE. Then use AVG() on the monthly revenue values.
*/

select
	*,
	MonthlyRev/NmbrofOrdersInThisMonth as AvgMonthlyRev
from
(
select 
	MONTH(b.OrderDate) as OrderMonth,
	COUNT(Distinct a.OrderID) as NmbrofOrdersInThisMonth,
	SUM(a.Quantity * a.UnitPrice * (1 - a.DiscountPercent)) as MonthlyRev
from OrderDetails as a
left join Orders as b
	on a.OrderID = b.OrderID
group by MONTH(b.OrderDate)
)t;

/*
Exercise 6 – Month-over-month revenue comparison
Compare each month's revenue with the previous month's revenue.

Display:
- Year
- Month
- Current month revenue
- Previous month revenue
- Revenue difference
Hint: Use LAG().

For an extra challenge, calculate the percentage change:
\[
\text{MoM Change \%} =
\frac{\text{Current Revenue - Previous Revenue}}
{\text{Previous Revenue}}\times100
\]
Use NULLIF() to avoid division by zero.
Note: LAG() compares with the previous available month in your grouped results. If a calendar month has no orders, it won't automatically appear as a zero-revenue month. Handling missing months is a useful advanced exercise.
*/

select
	*,
	LAG(CurrentMonthlyRev,1) over (Order by EOMnthofOrder) as LastMonthRev,
	CurrentMonthlyRev - LAG(CurrentMonthlyRev,1) over (Order by EOMnthofOrder)  as RevDiff,
	concat(Round((CurrentMonthlyRev - LAG(CurrentMonthlyRev,1) over (Order by EOMnthofOrder))*100 
						/ (LAG(CurrentMonthlyRev,1) over (Order by EOMnthofOrder)),2),'%') as MoMChange
from
(
select 
	YEAR(EOMonth (b.OrderDate)) as YearofOrder,
	MONTH(EOMonth (b.OrderDate)) as MonthofOrder,
	EOMONTH(b.OrderDate) as EOMnthofOrder,
	SUM(a.Quantity * a.UnitPrice * (1 - a.DiscountPercent)) as CurrentMonthlyRev	
from OrderDetails as a
left join Orders as b
	on a.OrderID = b.OrderID
group by EOMONTH(b.OrderDate)
)t;

/*
Exercise 7 – Find high-revenue orders
Identify individual orders whose total revenue is greater than $100.

Display:
- OrderID
- OrderDate
- OrderStatus
- OrderRevenue
Hint: First calculate revenue per order using a CTE, then filter using WHERE OrderRevenue > 100.
*/

select 
	b.OrderID,
	b.OrderDate,
	b.OrderStatus,
	SUM(a.Quantity * a.UnitPrice * (1 - DiscountPercent)) as TotRevbyOrder
from OrderDetails a
left join Orders b
	on a.OrderID = b.OrderID
group by b.OrderID, b.OrderDate, b.OrderStatus
having SUM(a.Quantity * a.UnitPrice * (1 - DiscountPercent)) > 100
order by TotRevbyOrder ASC

-------------------------------------------------------------------------------------------------------------