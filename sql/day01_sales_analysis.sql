--Business scenario
--The store manager wants to understand sales performance, customer activity, 
--and which products deserve more attention.

/*

1. Inspect the database · 8 min

SELECT, COUNT, DISTINCT
Check how many records are in Customers, Products, Orders, and OrderDetails. Find the distinct order statuses.
Hint: Start with SELECT COUNT(*) for each table. Use DISTINCT on the status column.

*/

select
	COUNT(*) as NmbrofRowsofCust
from Customers;

select
	COUNT(*) as NmbrofRowsofPdt
from Products;

select
	COUNT(*) as NmbrofRowsofORders
from Orders;

select
	COUNT(*) as NmbrofRowsofOrdDetails
from OrderDetails;

select 
	distinct (OrderStatus)
from Orders;

/*

2. Find the top products · 12 min

JOIN, GROUP BY, SUM, ORDER BY
Calculate sales revenue for each product and return the five products with the highest revenue.
Hint: Join OrderDetails to Products. Revenue per line is Quantity × UnitPrice × (1 − DiscountPercent). 
Group by product ID and name.

*/

select
	*
from OrderDetails;

select 
	*
from Products;

--step1
select
	a.ProductID,
	a.ProductName,
	SUM(b.Quantity * b.UnitPrice * (1 - b.DiscountPercent)) as RevPerProduct
from Products as a
left join OrderDetails as b
on a.ProductID = b.ProductID
group by a.ProductID,a.ProductName
order by RevPerProduct Desc

--step2

select top 5
	a.ProductID,
	a.ProductName,
	SUM(b.Quantity * b.UnitPrice * (1 - b.DiscountPercent)) as RevPerProduct,
	ROUND(SUM(b.Quantity * b.UnitPrice * (1 - b.DiscountPercent)),0) as RevPerProductRounded
from Products as a
left join OrderDetails as b
on a.ProductID = b.ProductID
group by a.ProductID,a.ProductName
order by RevPerProduct Desc;

/*
3. Compare categories · 12 min

JOIN, GROUP BY
Calculate total revenue for each product category and sort categories from highest to lowest.
Hint: You need the product category as well as order-line values. 
Trace the relationship from OrderDetails through Products to Categories.

*/

select
	*
from OrderDetails;

select 
	*
from Products;

select
	a.CategoryID,
	SUM(b.Quantity * b.UnitPrice * (1 - b.DiscountPercent)) as RevPerCategory
from Products as a
left join OrderDetails as b
on a.ProductID = b.ProductID
group by a.CategoryID
order by RevPerCategory Desc;

/*
4. Find valuable customers · 12 min

JOIN, GROUP BY, TOP
Identify the five customers who generated the most revenue. Display the customer ID, name, and revenue.
Hint: Connect Customers to Orders and then to OrderDetails. 
Aggregate at the customer level before selecting the top five.
*/

select *
from Customers;

select *
from Orders;

select *
from OrderDetails;

--step 1 - joining the orders table to customers, joining the orderdetails table to (Customers + Orders) using OrderID
select
	a.CustomerID,
	a.FirstName,
	a.LastName,
	sum(c.Quantity * c.UnitPrice * ( 1 - c.DiscountPercent)) as RevPerCustomer
from Customers as a
left join Orders as b
on a.CustomerID = b.CustomerID
left join OrderDetails as c
on b.OrderID = c.OrderID
group by a.CustomerID,a.FirstName,a.LastName;

--step 2 - sorting and choosing top 5 customers

select top 5
	a.CustomerID,
	a.FirstName,
	a.LastName,
	sum(c.Quantity * c.UnitPrice * ( 1 - c.DiscountPercent)) as RevPerCustomer
from Customers as a
left join Orders as b
on a.CustomerID = b.CustomerID
left join OrderDetails as c
on b.OrderID = c.OrderID
group by a.CustomerID,a.FirstName,a.LastName
order by RevPerCustomer Desc;

/*
Conclusion:
-- the top 5 customers are Nina Miller, Grace Johnson, Aisha Wright; anika Chen, Anika Hall
-- Top 5 products sold are Assorted Gift Box Large
Valentine Truffle Box
Holiday Chocolate Tin
Assorted Gift Box Small
Classic Hot Cocoa Mix
*/


