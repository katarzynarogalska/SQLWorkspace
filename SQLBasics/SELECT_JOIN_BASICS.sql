--Zad1 : Wy�wietlenie nazw miast w Niemczech, do kt�rych dostarczono produkty
SELECT DISTINCT ShipCity FROM Orders
WHERE ShipCountry='Germany'

--Zad2: Wy�wietlenie danych zam�wie� z�o�onych w lipcu 1996
SELECT * FROM Orders
WHERE year(OrderDate)=1996 AND month(OrderDate)=7

--Zad3: Wy�wietlenie pierwszych 10 znak�w nazw firm, po konwersji do du�ych znak�w
SELECT UPPER(SUBSTRING(CompanyName,0,11)) FROM Customers 

--Zad4: Wy�wietlenie danych wszystkich zam�wie� z�o�onych przez klient�w z Francji
SELECT * FROM Orders o
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country='France'

--Zad5: Wy�wietlenie wszystkich kraj�w dostawy dla zam�wie� z�o�onych przez
--klient�w z Niemiec
SELECT DISTINCT o.ShipCountry FROM Orders o
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country='Germany'

--Zad6: Znalezienie wszystkich zam�wie� dostarczonych do innego
--kraju ni� kraj, z kt�rego pochodzi� klient
SELECT o.* FROM Orders o
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country != o.ShipCountry

--Zad7: Znalezienie wszystkich klient�w, kt�rzy nigdy nie z�o�yli �adnych zam�wie�
SELECT c.* FROM Customers c
WHERE NOT EXISTS (SELECT * FROM Orders o
					WHERE o.CustomerID=c.CustomerID)

--Zad8: Znalezienie wszystkich klient�w, kt�rzy nigdy nie zam�wili produktu Chocolade
SELECT c.CompanyName FROM Customers c
WHERE NOT EXISTS (SELECT * FROM Orders o 
					JOIN [Order Details] od ON o.OrderID=od.OrderID
					JOIN Products p ON od.ProductID=p.ProductID
					WHERE o.CustomerID=c.CustomerID
					AND p.ProductName='Chocolade')

--Zad9: Znalezienie wszystkich klient�w, kt�rzy kiedykolwiek zam�wili Scottish Longbreads
SELECT c.CompanyName FROM Customers c
WHERE EXISTS (SELECT * FROM Orders o 
					JOIN [Order Details] od ON o.OrderID=od.OrderID
					JOIN Products p ON od.ProductID=p.ProductID
					WHERE o.CustomerID=c.CustomerID
					AND p.ProductName='Scottish Longbreads')

--Zad10: Znalezienie zam�wie�, kt�re zawieraj� Scottish Longbreads,
--ale nie zawieraj� Chocolade
SELECT o.* FROM Orders o 
WHERE EXISTS (SELECT * FROM [Order Details] od
			JOIN Products p ON od.ProductID=p.ProductID
			WHERE o.OrderID=od.OrderID
			AND p.ProductName='Scottish Longbreads')
AND NOT EXISTS (SELECT * FROM [Order Details] od
			JOIN Products p ON od.ProductID=p.ProductID
			WHERE o.OrderID=od.OrderID
			AND p.ProductName='Chocolade')


--Zad11: Znalezienie danych wszystkich pracownik�w, kt�rzy obs�ugiwali zam�wienia 
--klienta ALFKI. Oczekiwany format wyniku: Imi� i nazwisko pracownika
SELECT e.FirstName, e.LastName FROM Employees e
WHERE EXISTS (SELECT * FROM Orders o
				JOIN Customers c ON o.CustomerID=c.CustomerID
				WHERE c.CustomerID='ALFKI'
				AND e.EmployeeID=o.EmployeeID)

--Zad12: Przygotowanie raportu zawieraj�cego nast�puj�ce dane: imi� pracownika,
--nazwisko pracownika, data zam�wienia,informacja, czy zam�wienie zawiera�o Chocolate (0/1).
--W raporcie nale�y uwzgl�dni� ka�dego pracownika
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

--Zad13: Przygotowanie raportu zawieraj�cego nast�puj�ce dane: nazwa produktu,
--kraj dostawy, numer zam�wienia, rok zam�wienia, miesi�c zam�wienia,
--data zam�wienia posortowanego w malej�cej kolejno�ci dat zam�wienia. W
--raporcie nale�y uwzgl�dni� tylko zam�wienia z�o�one przez klient�w z
--Niemiec i produkty o nazwach rozpoczynaj�cych si� na liter� z przedzia�u [c-s]

SELECT p.ProductName, o.ShipCountry, o.OrderID, year(o.OrderDate) as OrderYear, month(o.OrderDate) as OrderMonth, o.OrderDate
FROM Orders o 
JOIN Customers c on o.CustomerID=c.CustomerID
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE c.Country='Germany' 
AND p.ProductName LIKE '[c-s]%'
ORDER BY o.OrderDate DESC

--Zad14: Poka� dla ka�dego elementu zam�wienia - nazwisko klienta i identyfikator
--zam�wienia, nazw� produktu, zam�wion� ilo��, cen� produktu oraz cen� ca�kowit�
--(ilo�� zam�wiona * cena produktu) oraz r�nic� mi�dzy dat� zam�wienia a dat�
--wysy�ki (r�nica w dniach). Posortuj wed�ug identyfikatora zam�wienia.

SELECT c.ContactName, o.OrderID, p.ProductName, od.Quantity, od.UnitPrice, (od.Quantity*od.UnitPrice) AS TotalPrice,
DATEDIFF(day,o.OrderDate ,o.ShippedDate) as ShipDuration 
FROM Orders o 
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
JOIN Customers c ON o.CustomerID=c.CustomerID
ORDER BY o.OrderID

