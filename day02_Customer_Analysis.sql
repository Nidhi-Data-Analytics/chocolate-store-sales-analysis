/*
Exercise 1: Customer order summary

Write a query to display:
- CustomerID
- CustomerName
- Total number of orders
- Total quantity of chocolates purchased
- Total revenue generated
*/

select *
from OrderDetails;


select *
from Customers;

select *
from Orders;

select
	a.CustomerID,
	a.FirstName,
	a.LastName,
	Count(Distinct c.OrderID) as TotNmbrofOrders,
	SUM(c.Quantity) as TotQuantityofChoco,
	round(sum(c.Quantity * c.UnitPrice * (1 - c.DiscountPercent)),2) as TotRevPerCust
from customers as a
left join Orders as b
on a.CustomerID = b.CustomerID
left join OrderDetails as c
on b.OrderID = c.OrderID
group by a.CustomerID, a.FirstName, a.LastName;

/*
Exercise 2: Top 10 customers by revenue

Find the 10 customers who generated the highest total revenue.

Display:
- CustomerName
- TotalOrders
- TotalRevenue
*/

select top 10
	a.CustomerID,
	a.FirstName,
	a.LastName,
	Count(Distinct c.OrderID) as TotNmbrofOrders,
	SUM(c.Quantity) as TotQuantityofChoco,
	round(sum(c.Quantity * c.UnitPrice * (1 - c.DiscountPercent)),2) as TotRevPerCust
from customers as a
left join Orders as b
on a.CustomerID = b.CustomerID
left join OrderDetails as c
on b.OrderID = c.OrderID
group by a.CustomerID, a.FirstName, a.LastName
order by TotRevPerCust Desc;

/*
Exercise 3: Customers with multiple orders

Find customers who have placed more than one order.

Display:
- CustomerName
- TotalOrders
*/


select
	a.CustomerID,
	a.FirstName + ' ' + a.LastName as Full_Name,
	COUNT(distinct b.OrderID) as TotOrders
from Customers as a
left join Orders as b
	on a.CustomerID = b.CustomerID
group by 
	a.CustomerID, 
	a.FirstName, 
	a.LastName
HAVING COUNT(DISTINCT b.OrderID) > 1
order by TotOrders ASC;

/*
Exercise 4: Average order value
Calculate the average order value for the store.
Formula:
{Average Order Value} ={Total Revenue}/{Number of Orders}

Hint: Calculate revenue at the order level first, then average the order totals. 
Avoid averaging individual order-detail rows.
*/

select
	a.CustomerID,
	a.FirstName + ' ' + a.LastName Full_Name,
	Count(Distinct c.OrderID) as TotNmbrofOrders,
	SUM(c.Quantity) as TotQuantityofChoco,
	round(sum(c.Quantity * c.UnitPrice * (1 - c.DiscountPercent)),2) as TotRevPerCust,
	round((sum(c.Quantity * c.UnitPrice * (1 - c.DiscountPercent)) / Count(Distinct c.OrderID)),2) AvgOrderValue
from customers as a
left join Orders as b
on a.CustomerID = b.CustomerID
left join OrderDetails as c
on b.OrderID = c.OrderID
group by a.CustomerID, a.FirstName, a.LastName
order by TotRevPerCust Desc;

/*
Exercise 5: Customer spending categories

Classify customers into three groups based on their total revenue:
- High Value: Revenue greater than or equal to $500
- Medium Value: Revenue between $200 and $499.99
- Low Value: Revenue below $200
Hint: Use a CTE or subquery and CASE WHEN.
*/

select 
	*,
	CASE WHEN TotRevPerCust >= 500 THEN 'High Value'
		 When TotRevPerCust >= 200 THEN 'Medium Value'
		 WHEN TotRevPerCust < 200 THEN 'Low Value'
	END as Cust_Classification
from
(
select
	a.CustomerID,
	a.FirstName + ' ' + a.LastName Full_Name,
	Count(Distinct c.OrderID) as TotNmbrofOrders,
	SUM(c.Quantity) as TotQuantityofChoco,
	round(sum(c.Quantity * c.UnitPrice * (1 - c.DiscountPercent)),2) as TotRevPerCust
from customers as a
left join Orders as b
on a.CustomerID = b.CustomerID
left join OrderDetails as c
on b.OrderID = c.OrderID
group by a.CustomerID, a.FirstName, a.LastName
)t


/*
Exercise 6: Customer ranking
Rank customers based on their revenue, from highest to lowest.
Hint: Use RANK() or DENSE_RANK() with OVER (ORDER BY ...).
Important: Use the same revenue formula as Day 1:
Quantity * UnitPrice * (1 - DiscountPercent)
If your discount is stored as a whole percentage, divide it by 100.
*/

select 
	*,
	CASE WHEN TotRevPerCust >= 500 THEN 'High Value'
		 When TotRevPerCust >= 200 THEN 'Medium Value'
		 WHEN TotRevPerCust < 200 THEN 'Low Value'
	END as Cust_Classification,
	RANK() OVER (Order by TotRevPerCust DESC) as Cust_Rank,
	DENSE_RANK() OVER (Order by TotRevPerCust DESC) as Cust_DenseRank

from
(
select
	a.CustomerID,
	a.FirstName + ' ' + a.LastName Full_Name,
	Count(Distinct c.OrderID) as TotNmbrofOrders,
	SUM(c.Quantity) as TotQuantityofChoco,
	round(sum(c.Quantity * c.UnitPrice * (1 - c.DiscountPercent)),2) as TotRevPerCust
from customers as a
left join Orders as b
on a.CustomerID = b.CustomerID
left join OrderDetails as c
on b.OrderID = c.OrderID
group by a.CustomerID, a.FirstName, a.LastName
)t
