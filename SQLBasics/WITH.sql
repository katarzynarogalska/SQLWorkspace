-- Examples
-- Fetch orderId with quantities more than average quantity
WITH avg_quantity (avg_sal) AS (
			SELECT AVG(od.Quantity) FROM [Order Details] od)

SELECT od.OrderID FROM [Order Details] od, avg_quantity av
WHERE od.Quantity>av.avg_sal

-- Example2: Find stores whose sales were better than average sales (columns: store_id, storeName, product, Quantity, cost)
-- 1) Total sales for each store
with totalSales (store, total) AS(
			SELECT store_id, SUM(cost) 
			FROM Stores 
			GROUP BY store_id)
-- 2) average of total sales
	 avg_sales (avg_s) AS(
				SELECT AVG(total) FROM totalSales)
--3) select the stores
SELECT store_id FROM totalSales ts
JOIN avg_sales av ON ts.total>av.avg_s

--Zad1: Dla ka�dego produktu znajd� wszystkich klient�w, kt�rzy
--z�o�yli zam�wienie na najwi�ksz� kiedykolwiek zam�wion� ilo�� tego produktu.
-- Wynik: ProductName, CompanyName, MaxQuantity

--1) Tabela z produktem - max ilo�� jego zam�wie�, tabela Customer-Product tam gdzie max ilo��
with Product_Max (product, max_quantity) AS (
					SELECT od.ProductID, MAX(od.Quantity) FROM [Order Details] od
					GROUP BY od.ProductID),

	Product_Customer_MaxQuantity (product, customer, max_quant) AS (
								SELECT od.ProductID, o.CustomerID, od.Quantity
								FROM Orders o 
								JOIN [Order Details] od ON o.OrderID=od.OrderID
								JOIN Product_Max pm ON pm.product = od.ProductID
								WHERE od.Quantity = pm.max_quantity)
--Tabela finalna:
SELECT p.ProductName, c.CompanyName, pcm.max_quant
FROM Product_Customer_MaxQuantity pcm
JOIN Products p ON p.ProductID=pcm.product
JOIN Customers c ON c.CustomerID=pcm.customer

--Zad2: Wymie� wszystkich pracownik�w, kt�rzy nadzorowali liczb�
--zam�wie� wi�ksz� ni� 120% �redniej liczby zam�wie� nadzorowanych przez pracownika

--1: Pracownik-liczba zam�wie�,
--2: �rednia liczba zam�wie� 
--3: ostateczna tabela pracownik�w, kt�rzy o 120% �redniej

with employee_orders (employeeID, orderCount) AS (
						SELECT o.EmployeeID, COUNT(o.OrderID) 
						FROM Orders o
						GROUP BY o.EmployeeID),
	avg_orderCount (avgCount) AS (
						SELECT AVG(orderCount) FROM employee_orders)

SELECT e.EmployeeID 
FROM Employees e 
JOIN employee_orders eo ON eo.employeeID=e.EmployeeID
CROSS JOIN avg_orderCount ac
WHERE eo.orderCount>=1.2*ac.avgCount



--Zad3: Wy�wietl dane 5 zam�wie� zawieraj�cych najwi�ksz� liczb�
--r�nych produkt�w umieszczonych na jednym zam�wieniu.
--Wynik powinien zawiera�: OrderId, ProductCount

SELECT TOP 5 od.OrderID, COUNT(od.ProductID) as ProductCount 
FROM [Order Details] od
GROUP BY od.OrderID
ORDER BY COUNT(od.ProductID) DESC

--Zad4: Znajd� wszystkie produkty, kt�re zam�wiono w wi�kszej ilo�ciw 1997 r. ni� w 1996 r.
--Wynik powinien zawiera� kolumny: ProductName,TotalQuantityIn1996, TotalQuantityIn1997

with product_quantity (productName, quantity97, quantity96) AS (
						SELECT p.ProductName, 
						SUM(CASE WHEN year(o.OrderDate)= 1997 THEN od.Quantity ELSE 0 END),
						SUM(CASE WHEN year(o.OrderDate)=1996 THEN od.Quantity ELSE 0 END)
						FROM Orders o 
						JOIN [Order Details] od ON o.OrderID=od.OrderID
						JOIN Products p ON od.ProductID=p.ProductID
						GROUP BY p.ProductID,p.ProductName)
SELECT * FROM product_quantity
WHERE quantity97>quantity96


--Zad5: Znajd� wszystkie produkty, na kt�re z�o�ono wi�cej zam�wie�w 1997 r. ni� w 1996 r.
--Wynik powinien zawiera� kolumny: ProductName, NumberOfOrdersIn1996, NumberOfOrdersIn1997

with product_orderNumber (productName, orderNb96, orderNb97) AS(
							SELECT p.ProductName, 
							SUM(CASE WHEN year(o.OrderDate)=1996 THEN 1 ELSE 0 END),
							SUM(CASE WHEN year(o.OrderDate)=1997 THEN 1 ELSE 0 END)
							FROM Orders o 
							JOIN [Order Details] od ON o.OrderID=od.OrderID
							JOIN Products p ON od.ProductID=p.ProductID
							GROUP BY p.ProductID, p.ProductName)
SELECT * FROM product_orderNumber
WHERE orderNb96<orderNb97


