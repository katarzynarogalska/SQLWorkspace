--Zad1 : Wyœwietlenie nazw miast w Niemczech, do których dostarczono produkty
SELECT DISTINCT ShipCity FROM Orders
WHERE ShipCountry='Germany'

--Zad2: Wyœwietlenie danych zamówieñ z³o¿onych w lipcu 1996
SELECT * FROM Orders
WHERE year(OrderDate)=1996 AND month(OrderDate)=7

--Zad3: Wyœwietlenie pierwszych 10 znaków nazw firm, po konwersji do du¿ych znaków
SELECT UPPER(SUBSTRING(CompanyName,0,11)) FROM Customers 

--Zad4: Wyœwietlenie danych wszystkich zamówieñ z³o¿onych przez klientów z Francji
SELECT * FROM Orders o
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country='France'

--Zad5: Wyœwietlenie wszystkich krajów dostawy dla zamówieñ z³o¿onych przez
--klientów z Niemiec
SELECT DISTINCT o.ShipCountry FROM Orders o
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country='Germany'

--Zad6: Znalezienie wszystkich zamówieñ dostarczonych do innego
--kraju ni¿ kraj, z którego pochodzi³ klient
SELECT o.* FROM Orders o
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country != o.ShipCountry

--Zad7: Znalezienie wszystkich klientów, którzy nigdy nie z³o¿yli ¿adnych zamówieñ
SELECT c.* FROM Customers c
WHERE NOT EXISTS (SELECT * FROM Orders o
					WHERE o.CustomerID=c.CustomerID)

--Zad8: Znalezienie wszystkich klientów, którzy nigdy nie zamówili produktu Chocolade
SELECT c.CompanyName FROM Customers c
WHERE NOT EXISTS (SELECT * FROM Orders o 
					JOIN [Order Details] od ON o.OrderID=od.OrderID
					JOIN Products p ON od.ProductID=p.ProductID
					WHERE o.CustomerID=c.CustomerID
					AND p.ProductName='Chocolade')

--Zad9: Znalezienie wszystkich klientów, którzy kiedykolwiek zamówili Scottish Longbreads
SELECT c.CompanyName FROM Customers c
WHERE EXISTS (SELECT * FROM Orders o 
					JOIN [Order Details] od ON o.OrderID=od.OrderID
					JOIN Products p ON od.ProductID=p.ProductID
					WHERE o.CustomerID=c.CustomerID
					AND p.ProductName='Scottish Longbreads')

--Zad10: Znalezienie zamówieñ, które zawieraj¹ Scottish Longbreads,
--ale nie zawieraj¹ Chocolade
SELECT o.* FROM Orders o 
WHERE EXISTS (SELECT * FROM [Order Details] od
			JOIN Products p ON od.ProductID=p.ProductID
			WHERE o.OrderID=od.OrderID
			AND p.ProductName='Scottish Longbreads')
AND NOT EXISTS (SELECT * FROM [Order Details] od
			JOIN Products p ON od.ProductID=p.ProductID
			WHERE o.OrderID=od.OrderID
			AND p.ProductName='Chocolade')


--Zad11: Znalezienie danych wszystkich pracowników, którzy obs³ugiwali zamówienia 
--klienta ALFKI. Oczekiwany format wyniku: Imiê i nazwisko pracownika
SELECT e.FirstName, e.LastName FROM Employees e
WHERE EXISTS (SELECT * FROM Orders o
				JOIN Customers c ON o.CustomerID=c.CustomerID
				WHERE c.CustomerID='ALFKI'
				AND e.EmployeeID=o.EmployeeID)

--Zad12: Przygotowanie raportu zawieraj¹cego nastêpuj¹ce dane: imiê pracownika,
--nazwisko pracownika, data zamówienia,informacja, czy zamówienie zawiera³o Chocolate (0/1).
--W raporcie nale¿y uwzglêdniæ ka¿dego pracownika
SELECT e.FirstName, e.LastName, o.OrderDate, (CASE WHEN o.OrderID is null THEN 0 ELSE 1 END) AS ChocoladeInOrder
FROM Employees e
LEFT JOIN Orders o ON o.EmployeeID=e.EmployeeID
LEFT JOIN [Order Details] od ON o.OrderID=od.OrderID
AND od.ProductID = (SELECT p.ProductID FROM Products p
					WHERE p.ProductName='Chocolade')

select firstname, lastname, orderdate,
(case when od.orderid is null then 0 else 1 end) as status
from employees e
left join orders o on o.employeeid=e.employeeid
left join [order details] od on o.orderid=od.orderid and
od.productid=(select productid from products where
productname='Chocolade')

--Zad13: Przygotowanie raportu zawieraj¹cego nastêpuj¹ce dane: nazwa produktu,
--kraj dostawy, numer zamówienia, rok zamówienia, miesi¹c zamówienia,
--data zamówienia posortowanego w malej¹cej kolejnoœci dat zamówienia. W
--raporcie nale¿y uwzglêdniæ tylko zamówienia z³o¿one przez klientów z
--Niemiec i produkty o nazwach rozpoczynaj¹cych siê na literê z przedzia³u [c-s]

SELECT p.ProductName, o.ShipCountry, o.OrderID, year(o.OrderDate) as OrderYear, month(o.OrderDate) as OrderMonth, o.OrderDate
FROM Orders o 
JOIN Customers c on o.CustomerID=c.CustomerID
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE c.Country='Germany' 
AND p.ProductName LIKE '[c-s]%'
ORDER BY o.OrderDate DESC

--Zad14: Poka¿ dla ka¿dego elementu zamówienia - nazwisko klienta i identyfikator
--zamówienia, nazwê produktu, zamówion¹ iloœæ, cenê produktu oraz cenê ca³kowit¹
--(iloœæ zamówiona * cena produktu) oraz ró¿nicê miêdzy dat¹ zamówienia a dat¹
--wysy³ki (ró¿nica w dniach). Posortuj wed³ug identyfikatora zamówienia.

SELECT c.ContactName, o.OrderID, p.ProductName, od.Quantity, od.UnitPrice, (od.Quantity*od.UnitPrice) AS TotalPrice,
DATEDIFF(day,o.OrderDate ,o.ShippedDate) as ShipDuration 
FROM Orders o 
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
JOIN Customers c ON o.CustomerID=c.CustomerID
ORDER BY o.OrderID

